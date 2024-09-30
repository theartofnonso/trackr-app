import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';

import '../buttons/opacity_button_widget.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CupertinoPicker(
            scrollController: _hoursScrollController,
            looping: true,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              _hours = index;
            },
            squeeze: 1,
            children: List<Widget>.generate(23, (int index) {
              return Center(child: Text(index.toString().padLeft(2, "0"), style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 32, color: Colors.white)));
            }),
          ),
        ),
        const SizedBox(height: 10),
        OpacityButtonWidget(
            onPressed: () {
              widget.onSelect(Duration(hours: _hours));
            },
            label: "Remind me at this hour",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
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
