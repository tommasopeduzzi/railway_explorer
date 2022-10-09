//Import nessecay libraries
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:railway_explorer/state_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:permission_handler/permission_handler.dart';

//class for the settings page
import 'tutorial.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

//Initialize variables
class _SettingsState extends State<Settings> {
//Build the settings page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Consumer<AppStateModel>(
          builder: (context, state, child) => Column(
            //All setting rows are in this column
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                //Row for offline mode
                const Text('Offline mode', style: TextStyle(fontSize: 20)),
                Switch(
                  key: offlineModeSwitch,
                  value: state.offlineMode,
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    state.setOfflineMode(value);
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
                        key: railColourPicker,
                        onTap: (() {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Pick a colour'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    //Color picker with Package flutter_colorpicker
                                    pickerColor: state.railColour,
                                    onColorChanged: (colour) {
                                      state.setRailColour(colour);
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
                          backgroundColor: state.railColour,
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
                          key: railTolerancePicker,
                          haptics: true,
                          minValue: 0,
                          maxValue: 5000,
                          itemWidth: 50,
                          step: 5,
                          value: state.railTolerance,
                          axis: Axis.horizontal,
                          onChanged: (railTolerance) {
                            state.setRailTolerance(railTolerance);
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
                            key: frequencyPicker,
                            haptics: true,
                            minValue: 0,
                            maxValue: 5000,
                            itemWidth: 50,
                            step: 1,
                            value: state.saveFrequency,
                            axis: Axis.horizontal,
                            onChanged: (frequency) {
                              state.setSaveFrequency(frequency);
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
                    key: phoneSettingsButton,
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      openAppSettings(); //Open app settings when pressed
                    },
                  ),
                ],
              ),
              const Divider(
                //Divider between save frequency and open app settings
                color: Colors.black,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Reset Tutorial", style: TextStyle(fontSize: 20)),
                  IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () {
                      state.setOfflineMode(true);
                      state.setWatchedTutorial(false);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
