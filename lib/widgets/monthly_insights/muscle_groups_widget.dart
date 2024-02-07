import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/empty_states/muscle_group_split_empty_state.dart';

import '../../dtos/routine_log_dto.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
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

    final muscleGroupFamilySplit = scaledMuscleGroupFrequencyAcrossSessions(exerciseLogs: exerciseLogs);

    final muscleGroupFamilies = muscleGroupFamilySplit.keys;

    final untrainedMuscleGroups =
        popularMuscleGroupFamilies().where((family) => !muscleGroupFamilies.contains(family)).toList();

    final untrainedMuscleGroupsMessage = untrainedMuscleGroups.length < popularMuscleGroupFamilies().length
        ? "${untrainedMuscleGroups.take(untrainedMuscleGroups.length - 1).map((muscle) => muscle.name).join(", ")} and ${untrainedMuscleGroups.last.name}"
        : "any muscle groups";

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text("Muscle Groups Frequency".toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (muscleGroupFamilySplit.length > 3)
          GestureDetector(
              onTap: _onTap,
              child: FaIcon(_minimized ? FontAwesomeIcons.angleDown : FontAwesomeIcons.angleUp,
                  color: Colors.white70, size: 16)),
      ]),
      const SizedBox(height: 10),
      Text(
          "Train a variety of muscle groups to avoid muscle imbalances and prevent injury. On average each muscle group should be trained at least 2 times a week.",
          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      exerciseLogs.isNotEmpty
          ? RoutineMuscleGroupSplitChart(frequencyData: muscleGroupFamilySplit, minimized: _minimized)
          : const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: MuscleGroupSplitEmptyState(),
            ),
      if (untrainedMuscleGroups.isNotEmpty)
        RichText(
            text: TextSpan(
                text: "You haven't trained",
                style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                children: [
              const TextSpan(text: " "),
              TextSpan(
                  text: untrainedMuscleGroupsMessage,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))
            ]))
    ]);
  }

  void _onTap() {
    setState(() {
      _minimized = !_minimized;
    });
  }
}
