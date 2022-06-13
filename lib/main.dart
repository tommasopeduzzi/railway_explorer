import 'dart:convert';
import 'dart:io';

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

import 'api.dart';
import 'settings.dart';
import 'railway.dart';

void main() {
  runApp(const MyApp());
}

GlobalKey floatingActionButtonKey = GlobalKey();
GlobalKey settingsButton = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Railway Explorer',
      theme: ThemeData(
        primarySwatch: Colors.grey,
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
  List<Tuple2<LatLng, bool>>? checkedLocations = [];
  int count = 1;
  int saveFreq = 30;
  bool railway = false, watchedIntro = false;
  List<Railway> railways = [];
  bool offlineMode = false;
  Color railColour = Colors.red;

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

  void save() async {
    File? file = await getFile();
    if (file == null) return;
    file.writeAsString(jsonEncode(railways));
  }

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

  void checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saveFreq = prefs.getInt('save') ?? saveFreq;
      railway = prefs.getBool('railway') ?? railway;
      var newOfflineMode = prefs.getBool('offlineMode') ?? offlineMode;
      if (newOfflineMode != offlineMode) {
        railway = false;
        offlineMode = newOfflineMode;
      }
      railColour = Color(prefs.getInt('railColour') ?? railColour.value);
      watchedIntro = prefs.getBool("watchedIntro") ?? watchedIntro;
    });
  }

  void showTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!watchedIntro) {
      TutorialCoachMark(
        context,
        targets: [
          TargetFocus(
            keyTarget: floatingActionButtonKey,
            alignSkip: Alignment.topRight,
            contents: [
              TargetContent(
                align: ContentAlign.top,
                child: const Text(
                  '''While not in offline mode, this app will automatically track your location (also in the background if enabled in the permission settings) and draw lines on while you are near a railway. You can see whether you are near a railway here:''',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          TargetFocus(
            alignSkip: Alignment.bottomRight,
            keyTarget: settingsButton,
            contents: [
              TargetContent(
                align: ContentAlign.bottom,
                child: const Text(
                  'Tap here to open settings: Here you can control different aspects of the app. One of them is offline mode: With offline mode, the app will not make any network requests. You can use the button below to toggle whether you are near a railway while in offline mode. While not, the app will use openstreetmap data to determine whether you are near a railway.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ], // List<TargetFocus>
        colorShadow: Colors.grey, // DEFAULT Colors.black
      ).show();
      await prefs.setBool('watchedIntro', true);
    }
  }

  @override
  void initState() {
    super.initState();
    showTutorial();
    read();
    checkedLocations ??= [];
    initPlatformState();
    loadSettings();
  }

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
          railways.add(Railway(JsonColor.fromColor(railColour)));
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

  @override
  Widget build(BuildContext context) {
    loadSettings();
    checkPermissions();
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
        options: MapOptions(
          plugins: [
            TappablePolylineMapPlugin(),
          ],
          center: LatLng(47.547484, 7.589800),
          zoom: 13.0,
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
              polylines: railways.map((railway) {
                return TaggedPolyline(
                  points:
                      railway.points.map((e) => LatLng(e.lat, e.lng)).toList(),
                  strokeWidth: 5.0,
                  color: railway.color == null
                      ? railColour
                      : Color.fromARGB(255, railway.color!.r, railway.color!.g,
                          railway.color!.b),
                  tag: railways.indexOf(railway).toString(),
                );
              }).toList(),
              onTap: (polylines, tapPosition) {
                int index = int.parse(polylines[0].tag!);
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text("Edit railway journey"),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Name",
                                ),
                                minLines: 1,
                                maxLines: 1,
                                initialValue: railways[index].name,
                                onChanged: (value) {
                                  setState(() => railways[index].name = value);
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
                                  setState(() =>
                                      railways[index].description = value);
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      DateFormat("mm:HH dd.MM.yyyy")
                                          .format(railways[index].dateTime),
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  TextButton(
                                    child: const Text("Select date"),
                                    onPressed: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: railways[index].dateTime,
                                        firstDate: railways[index]
                                            .dateTime
                                            .add(const Duration(days: -365)),
                                        lastDate: railways[index]
                                            .dateTime
                                            .add(const Duration(days: 365)),
                                      ).then((date) {
                                        if (date != null) {
                                          setState(() {
                                            railways[index].dateTime = date;
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
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    GestureDetector(
                                      onTap: (() {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Pick a colour'),
                                              content: SingleChildScrollView(
                                                child: ColorPicker(
                                                  pickerColor: railways[index]
                                                      .color!
                                                      .toColor(),
                                                  onColorChanged: (color) {
                                                    setState(() {
                                                      railways[index].color =
                                                          JsonColor.fromColor(
                                                              color);
                                                    });
                                                  },
                                                  pickerAreaHeightPercent: 0.8,
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Close'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }),
                                      child: CircleAvatar(
                                        backgroundColor:
                                            railways[index].color!.toColor(),
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
                                              setState(() {
                                                railways.removeAt(index);
                                              });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
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
                          ),
                        )
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
                railways.add(Railway(JsonColor.fromColor(railColour)));
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
