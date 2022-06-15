// Import nessecay libraries
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import auto-generated response classes
import 'overpass.dart';

// Function to request data from server
Future<List<Elements>> fetchElements(LatLng location) async {
  final coordStr =
      "${location.latitude.toString()},${location.longitude.toString()}";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int minDist = prefs.getInt('tolerance') ?? 5;
  final response = await http.get(Uri.parse(
      'https://overpass.kumi.systems/api/interpreter?data=[out:json];(node["railway"="rail"](around:$minDist,$coordStr);way["railway"="rail"](around:$minDist,$coordStr);node["railway"="tram"](around:$minDist,$coordStr);way["railway"="tram"](around:$minDist,$coordStr););out geom;'));

  if (response.statusCode == 200 || response.statusCode == 203) {
    // If the server did return a 200 OK response or a 203 Non-Authoritative Information response,
    // then parse the JSON.
    return Response.fromJson(jsonDecode(response.body)).elements!;
  } else {
    // If the server did not return a 200 OK response or a 203 Non-Authoritative Information response,
    // then throw an exception.
    throw Exception(
      // This is a very funny error message.
      'C\'est l\'erreur d\'api numéro ${response.statusCode}. Please visit http.cat/${response.statusCode} for further information.',
    );
  }
}
