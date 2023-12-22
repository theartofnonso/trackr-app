import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import '../../../screens/exercise/history/home_screen.dart';
import '../../../utils/general_utils.dart';
import '../../helper_widgets/routine_helper.dart';
import '../preview/set_headers/single_set_header.dart';
import '../preview/set_headers/double_set_header.dart';

class ExerciseLogWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;
  final ExerciseLogDto? superSet;
  final EdgeInsetsGeometry? padding;

  const ExerciseLogWidget({super.key, required this.exerciseLog, required this.superSet, this.padding});

  @override
  Widget build(BuildContext context) {
    final otherSuperSet = superSet;

    final exerciseString = exerciseLog.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseString);

    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Theme(
            data: ThemeData(splashColor: tealBlueLight),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => HomeScreen(exercise: exerciseLog.exercise)));
              },
              title: Text(exerciseLog.exercise.name, style: GoogleFonts.lato(color: Colors.white, fontSize: 14)),
              subtitle: otherSuperSet != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text("with ${otherSuperSet.exercise.name}",
                          style: GoogleFonts.lato(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                    )
                  : null,
            ),
          ),
          exerciseLog.notes.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(exerciseLog.notes,
                      style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontSize: 15)),
                )
              : const SizedBox.shrink(),
          switch (exerciseType) {
            ExerciseType.weightAndReps => DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS'),
            ExerciseType.weightedBodyWeight =>
              DoubleSetHeader(firstLabel: "+${weightLabel().toUpperCase()}", secondLabel: 'REPS'),
            ExerciseType.assistedBodyWeight =>
              DoubleSetHeader(firstLabel: '-${weightLabel().toUpperCase()}', secondLabel: 'REPS'),
            ExerciseType.weightAndDistance => DoubleSetHeader(
                firstLabel: weightLabel().toUpperCase(),
                secondLabel: distanceTitle(type: ExerciseType.weightAndDistance)),
            ExerciseType.bodyWeightAndReps => const SingleSetHeader(label: 'REPS'),
            ExerciseType.duration => const SingleSetHeader(label: 'TIME'),
            ExerciseType.durationAndDistance =>
              DoubleSetHeader(firstLabel: 'TIME', secondLabel: distanceTitle(type: ExerciseType.durationAndDistance)),
          },
          const SizedBox(height: 8),
          ...setsToWidgets(type: ExerciseType.fromString(exerciseLog.exercise.type), sets: exerciseLog.sets),
        ],
      ),
    );
  }
}
