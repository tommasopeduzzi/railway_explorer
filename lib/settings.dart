//Import nessecay libraries
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:permission_handler/permission_handler.dart';

//class for the settings page
class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

//Initialize variables
class _SettingsState extends State<Settings> {
  int frequency = 30;
  int railTolerance = 5;
  bool offlineMode = false;
  Color railColour = const Color.fromARGB(255, 76, 175, 175);

  //Function to store stettings to shared preferences
  void storeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('offlineMode', offlineMode);
    prefs.setInt('railColour', railColour.value);
    prefs.setInt('tolerance', railTolerance);
    prefs.setInt('save', frequency);
  }

//Function to get settings from shared preferences
  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      offlineMode = prefs.getBool('offlineMode') ?? false;
      railColour = Color(prefs.getInt('railColour') ?? 0xFF76B5B5);
      railTolerance = prefs.getInt('tolerance') ?? 5;
      frequency = prefs.getInt('save') ?? 30;
    });
  }

  //Call function to load settings in innitState to display current settings
  @override
  void initState() {
    super.initState();
    loadSettings();
  }

//Build the settings page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          //All setting rows are in this column
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              //Row for offline mode
              const Text('Offline mode', style: TextStyle(fontSize: 20)),
              Switch(
                value: offlineMode,
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    offlineMode = value;
                  });
                  storeSettings(); //Store settings when offline mode is changed
                },
              ),
            ]),
            const Divider(
              //Divider between offline mode and rail colour
              color: Colors.black,
            ),
            Row(
              //Row for rail colour
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
                                  //Color picker with Package flutter_colorpicker
                                  pickerColor: railColour,
                                  onColorChanged: (color) {
                                    setState(() {
                                      railColour = color;
                                    });
                                    storeSettings(); //Store settings when colour is changed
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
              //Divider between rail colour and rail tolerance
              color: Colors.black,
            ),
            Row(
              //Row for rail tolerance setting
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rail Tolerance', style: TextStyle(fontSize: 20)),
                SizedBox(
                  width: 150,
                  child: Center(
                    child: Transform.scale(
                      scale: 0.7,
                      child: NumberPicker(
                        //Number picker with Package numberpicker
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
                          storeSettings(); //Store settings when rail tolerance is changed
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
            const Divider(
              //Divider between rail tolerance and save frequency
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
                          //Number picker with Package numberpicker
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
                            storeSettings(); //Store settings when save frequency is changed
                          },
                        ),
                      ),
                    ))
              ],
            ),
            const Divider(
              //Divider between save frequency and open app settings
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Open Settings", style: TextStyle(fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    openAppSettings(); //Open app settings when pressed
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
