import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:background_location/background_location.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'api.dart';
import 'settings.dart';
import 'railway.dart';

void main() {
  runApp(const MyApp());
}

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
  bool railway = false;
  List<Railway> railways = [];
  bool offlineMode = false;
  Color railColour = Colors.red;

  Future<File> getFile() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/save.json';
    File file = File(filePath);
    if (!await file.exists()) {
      file.create();
    }
    return file;
  }

  void save() async {
    File file = await getFile();
    file.writeAsString(jsonEncode(railways));
  }

  void read() async {
    File file = await getFile();
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
      railway = prefs.getBool('railway') ?? railway;
      var newOfflineMode = prefs.getBool('offlineMode') ?? offlineMode;
      if (newOfflineMode != offlineMode) {
        railway = false;
        offlineMode = newOfflineMode;
      }
      railColour = Color(prefs.getInt('railColour') ?? railColour.value);
    });
  }

  @override
  void initState() {
    super.initState();
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
          railways.add(Railway());
        });
      }
      railway = near;
      count = -1;
    } else if (offlineMode && !railway) {
      setState(() {
        railway = true;
        railways.add(Railway());
      });
    }
    if (count % 5 == 0) {
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
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(47.547484, 7.589800),
          zoom: 13.0,
        ),
        children: [
          TileLayerWidget(
            options: TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
              attributionBuilder: (_) {
                return Text("© OpenStreetMap contributors");
              },
            ),
          ),
          PolylineLayerWidget(
            options: PolylineLayerOptions(
              polylines: railways.map((railway) {
                return Polyline(
                  points:
                      railway.points.map((e) => LatLng(e.lat, e.lng)).toList(),
                  strokeWidth: 5.0,
                  color: railColour,
                );
              }).toList(),
            ),
          ),
          LocationMarkerLayerWidget(),
        ],
      ),
    );
  }
}
