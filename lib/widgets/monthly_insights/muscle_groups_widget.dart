import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/empty_states/muscle_group_split_empty_state.dart';

import '../../dtos/routine_log_dto.dart';
import '../../utils/exercise_logs_utils.dart';
import '../chart/routine_muscle_group_split_chart.dart';

class MuscleGroupsWidget extends StatefulWidget {
  final List<RoutineLogDto> monthAndLogs;

  const MuscleGroupsWidget({super.key, required this.monthAndLogs});

  @override
  State<MuscleGroupsWidget> createState() => _MuscleGroupsWidgetState();
}

class _MuscleGroupsWidgetState extends State<MuscleGroupsWidget> {
  bool _minimized = true;

  @override
  Widget build(BuildContext context) {
    final exerciseLogs = widget.monthAndLogs
        .map((log) => exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs))
        .expand((exerciseLogs) => exerciseLogs)
        .toList();

    final muscleGroupFamilySplit = muscleGroupFrequency(exerciseLogs: exerciseLogs);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text("Muscle Groups Split".toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const Spacer(),
        GestureDetector(
            onTap: _onTap,
            child: FaIcon(_minimized ? FontAwesomeIcons.angleDown : FontAwesomeIcons.angleUp,
                color: Colors.white70, size: 16)),
      ]),
      const SizedBox(height: 10),
      exerciseLogs.isNotEmpty
          ? RoutineMuscleGroupSplitChart(frequencyData: muscleGroupFamilySplit, showInfo: false, minimized: _minimized)
          : const MuscleGroupSplitEmptyState()
    ]);
  }

  void _onTap() {
    setState(() {
      _minimized = !_minimized;
    });
  }
}
