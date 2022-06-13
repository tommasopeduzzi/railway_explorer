import 'package:flutter/material.dart';
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

@JsonSerializable()
class JsonColor {
  int r, g, b;
  JsonColor(this.r, this.g, this.b);

  factory JsonColor.fromJson(Map<String, dynamic> json) =>
      _$JsonColorFromJson(json);

  Map<String, dynamic> toJson() => _$JsonColorToJson(this);

  Color toColor() => Color.fromARGB(255, r, g, b);

  JsonColor.fromColor(Color color)
      : r = color.red,
        g = color.green,
        b = color.blue;
}

DateFormat dateFormat = DateFormat('dd-MM-yyy');
DateFormat timeFormat = DateFormat('HH:mm');

@JsonSerializable()
class Railway {
  List<JsonLatLng> points = [];
  String name = "";
  String description = "";
  DateTime dateTime = DateTime.now();
  JsonColor? color;

  Railway(this.color) {
    name =
        "Railway journey on the ${dateFormat.format(DateTime.now())} at ${timeFormat.format(DateTime.now())}";
    description = "";
    dateTime = DateTime.now();
  }

  factory Railway.fromJson(Map<String, dynamic> json) =>
      _$RailwayFromJson(json);

  Map<String, dynamic> toJson() => _$RailwayToJson(this);
}
