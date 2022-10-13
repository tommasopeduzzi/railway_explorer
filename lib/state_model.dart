import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:railway_explorer/railway.dart';

import 'app_state.dart';

class JsonState extends ChangeNotifier {
  JsonState() {
    fromJsonFile();
  }

  void fromJsonFile() {}
  void saveAsJson() {}

  Future<File> _getFile(String fileName) async {
    Directory? appDocumentsDirectory = await getExternalStorageDirectory();
    if (appDocumentsDirectory == null) {
      throw Exception("Can't get external storage directory");
    }
    String appDocumentsPath = appDocumentsDirectory.path;
    String path = '$appDocumentsPath/$fileName';
    File file = File(path);
    if (!await file.exists()) {
      file.create();
    }
    return file;
  }

  Future<String> _readJsonFile(String filename) async {
    File file = await _getFile(filename);
    if (!await file.exists()) {
      file.create();
    }
    return await file.readAsString();
  }
}

class RailwaysModel extends JsonState {
  List<Railway> _railways = [];

  UnmodifiableListView<Railway> get railways => UnmodifiableListView(_railways);
  operator [](index) {
    if (index < 0 || index >= _railways.length) return null;
    return _railways[index];
  }

  @override
  void fromJsonFile() async {
    String data = await _readJsonFile("save.json");
    if (data == "") return;
    _railways = jsonDecode(data).map<Railway>((railway) => Railway.fromJson(railway)).toList();
    notifyListeners();
  }

  @override
  void saveAsJson() {
    _getFile("save.json").then((file) {
      var string = jsonEncode(_railways);
      file.writeAsString(string);
    });
  }

  void update(List<Railway> railways) {
    _railways = railways;
    notifyListeners();
  }

  void add(Railway railway) {
    _railways.add(railway);
    notifyListeners();
  }

  void remove(int index) {
    _railways.removeAt(index);
    notifyListeners();
  }

  void addNewLocationToLastRailway(JsonLatLng location) {
    railways.last.points.add(location);
    notifyListeners();
  }

  void setDescription(int index, String value) {
    _railways[index].description = value;
    notifyListeners();
  }

  void setDate(int index, DateTime date) {
    _railways[index].dateTime = date;
    notifyListeners();
  }

  void setName(int index, String value) {
    _railways[index].name = value;
    notifyListeners();
  }

  void setColor(int index, Color color) {
    _railways[index].color = JsonColor.fromColor(color);
    notifyListeners();
  }
}

class AppStateModel extends JsonState {
  AppState appState = AppState();

  int get saveFrequency => appState.saveFrequency;
  bool get offlineMode => appState.offlineMode;
  bool get watchedTutorial => appState.watchedTutorial;
  bool get nearRailway => appState.nearRailway;
  int get railTolerance => appState.railTolerance;
  Color get railColour => appState.railColour.toColor();

  @override
  void fromJsonFile() async {
    String data = await _readJsonFile("config.json");
    if (data == "") return;
    var decodedJson = jsonDecode(data);

    appState = AppState.fromJson(decodedJson);

    notifyListeners();
  }

  @override
  void saveAsJson() {
    _getFile("config.json").then((file) {
      var string = jsonEncode(appState);
      file.writeAsString(string);
    });
  }

  void setSaveFrequency(int saveFrequency) {
    appState.saveFrequency = saveFrequency;
    notifyListeners();
  }

  void setOfflineMode(bool offlineMode) {
    appState.offlineMode = offlineMode;
    notifyListeners();
  }

  void setRailTolerance(int railTolerance) {
    appState.railTolerance = railTolerance;
    notifyListeners();
  }

  void setRailColour(Color railColour) {
    appState.railColour = JsonColor.fromColor(railColour);
    notifyListeners();
  }

  void setWatchedTutorial(bool watchedTutorial) {
    appState.watchedTutorial = watchedTutorial;
    notifyListeners();
  }

  void setNearRailway(bool nearRailway) {
    appState.nearRailway = nearRailway;
    notifyListeners();
  }
}
