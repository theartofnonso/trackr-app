import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../enums/routine_plan_sessions.dart';
import '../buttons/opacity_button_widget.dart';

class RoutinePlanSessionsPicker extends StatefulWidget {
  final RoutinePlanSessions? sessions;
  final void Function(RoutinePlanSessions goal) onSelect;

  const RoutinePlanSessionsPicker({super.key, this.sessions, required this.onSelect});

  @override
  State<RoutinePlanSessionsPicker> createState() => _RoutinePlanSessionsPickerState();
}

class _RoutinePlanSessionsPickerState extends State<RoutinePlanSessionsPicker> {
  RoutinePlanSessions _weeklySessions = RoutinePlanSessions.two;

  FixedExtentScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    final sessions = RoutinePlanSessions.values;

    final children = RoutinePlanSessions.values
        .map((session) => Center(
            child: Text("${session.frequency} days per week",
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
              _weeklySessions = sessions[index];
            },
            squeeze: 1,
            selectionOverlay: Container(color: Colors.transparent),
            children: children,
          ),
        ),
        const SizedBox(height: 16),
        OpacityButtonWidget(
            onPressed: () {
              widget.onSelect(_weeklySessions);
            },
            label: "Train ${_weeklySessions.frequency} days per week",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = RoutinePlanSessions.values.indexOf(widget.sessions ?? RoutinePlanSessions.two);
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
