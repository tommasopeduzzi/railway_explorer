//Import nessecay libraries
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:railway_explorer/main.dart';
import 'package:railway_explorer/railway.dart';
import 'package:railway_explorer/state_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Edit extends StatefulWidget {
  final int index;
  const Edit(this.index, {Key? key}) : super(key: key);

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<RailwaysModel>(
        builder: (context, railways, child) {
          if (railways[widget.index] == null) {
            return Column(
              children: [],
            );
          }
          return Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Name",
                  ),
                  minLines: 1,
                  maxLines: 1,
                  initialValue: railways[widget.index].name,
                  onChanged: (value) {
                    railways.setName(widget.index, value);
                  },
                ),
                TextFormField(
                  minLines: 3,
                  maxLines: 7,
                  initialValue: railways[widget.index].description,
                  decoration: const InputDecoration(
                    labelText: "Description",
                  ),
                  onChanged: (value) {
                    railways.setDescription(widget.index, value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat("mm:HH dd.MM.yyyy").format(railways[widget.index].dateTime),
                        style: const TextStyle(color: Colors.grey)),
                    TextButton(
                      child: const Text("Select date"),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: railways[widget.index].dateTime,
                          firstDate: railways[widget.index].dateTime.add(const Duration(days: -365)),
                          lastDate: railways[widget.index].dateTime.add(const Duration(days: 365)),
                        ).then((date) {
                          if (date != null) {
                            railways.setDate(widget.index, date);
                          }
                        });
                      },
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text(
                    "Change Color",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: (() {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Pick a colour'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: railways[widget.index].color.toColor(),
                                onColorChanged: (color) {
                                  railways.setColor(widget.index, color);
                                },
                                pickerAreaHeightPercent: 0.8,
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }),
                    child: CircleAvatar(
                      backgroundColor: railways[widget.index].color.toColor(),
                      radius: 20,
                    ),
                  ),
                ]),
                TextButton(
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Are you sure you want to delete this journey?"),
                          actions: [
                            TextButton(
                              child: const Text("No"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: const Text("Yes"),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                if (Provider.of<AppStateModel>(context, listen: false).nearRailway &&
                                    widget.index == railways.railways.length - 1) {
                                  railways.add(Railway(JsonColor.fromColor(
                                      Provider.of<AppStateModel>(context, listen: false).railColour)));
                                }
                                railways.remove(widget.index);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                TextButton(
                  child: const Text("Close"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
