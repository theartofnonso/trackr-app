import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/empty_states/muscle_group_split_empty_state.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../utils/exercise_logs_utils.dart';
import '../chart/routine_muscle_group_split_chart.dart';

class MuscleGroupsWidget extends StatelessWidget {
  final List<ExerciseLogDto> exerciseLogs;

  const MuscleGroupsWidget({super.key, required this.exerciseLogs});

  @override
  Widget build(BuildContext context) {
    final muscleGroupFamilySplit = muscleGroupFrequency(exerciseLogs: exerciseLogs);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Muscle Groups Split".toUpperCase(),
          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      exerciseLogs.isNotEmpty ? RoutineMuscleGroupSplitChart(frequencyData: muscleGroupFamilySplit, showInfo: false) : const MuscleGroupSplitEmptyState()
    ]);
  }
}
