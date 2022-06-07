// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'railway.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonLatLng _$JsonLatLngFromJson(Map<String, dynamic> json) => JsonLatLng(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$JsonLatLngToJson(JsonLatLng instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

Railway _$RailwayFromJson(Map<String, dynamic> json) => Railway()
  ..points = (json['points'] as List<dynamic>)
      .map((e) => JsonLatLng.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$RailwayToJson(Railway instance) => <String, dynamic>{
      'points': instance.points,
    };
