import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../enums/routine_plan_goal.dart';
import '../buttons/opacity_button_widget.dart';

class RoutinePlanGoalPicker extends StatefulWidget {
  final RoutinePlanGoal? goal;
  final void Function(RoutinePlanGoal goal) onSelect;

  const RoutinePlanGoalPicker({super.key, this.goal, required this.onSelect});

  @override
  State<RoutinePlanGoalPicker> createState() => _RoutinePlanGoalPickerState();
}

class _RoutinePlanGoalPickerState extends State<RoutinePlanGoalPicker> {
  RoutinePlanGoal _goal = RoutinePlanGoal.muscle;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final goals = RoutinePlanGoal.values;

    final children = RoutinePlanGoal.values
        .map((goal) => Center(
            child: Text(goal.description,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 28, color: Colors.white))))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              _goal = goals[index];
            },
            squeeze: 1,
            selectionOverlay: Container(color: Colors.transparent),
            children: children,
          ),
        ),
        const SizedBox(height: 16),
        OpacityButtonWidget(
            onPressed: () {
              widget.onSelect(_goal);
            },
            label: "Select Goal",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = RoutinePlanGoal.values.indexOf(widget.goal ?? RoutinePlanGoal.muscle);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
