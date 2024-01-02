import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/widgets/exercise_history/set_record_widget.dart';

import '../../dtos/exercise_dto.dart';
import '../../providers/routine_log_provider.dart';

class PersonalBestWidget extends StatelessWidget {
  final ExerciseDto exercise;

  const PersonalBestWidget({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    List<ExerciseLogDto> pastLogs =
        Provider.of<RoutineLogProvider>(context, listen: false).exerciseLogsById[exercise.id] ?? [];

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Personal Best achievements for this exercise",
              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          SetRecordWidget(exerciseType: exercise.type, sets: pastLogs.expand((log) => log.sets).toList()),
        ],
      ),
    );
  }
}
