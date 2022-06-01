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
  Color railColour = Color.fromARGB(255, 76, 175, 175);

  void storeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('offlineMode', offlineMode);
    prefs.setInt('railColour', railColour.value);
  }

  void loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      offlineMode = prefs.getBool('offlineMode') ?? false;
      railColour = Color(prefs.getInt('railColour') ?? 0xFF76B5B5);
    });
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

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
                  storeSettings();
                },
              ),
            ]),
            Divider(
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Railway colour', style: TextStyle(fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        storeSettings();
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
