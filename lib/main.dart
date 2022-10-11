// import nessecary packages
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:background_location/background_location.dart';
import 'package:railway_explorer/state_model.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:provider/provider.dart';
// import necessary files
import 'settings.dart';
import 'railway.dart';
import 'tutorial.dart';
import 'overpass.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RailwaysModel()),
        ChangeNotifierProvider(create: (context) => AppStateModel()),
      ],
      child: const MyApp(),
    ),
  );
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
  int count = 1;

  //Function to check permissions and request them if necessary.
  void checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  // Function to advance the tutorial and open/close different pages at different times
  void advanceTutorial(TargetFocus target) {
    if (tutorialCoachMark == null) return;
    if (target.identify == "settingsButton") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Settings(),
        ),
      );
    } else if (target.identify == "offlineModeSwitch") {
      Provider.of<AppStateModel>(context, listen: false).setNearRailway(true);
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

  void showTutorial() {
    var watchedIntro =
        Provider.of<AppStateModel>(context, listen: false).watchedTutorial;
    if (!watchedIntro) {
      tutorialCoachMark = TutorialCoachMark(
        context,
        targets: targets, // List<TargetFocus>
        colorShadow: Colors.grey, // DEFAULT Colors.black
        onClickTarget: (target) {
          advanceTutorial(target);
        },
        onFinish: () {
          Provider.of<AppStateModel>(context, listen: false)
              .setWatchedTutorial(true);
        },
      )..show();
    }
  }

  @override // Initialize the app, show tutorial on the first start and load settings and railways from the save file
  void initState() {
    super.initState();
    showTutorial();
    initPlatformState();
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

  Future<List<Elements>> fetchElements(LatLng location) async {
    final coordStr =
        "${location.latitude.toString()},${location.longitude.toString()}";
    final tolerance =
        Provider.of<AppStateModel>(context, listen: false).railTolerance;
    try {
      final response = await http.get(Uri.parse(
          'https://overpass.kumi.systems/api/interpreter?data=[out:json];(node["railway"="rail"](around:$tolerance,$coordStr);way["railway"="rail"](around:$tolerance,$coordStr);node["railway"="tram"](around:$tolerance,$coordStr);way["railway"="tram"](around:$tolerance,$coordStr););out geom;'));
      if (response.statusCode == 200 || response.statusCode == 203) {
        // If the server did return a 200 OK response or a 203 Non-Authoritative Information response,
        // then parse the JSON.
        return Response.fromJson(jsonDecode(response.body)).elements!;
      } else {
        // If the server did not return a 200 OK response or a 203 Non-Authoritative Information response,
        // then throw an exception.
        throw Exception('HTTP Error ${response.statusCode}.');
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> checkIfLocationNearRailway(LatLng location) async {
    List<Elements> response = await fetchElements(location);
    return response.isNotEmpty;
  }

  // This function is called every time the app receives a location update (if the user moves approximately every second),
  // it checks if the user is near a railway and if so it adds it to the list of railways, so that it gets rendered on the map.
  void callback(Location location) async {
    var appStateProvider = Provider.of<AppStateModel>(context, listen: false);
    var railwayStateProvider =
        Provider.of<RailwaysModel>(context, listen: false);

    if (appStateProvider.nearRailway) {
      railwayStateProvider.addNewLocationToLastRailway(
          JsonLatLng(location.latitude!, location.longitude!));
    }
    if (count > 0 && count % 5 == 0 && !appStateProvider.offlineMode) {
      bool near = await checkIfLocationNearRailway(
          LatLng(location.latitude!, location.longitude!));
      if (!appStateProvider.nearRailway && near) {
        railwayStateProvider
            .add(Railway(JsonColor.fromColor(appStateProvider.railColour)));
      }
      appStateProvider.setNearRailway(near);
    }
    if (count >= appStateProvider.saveFrequency) {
      railwayStateProvider.saveAsJson();
      appStateProvider.saveAsJson();
      count = 0;
    } else {
      count++;
    }
  }

  @override // Build the app
  Widget build(BuildContext context) {
    checkPermissions(); // Check permissions every time the app is built
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
          Consumer<RailwaysModel>(
            builder: (context, railwayModel, child) {
              var railways = railwayModel.railways;
              return TappablePolylineLayerWidget(
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
                  // onTap: (polylines, tapPosition) {
                  //   // When the user taps a polyline open a dialog with the railway details
                  //   int index = int.parse(polylines[0].tag!);
                  //   var avatarColor = railways[index].color.toColor();
                  //   showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return SimpleDialog(
                  //         title: const Text("Edit railway journey"),
                  //         children: [
                  //           Container(
                  //             padding: const EdgeInsets.all(10),
                  //             child: StatefulBuilder(
                  //               builder: (context, setState) {
                  //                 if (index >= railways.length) {
                  //                   return const Text("No railway selected");
                  //                 }
                  //                 return Column(
                  //                   children: [
                  //                     TextFormField(
                  //                       decoration: const InputDecoration(
                  //                         labelText: "Name",
                  //                       ),
                  //                       minLines: 1,
                  //                       maxLines: 1,
                  //                       initialValue: railways[index].name,
                  //                       onChanged: (value) {
                  //                         setState(() =>
                  //                             railways[index].name = value);
                  //                       },
                  //                     ),
                  //                     TextFormField(
                  //                       minLines: 3,
                  //                       maxLines: 7,
                  //                       initialValue:
                  //                           railways[index].description,
                  //                       decoration: const InputDecoration(
                  //                         labelText: "Description",
                  //                       ),
                  //                       onChanged: (value) {
                  //                         setState(() => railways[index]
                  //                             .description = value);
                  //                       },
                  //                     ),
                  //                     Row(
                  //                       mainAxisAlignment:
                  //                           MainAxisAlignment.spaceBetween,
                  //                       children: [
                  //                         Text(
                  //                             DateFormat("mm:HH dd.MM.yyyy")
                  //                                 .format(
                  //                                     railways[index].dateTime),
                  //                             style: const TextStyle(
                  //                                 color: Colors.grey)),
                  //                         TextButton(
                  //                           child: const Text("Select date"),
                  //                           onPressed: () {
                  //                             showDatePicker(
                  //                               context: context,
                  //                               initialDate:
                  //                                   railways[index].dateTime,
                  //                               firstDate: railways[index]
                  //                                   .dateTime
                  //                                   .add(const Duration(
                  //                                       days: -365)),
                  //                               lastDate: railways[index]
                  //                                   .dateTime
                  //                                   .add(const Duration(
                  //                                       days: 365)),
                  //                             ).then((date) {
                  //                               if (date != null) {
                  //                                 setState(() {
                  //                                   railways[index].dateTime =
                  //                                       date;
                  //                                 });
                  //                               }
                  //                             });
                  //                           },
                  //                         ),
                  //                       ],
                  //                     ),
                  //                     Row(
                  //                         mainAxisAlignment:
                  //                             MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           const Text(
                  //                             "Change Color",
                  //                             style:
                  //                                 TextStyle(color: Colors.grey),
                  //                           ),
                  //                           GestureDetector(
                  //                             onTap: (() {
                  //                               showDialog(
                  //                                 context: context,
                  //                                 builder: (context) {
                  //                                   return AlertDialog(
                  //                                     title: const Text(
                  //                                         'Pick a colour'),
                  //                                     content:
                  //                                         SingleChildScrollView(
                  //                                       child: ColorPicker(
                  //                                         pickerColor:
                  //                                             railways[index]
                  //                                                 .color
                  //                                                 .toColor(),
                  //                                         onColorChanged:
                  //                                             (color) {
                  //                                           setState(() {
                  //                                             railways[index]
                  //                                                     .color =
                  //                                                 JsonColor
                  //                                                     .fromColor(
                  //                                                         color);
                  //                                             avatarColor =
                  //                                                 color;
                  //                                           });
                  //                                         },
                  //                                         pickerAreaHeightPercent:
                  //                                             0.8,
                  //                                       ),
                  //                                     ),
                  //                                     actions: <Widget>[
                  //                                       TextButton(
                  //                                         child: const Text(
                  //                                             'Close'),
                  //                                         onPressed: () {
                  //                                           Navigator.of(
                  //                                                   context)
                  //                                               .pop();
                  //                                         },
                  //                                       ),
                  //                                     ],
                  //                                   );
                  //                                 },
                  //                               );
                  //                             }),
                  //                             child: CircleAvatar(
                  //                               backgroundColor: avatarColor,
                  //                               radius: 20,
                  //                             ),
                  //                           ),
                  //                         ]),
                  //                     TextButton(
                  //                       child: const Text("Delete",
                  //                           style:
                  //                               TextStyle(color: Colors.red)),
                  //                       onPressed: () {
                  //                         showDialog(
                  //                           context: context,
                  //                           builder: (context) {
                  //                             return AlertDialog(
                  //                               title: const Text(
                  //                                   "Are you sure you want to delete this journey?"),
                  //                               actions: [
                  //                                 TextButton(
                  //                                   child: const Text("No"),
                  //                                   onPressed: () {
                  //                                     Navigator.pop(context);
                  //                                   },
                  //                                 ),
                  //                                 TextButton(
                  //                                   child: const Text("Yes"),
                  //                                   onPressed: () {
                  //                                     Navigator.pop(context);
                  //                                     Navigator.pop(context);
                  //                                     setState(() {
                  //                                       railways
                  //                                           .removeAt(index);
                  //                                       if (railway) {
                  //                                         railways
                  //                                             .add(Railway());
                  //                                       }
                  //                                     });
                  //                                   },
                  //                                 ),
                  //                               ],
                  //                             );
                  //                           },
                  //                         );
                  //                       },
                  //                     ),
                  //                     TextButton(
                  //                       child: const Text("Close"),
                  //                       onPressed: () => Navigator.pop(context),
                  //                     )
                  //                   ],
                  //                 );
                  //               },
                  //             ),
                  //           )
                  //         ],
                  //       );
                  //     },
                  //   );
                  // },
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: Consumer<AppStateModel>(
        builder: (context, appState, child) {
          return FloatingActionButton(
            key: floatingActionButtonKey,
            onPressed: () {
              if (appState.offlineMode) {
                setState(() {
                  if (!appState.nearRailway) {
                    Provider.of<RailwaysModel>(context, listen: false).add(
                      Railway(
                        JsonColor.fromColor(appState.railColour),
                      ),
                    );
                  }
                  appState.setNearRailway(!appState.nearRailway);
                });
              }
            },
            tooltip: 'Add railway',
            backgroundColor: (appState.nearRailway ? Colors.green : Colors.red),
            child: appState.offlineMode
                ? Icon(!appState.nearRailway ? Icons.play_arrow : Icons.stop)
                : null,
          );
        },
      ),
    );
  }
}
