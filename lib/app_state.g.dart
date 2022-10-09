// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) => AppState()
  ..saveFrequency = json['saveFrequency'] as int
  ..offlineMode = json['offlineMode'] as bool
  ..watchedTutorial = json['watchedTutorial'] as bool
  ..railTolerance = json['railTolerance'] as int
  ..railColour = JsonColor.fromJson(json['railColour'] as Map<String, dynamic>);

Map<String, dynamic> _$AppStateToJson(AppState instance) => <String, dynamic>{
      'saveFrequency': instance.saveFrequency,
      'offlineMode': instance.offlineMode,
      'watchedTutorial': instance.watchedTutorial,
      'railTolerance': instance.railTolerance,
      'railColour': instance.railColour,
    };
