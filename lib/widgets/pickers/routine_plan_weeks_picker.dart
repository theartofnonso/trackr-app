import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../enums/routine_plan_weeks.dart';
import '../buttons/opacity_button_widget.dart';

class RoutinePlanWeeksPicker extends StatefulWidget {
  final RoutinePlanWeeks? weeks;
  final void Function(RoutinePlanWeeks goal) onSelect;

  const RoutinePlanWeeksPicker({super.key, this.weeks, required this.onSelect});

  @override
  State<RoutinePlanWeeksPicker> createState() => _RoutinePlanWeeksPickerState();
}

class _RoutinePlanWeeksPickerState extends State<RoutinePlanWeeksPicker> {
  RoutinePlanWeeks _weeks = RoutinePlanWeeks.four;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final weeks = RoutinePlanWeeks.values;

    final children = RoutinePlanWeeks.values
        .map((value) => Center(
            child: Text("${value.weeks} weeks",
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 24, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              _weeks = weeks[index];
            },
            squeeze: 1,
            selectionOverlay: Container(color: Colors.transparent),
            children: children,
          ),
        ),
        const SizedBox(height: 16),
        OpacityButtonWidget(
            onPressed: () {
              widget.onSelect(_weeks);
            },
            label: "Train for ${_weeks.weeks} weeks",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = RoutinePlanWeeks.values.indexOf(widget.weeks ?? RoutinePlanWeeks.four);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
