import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:background_location/background_location.dart';

import 'api.dart';

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
  List<LatLng>? checkedLocations;
  int count = 0;
  bool railway = false;

  Future<bool> nearRailway(LatLng location) async {
    if (checkedLocations!.contains(LatLng(
      double.parse(location.latitude.toStringAsFixed(4)),
      double.parse(location.longitude.toStringAsFixed(4)),
    ))) {
      return false;
    }
    checkedLocations!.add(location);
    Elements elements = await fetchElements(location);
    return elements.type == "way";
  }

  void checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  ReceivePort receivePort = ReceivePort();
  @override
  void initState() {
    super.initState();
    checkedLocations ??= <LatLng>[];
    initPlatformState();
    startLocationService();
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
      print("got location");
      callback(location);
    });
  }

  void callback(Location location) async {
    if (railway == true) {
      print(" !!! near railway");
      print(location.latitude);
      print(location.longitude);
      print(location.speed);
      print(location.altitude);
      print(location.accuracy);
      print(location.time);
    }
    if (count % 5 == 0) {
      railway =
          await nearRailway(LatLng(location.latitude!, location.longitude!));
      count = -1;
    }
    count++;
  }

//Optional
  static void notificationCallback() {
    print('User clicked on the notification');
  }

  void startLocationService() {}

  @override
  Widget build(BuildContext context) {
    checkPermissions();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              print("pressed settings button");
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
              polylines: [
                new Polyline(
                    points: checkedLocations!,
                    strokeWidth: 2.0,
                    color: Colors.red)
              ],
            ),
          ),
          LocationMarkerLayerWidget(),
        ],
      ),
    );
  }
}
