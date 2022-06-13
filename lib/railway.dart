import 'package:latlong2/latlong.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';
part 'railway.g.dart';

@JsonSerializable()
class JsonLatLng {
  final double lat;
  final double lng;

  JsonLatLng(this.lat, this.lng);

  factory JsonLatLng.fromJson(Map<String, dynamic> json) =>
      _$JsonLatLngFromJson(json);

  Map<String, dynamic> toJson() => _$JsonLatLngToJson(this);
}

DateFormat dateFormat = DateFormat('dd-MM-yyy');
DateFormat timeFormat = DateFormat('HH:mm');

@JsonSerializable()
class Railway {
  List<JsonLatLng> points = [];
  String name = "";
  String description = "";
  DateTime dateTime = DateTime.now();

  Railway() {
    this.name = "Railway journey on the " +
        dateFormat.format(DateTime.now()) +
        ' at ' +
        timeFormat.format(DateTime.now());
    this.description = "";
    this.dateTime = DateTime.now();
  }

  factory Railway.fromJson(Map<String, dynamic> json) =>
      _$RailwayFromJson(json);

  Map<String, dynamic> toJson() => _$RailwayToJson(this);
}
