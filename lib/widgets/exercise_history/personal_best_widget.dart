import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/models/Exercise.dart';
import 'package:tracker_app/widgets/exercise_history/set_record_widget.dart';

import '../../enums/exercise_type_enums.dart';
import '../../providers/routine_log_provider.dart';

class PersonalBestWidget extends StatelessWidget {
  final Exercise exercise;

  const PersonalBestWidget({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    List<ExerciseLogDto> pastLogs =
        Provider.of<RoutineLogProvider>(context, listen: false).exerciseLogsById[exercise.id] ?? [];

    final exerciseString = exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseString);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Personal Bests achievements for this exercise",
              style: GoogleFonts.lato(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 16),
          SetRecordWidget(exerciseType: exerciseType, sets: pastLogs.expand((log) => log.sets).toList()),
        ],
      ),
    );
  }
}