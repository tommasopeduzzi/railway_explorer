import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:permission_handler/permission_handler.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int frequency = 30;
  int railTolerance = 5;
  bool offlineMode = false;
  Color railColour = const Color.fromARGB(255, 76, 175, 175);

  void storeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('offlineMode', offlineMode);
    prefs.setInt('railColour', railColour.value);
    prefs.setInt('tolerance', railTolerance);
    prefs.setInt('save', frequency);
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      offlineMode = prefs.getBool('offlineMode') ?? false;
      railColour = Color(prefs.getInt('railColour') ?? 0xFF76B5B5);
      railTolerance = prefs.getInt('tolerance') ?? 5;
      frequency = prefs.getInt('save') ?? 30;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Offline mode', style: TextStyle(fontSize: 20)),
              Switch(
                value: offlineMode,
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    offlineMode = value;
                  });
                  storeSettings();
                },
              ),
            ]),
            const Divider(
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Railway colour', style: TextStyle(fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (() {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Pick a colour'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: railColour,
                                  onColorChanged: (color) {
                                    setState(() {
                                      railColour = color;
                                    });
                                    storeSettings();
                                  },
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }),
                      child: CircleAvatar(
                        backgroundColor: railColour,
                        radius: 20,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const Divider(
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rail Tolerance', style: TextStyle(fontSize: 20)),
                SizedBox(
                  width: 150,
                  child: Center(
                    child: Transform.scale(
                      scale: 0.7,
                      child: NumberPicker(
                        haptics: true,
                        minValue: 0,
                        maxValue: 5000,
                        itemWidth: 50,
                        step: 5,
                        value: railTolerance,
                        axis: Axis.horizontal,
                        onChanged: (railTolerance) {
                          setState(
                            () {
                              this.railTolerance = railTolerance;
                            },
                          );
                          storeSettings();
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
            const Divider(
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Save Frequency', style: TextStyle(fontSize: 20)),
                SizedBox(
                    width: 150,
                    child: Center(
                      child: Transform.scale(
                        scale: 0.7,
                        child: NumberPicker(
                          haptics: true,
                          minValue: 0,
                          maxValue: 5000,
                          itemWidth: 50,
                          step: 1,
                          value: frequency,
                          axis: Axis.horizontal,
                          onChanged: (frequency) {
                            setState(
                              () {
                                this.frequency = frequency;
                              },
                            );
                            storeSettings();
                          },
                        ),
                      ),
                    ))
              ],
            ),
            const Divider(
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Open Settings", style: TextStyle(fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
