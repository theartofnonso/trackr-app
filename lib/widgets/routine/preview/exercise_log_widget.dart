import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';

import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/routine_utils.dart';
import '../preview/set_headers/double_set_header.dart';
import '../preview/set_headers/single_set_header.dart';

class ExerciseLogWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;
  final ExerciseLogDto? superSet;
  final EdgeInsetsGeometry? padding;
  final RoutinePreviewType previewType;

  const ExerciseLogWidget(
      {super.key, required this.exerciseLog, required this.superSet, this.padding, required this.previewType});

  @override
  Widget build(BuildContext context) {
    final otherSuperSet = superSet;

    final exerciseType = exerciseLog.exercise.type;

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final pastExerciseLogs =
        routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

    final pbs = calculatePBs(pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseType, exerciseLog: exerciseLog);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ExerciseHomeScreen(exercise: exerciseLog.exercise)));
          },
          title: Text(exerciseLog.exercise.name,
              style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
          subtitle: otherSuperSet != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text("with ${otherSuperSet.exercise.name}",
                      style: GoogleFonts.ubuntu(color: vibrantGreen, fontSize: 12, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                )
              : null,
        ),
        exerciseLog.notes.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Center(
                  child: Text(exerciseLog.notes,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                          fontSize: 14,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600)),
                ),
              )
            : const SizedBox.shrink(),
        switch (exerciseType) {
          ExerciseType.weights => DoubleSetHeader(
              firstLabel: weightLabel().toUpperCase(),
              secondLabel: 'REPS',
              routinePreviewType: previewType,
            ),
          ExerciseType.bodyWeight => SingleSetHeader(
              label: 'REPS',
              routinePreviewType: previewType,
            ),
          ExerciseType.duration => SingleSetHeader(
              label: 'TIME',
              routinePreviewType: previewType,
            ),
          ExerciseType.all => throw Exception("Unable to return Set header for type ExerciseType.all"),
        },
        const SizedBox(height: 8),
        ...setsToWidgets(
            type: exerciseType,
            sets: exerciseLog.sets,
            pbs: previewType == RoutinePreviewType.log ? pbs : [],
            routinePreviewType: previewType),
      ],
    );
  }
}
