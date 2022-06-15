// import nessecary dart core libaries
import 'dart:convert';
import 'dart:io';
// import nessecary packages
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:background_location/background_location.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
// import nessecary files
import 'api.dart';
import 'settings.dart';
import 'railway.dart';
import 'tutorial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Build the app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Railway Explorer',
      theme: ThemeData(
        primarySwatch:
            Colors.grey, // Set the default colour of the app and text Styles
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: 1.1,
              fontSizeDelta: 2.0,
            ),
      ),
      home: const HomePage(title: 'Railway Explorer'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Initialize variables
  List<Tuple2<LatLng, bool>>? checkedLocations = [];
  int count = 1;
  int saveFreq = 30;
  bool railway = false;
  List<Railway> railways = [];
  bool offlineMode = false;
  List<int> toBeRemoved = [];

  // Function to get File Object for Saving
  Future<File?> getFile() async {
    Directory? appDocumentsDirectory = await getExternalStorageDirectory();
    if (appDocumentsDirectory == null) {
      return null;
    }
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/save.json';
    File file = File(filePath);
    if (!await file.exists()) {
      file.create();
    }
    return file;
  }

  // Function to save railways to file
  void save() async {
    File? file = await getFile();
    if (file == null) return;
    file.writeAsString(jsonEncode(railways));
  }

  // Function to load railways from file
  void read() async {
    File? file = await getFile();
    if (file == null) return;
    String contents = await file.readAsString();
    if (contents != "") {
      var decodedJson = jsonDecode(contents)
          .map((railway) => Railway.fromJson(railway))
          .toList();
      setState(() {
        railways = List<Railway>.from(decodedJson);
      });
    }
  }

  // Function to check if the user is near a railway,
  // if the user has moved more than 10m, it will check with the Overpass API
  Future<bool> nearRailway(LatLng location) async {
    LatLng roundedLocation = LatLng(
      double.parse(location.latitude.toStringAsFixed(4)),
      double.parse(location.longitude.toStringAsFixed(4)),
    );
    for (Tuple2<LatLng, bool> location in checkedLocations!) {
      if (location.item1 == roundedLocation) {
        return location.item2;
      }
    }
    List<Elements> response = await fetchElements(location);
    return response.isNotEmpty;
  }

  //Function to check permissions.
  void checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  // Fuction to load settings from shared preferences
  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveFreq = prefs.getInt('save') ?? saveFreq;
      var newOfflineMode = prefs.getBool('offlineMode') ?? offlineMode;
      if (newOfflineMode != offlineMode) {
        railway = false;
        offlineMode = newOfflineMode;
      }
    });
  }

  // Function to play tutorial
  void enableOfflineMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('offlineMode', true);
  }

  void advanceTutorial(TargetFocus target) {
    if (tutorialCoachMark == null) return;
    if (target.identify == "settingsButton") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Settings(),
        ),
      );
    } else if (target.identify == "offlineModeSwitch") {
      enableOfflineMode();
      Navigator.pop(context);
    } else if (target.identify == "floatingActionButton2") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Settings(),
        ),
      );
    } else if (target.identify == "phoneSettingsButton") {
      Navigator.pop(context);
    }
    tutorialCoachMark!.next();
  }

  void showTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var watchedIntro = prefs.getBool('watchedIntro') ?? false;
    if (!watchedIntro) {
      // ignore: use_build_context_synchronously
      // can't do this differently
      tutorialCoachMark = TutorialCoachMark(
        context,
        targets: targets, // List<TargetFocus>
        colorShadow: Colors.grey, // DEFAULT Colors.black
        onClickTarget: (target) {
          advanceTutorial(target);
        },
        onFinish: () {
          prefs.setBool('watchedIntro', true);
        },
      )..show();
    }
  }

  @override // Initialize the app and load settings and railways
  void initState() {
    super.initState();
    showTutorial();
    read();
    checkedLocations ??= [];
    initPlatformState();
    loadSettings();
  }

  // Function to satart tracking and set up location services
  // This also generates the notification to let the user know that the app is running
  Future<void> initPlatformState() async {
    await BackgroundLocation.setAndroidNotification(
      title: 'Railway Explorer',
      message:
          'Getting background location to update your personal railway map!',
    );
    await BackgroundLocation.setAndroidConfiguration(1000);
    await BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
      callback(location);
    });
  }

  // This function is called every time the user moves,
  // it checks if the user is near a railway and updates the map
  void callback(Location location) async {
    if (railway) {
      setState(() {
        railways.last.points
            .add(JsonLatLng(location.latitude!, location.longitude!));
      });
    }
    if (count % 5 == 0 && !offlineMode) {
      bool near =
          await nearRailway(LatLng(location.latitude!, location.longitude!));
      if (!railway && near) {
        setState(() {
          railways.add(Railway());
        });
      }
      railway = near;
      count = -1;
    }
    if (count % saveFreq == 0) {
      save();
    }
    count++;
  }

  @override // Build the app
  Widget build(BuildContext context) {
    loadSettings(); // Load settings every time the app is built
    checkPermissions(); // Check permissions every time the app is built
    setState(() {
      for (int index in toBeRemoved) {
        railways.removeAt(index);
      }
      toBeRemoved = [];
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            key: settingsButton,
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
          ),
        ],
      ),
      body: FlutterMap(
        // Add a map using Plugin Flutter Map
        options: MapOptions(
          plugins: [
            TappablePolylineMapPlugin(),
          ],
          center: LatLng(47.35185817238327, 7.907706238342396),
          zoom: 10,
        ),
        children: [
          TileLayerWidget(
            options: TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
              attributionBuilder: (_) {
                return const Text("© OpenStreetMap contributors");
              },
            ),
          ),
          LocationMarkerLayerWidget(),
          TappablePolylineLayerWidget(
            options: TappablePolylineLayerOptions(
              // Add tappable polylines using Plugin flutter map tappable polyline.
              polylines: railways.map((railway) {
                return TaggedPolyline(
                  points: railway.points
                      .map((e) => LatLng(e.lat, e.lng))
                      .toList(), // Make polylines from the points
                  strokeWidth: 5.0,
                  color: railway.color.toColor(),
                  tag: railways.indexOf(railway).toString(),
                );
              }).toList(),
              onTap: (polylines, tapPosition) {
                // When the user taps a polyline open a dialog with the railway details
                int index = int.parse(polylines[0].tag!);
                var avatarColor = railways[index].color.toColor();
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text("Edit railway journey"),
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                if (index >= railways.length) {
                                  return const Text("No railway selected");
                                }
                                return Column(
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: "Name",
                                      ),
                                      minLines: 1,
                                      maxLines: 1,
                                      initialValue: railways[index].name,
                                      onChanged: (value) {
                                        setState(
                                            () => railways[index].name = value);
                                      },
                                    ),
                                    TextFormField(
                                      minLines: 3,
                                      maxLines: 7,
                                      initialValue: railways[index].description,
                                      decoration: const InputDecoration(
                                        labelText: "Description",
                                      ),
                                      onChanged: (value) {
                                        setState(() => railways[index]
                                            .description = value);
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            DateFormat("mm:HH dd.MM.yyyy")
                                                .format(
                                                    railways[index].dateTime),
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        TextButton(
                                          child: const Text("Select date"),
                                          onPressed: () {
                                            showDatePicker(
                                              context: context,
                                              initialDate:
                                                  railways[index].dateTime,
                                              firstDate: railways[index]
                                                  .dateTime
                                                  .add(const Duration(
                                                      days: -365)),
                                              lastDate: railways[index]
                                                  .dateTime
                                                  .add(const Duration(
                                                      days: 365)),
                                            ).then((date) {
                                              if (date != null) {
                                                setState(() {
                                                  railways[index].dateTime =
                                                      date;
                                                });
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Change Color",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          GestureDetector(
                                            onTap: (() {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Pick a colour'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ColorPicker(
                                                        pickerColor:
                                                            railways[index]
                                                                .color
                                                                .toColor(),
                                                        onColorChanged:
                                                            (color) {
                                                          setState(() {
                                                            railways[index]
                                                                    .color =
                                                                JsonColor
                                                                    .fromColor(
                                                                        color);
                                                            avatarColor = color;
                                                          });
                                                        },
                                                        pickerAreaHeightPercent:
                                                            0.8,
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child:
                                                            const Text('Close'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }),
                                            child: CircleAvatar(
                                              backgroundColor: avatarColor,
                                              radius: 20,
                                            ),
                                          ),
                                        ]),
                                    TextButton(
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Are you sure you want to delete this journey?"),
                                              actions: [
                                                TextButton(
                                                  child: const Text("No"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text("Yes"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      if (index ==
                                                          railways.length) {
                                                        railways = [];
                                                      } else {
                                                        railways
                                                            .removeAt(index);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Close"),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                );
                              },
                            ))
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: floatingActionButtonKey,
        onPressed: () {
          if (offlineMode) {
            setState(() {
              if (!railway) {
                railways.add(Railway());
              }
              railway = !railway;
            });
          }
        },
        tooltip: 'Add railway',
        backgroundColor: (railway ? Colors.green : Colors.red),
        child:
            offlineMode ? Icon(!railway ? Icons.play_arrow : Icons.stop) : null,
      ),
    );
  }
}
