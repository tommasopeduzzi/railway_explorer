import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

// Create state
class _SettingsState extends State<Settings> {
  bool offlineMode = false;
  Color railColour = Colors.green;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Offline mode', style: TextStyle(fontSize: 20)),
              Switch(
                value: offlineMode,
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    offlineMode = value;
                  });
                },
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Railway colour', style: TextStyle(fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: GestureDetector(
                        child: CircleAvatar(
                          backgroundColor: railColour,
                          radius: 20,
                        ),
                        onTap: (() {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Pick a colour'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: railColour,
                                      onColorChanged: (color) {
                                        setState(() {
                                          railColour = color;
                                        });
                                      },
                                      pickerAreaHeightPercent: 0.8,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
