import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import '../../../controllers/routine_log_controller.dart';
import '../../../screens/exercise/history/home_screen.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/routine_utils.dart';
import '../preview/set_headers/single_set_header.dart';
import '../preview/set_headers/double_set_header.dart';

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

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final pastExerciseLogs =
        routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

    final pbs = calculatePBs(pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseType, exerciseLog: exerciseLog);

    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Theme(
            data: ThemeData(splashColor: sapphireLight),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => HomeScreen(exercise: exerciseLog.exercise)));
              },
              title: Text(exerciseLog.exercise.name,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center),
              subtitle: otherSuperSet != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text("with ${otherSuperSet.exercise.name}",
                          style: GoogleFonts.montserrat(color: vibrantGreen, fontSize: 12, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center),
                    )
                  : null,
            ),
          ),
          exerciseLog.notes.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Text(exerciseLog.notes,
                        style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.8), fontSize: 15)),
                  ),
                )
              : const SizedBox.shrink(),
          switch (exerciseType) {
            ExerciseType.weights => DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS'),
            ExerciseType.bodyWeight => const SingleSetHeader(label: 'REPS'),
            ExerciseType.duration => const SingleSetHeader(label: 'TIME'),
          },
          const SizedBox(height: 8),
          ...setsToWidgets(
              type: exerciseType,
              sets: exerciseLog.sets,
              pbs: previewType == RoutinePreviewType.log ? pbs : [],
              routinePreviewType: previewType),
        ],
      ),
    );
  }
}
