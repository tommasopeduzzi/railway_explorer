import 'package:latlong2/latlong.dart';
import 'package:json_annotation/json_annotation.dart';

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

@JsonSerializable()
class Railway {
  List<JsonLatLng> points = [];

  Railway();

  factory Railway.fromJson(Map<String, dynamic> json) =>
      _$RailwayFromJson(json);

  Map<String, dynamic> toJson() => _$RailwayToJson(this);
}
