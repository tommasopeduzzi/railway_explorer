import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:railway_explorer/railway.dart';

part 'app_state.g.dart';

@JsonSerializable()
class AppState {
  int saveFrequency = 30;
  bool offlineMode = false;
  bool watchedTutorial = false;
  bool nearRailway = false;
  int railTolerance = 5;
  JsonColor railColour =
      JsonColor.fromColor(const Color.fromARGB(255, 76, 175, 175));

  AppState();

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  Map<String, dynamic> toJson() => _$AppStateToJson(this);
}
