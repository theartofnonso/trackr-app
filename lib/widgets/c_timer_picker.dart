import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'buttons/text_button_widget.dart';

class CustomTimerPicker extends StatefulWidget {
  final void Function(Duration duration) onSelect;
  final void Function() turnOffReminder;

  const CustomTimerPicker({super.key, required this.turnOffReminder, required this.onSelect});

  @override
  State<CustomTimerPicker> createState() => _CustomTimerPickerState();
}

class _CustomTimerPickerState extends State<CustomTimerPicker> {
  int _hours = 0;
  int _minutes = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Minutes Picker
                Expanded(
                  child: CupertinoPicker(
                    looping: true,
                    itemExtent: 38.0,
                    onSelectedItemChanged: (int index) {
                      _hours = index;
                    },
                    children: List<Widget>.generate(23, (int index) {
                      return Center(child: Text(index.toString().padLeft(2, "0")));
                    }),
                  ),
                ),
                // Seconds Picker
                Expanded(
                  child: CupertinoPicker(
                    looping: true,
                    itemExtent: 38.0,
                    onSelectedItemChanged: (int index) {
                      _minutes = index;
                    },
                    children: List<Widget>.generate(60, (int index) {
                      return Center(child: Text(index.toString().padLeft(2, "0")));
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            CTextButton(
                onPressed: widget.turnOffReminder, label: "Turn off reminder", padding: const EdgeInsets.all(10.0)),
            const SizedBox(width: 10),
            CTextButton(
                onPressed: () {
                  widget.onSelect( Duration(hours: _hours, minutes: _minutes));
                },
                label: "Remind me",
                buttonColor: Colors.green,
                padding: const EdgeInsets.all(10.0))
          ]),
        ],
      ),
    );
  }
}
