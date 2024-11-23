import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise/set_type_enums.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';

import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/routine_utils.dart';
import '../../chips/squared_chips.dart';
import '../preview/set_headers/double_set_header.dart';
import '../preview/set_headers/single_set_header.dart';

class ExerciseLogWidget extends StatelessWidget {
  final ExerciseLogDTO exerciseLog;
  final ExerciseLogDTO? superSet;
  final RoutinePreviewType previewType;

  const ExerciseLogWidget({super.key, required this.exerciseLog, required this.superSet, required this.previewType});

  @override
  Widget build(BuildContext context) {
    final otherSuperSet = superSet;

    final setType = exerciseLog.exerciseVariant.getSetTypeConfiguration();

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final pastExerciseLogs = exerciseAndRoutineController.whereExerciseLogsBefore(
        exerciseVariant: exerciseLog.exerciseVariant, date: exerciseLog.createdAt);

    final pbs = calculatePBs(pastExerciseLogs: pastExerciseLogs, setType: setType, exerciseLog: exerciseLog);

    final exercise = exerciseAndRoutineController.whereExercise(id: exerciseLog.exerciseVariant.baseExerciseId);

    final configurationChips = exercise.configurationOptions.keys.where((configKey) {
      final configOptions = exercise.configurationOptions[configKey]!;
      return configOptions.length > 1;
    }).map((ExerciseConfigurationKey configKey) {
      final configValue = exerciseLog.exerciseVariant.configurations[configKey]!;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SquaredChips(
          label: configValue.displayName.toLowerCase(),
          color: vibrantGreen,
        ),
      );
    }).toList();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ExerciseHomeScreen(id: exerciseLog.exerciseVariant.baseExerciseId))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(exerciseLog.exerciseVariant.name,
              style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
          if (otherSuperSet != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text("with ${otherSuperSet.exerciseVariant.name}",
                  style: GoogleFonts.ubuntu(color: vibrantGreen, fontSize: 12, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ),
          if (exerciseLog.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Text(exerciseLog.notes,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                        fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent, // Makes the background transparent
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: sapphireLight, // Border color
                width: 1.0, // Border width
              ), // Adjust the radius as needed
            ),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: configurationChips)),
          ),
          switch (setType) {
            SetType.weightsAndReps => DoubleSetHeader(
                firstLabel: weightLabel().toUpperCase(),
                secondLabel: 'REPS',
                routinePreviewType: previewType,
              ),
            SetType.reps => SingleSetHeader(
                label: 'REPS',
                routinePreviewType: previewType,
              ),
            SetType.duration => SingleSetHeader(
                label: 'TIME',
                routinePreviewType: previewType,
              ),
          },
          const SizedBox(height: 8),
          ...setsToWidgets(
              setType: setType,
              sets: exerciseLog.sets,
              pbs: previewType == RoutinePreviewType.log ? pbs : [],
              routinePreviewType: previewType),
        ],
      ),
    );
  }
}
