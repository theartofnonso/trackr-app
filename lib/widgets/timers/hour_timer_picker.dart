import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../buttons/text_button_widget.dart';

class HourTimerPicker extends StatefulWidget {
  final Duration initialDuration;
  final void Function(Duration duration) onSelect;

  const HourTimerPicker({super.key, required this.initialDuration, required this.onSelect});

  @override
  State<HourTimerPicker> createState() => _HourTimerPickerState();
}

class _HourTimerPickerState extends State<HourTimerPicker> {
  int _hours = 0;

  FixedExtentScrollController? _hoursScrollController;

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
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
              child: CTextButton(
                  onPressed: () {
                    widget.onSelect(Duration(hours: _hours));
                  },
                  label: "Remind me at this hour",
                  buttonColor: vibrantGreen,
                  textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
                  padding: const EdgeInsets.all(10.0)))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _hoursScrollController = FixedExtentScrollController(initialItem: widget.initialDuration.inHours);
  }

  @override
  void dispose() {
    _hoursScrollController?.dispose();
    super.dispose();
  }
}
