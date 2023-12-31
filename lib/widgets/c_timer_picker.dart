import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'buttons/text_button_widget.dart';

class CustomTimerPicker extends StatefulWidget {
  final Duration initialDuration;
  final void Function(Duration duration) onSelect;

  const CustomTimerPicker({super.key, required this.initialDuration, required this.onSelect});

  @override
  State<CustomTimerPicker> createState() => _CustomTimerPickerState();
}

class _CustomTimerPickerState extends State<CustomTimerPicker> {
  int _hours = 0;
  int _minutes = 0;

  FixedExtentScrollController? _hoursScrollController;
  FixedExtentScrollController? _minutesScrollController;

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
                    scrollController: _hoursScrollController,
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
                    scrollController: _minutesScrollController,
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
          Center(
              child: CTextButton(
                  onPressed: () {
                    widget.onSelect(Duration(hours: _hours, minutes: _minutes));
                  },
                  label: "Remind me",
                  buttonColor: Colors.green,
                  padding: const EdgeInsets.all(10.0)))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDuration.inHours;
    _minutes = widget.initialDuration.inMinutes;
    _hoursScrollController = FixedExtentScrollController(initialItem: _hours);
    _minutesScrollController = FixedExtentScrollController(initialItem: _minutes);
  }
}
