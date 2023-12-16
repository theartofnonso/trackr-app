import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../enums/exercise_type_enums.dart';
import '../../utils/general_utils.dart';
import '../helper_widgets/routine_helper.dart';
import '../routine/preview/set_headers/double_set_header.dart';
import '../routine/preview/set_headers/single_set_header.dart';

class RoutineLogWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;

  const RoutineLogWidget({
    super.key,
    required this.exerciseLog,
  });

  @override
  Widget build(BuildContext context) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);
    final routineLog = routineLogProvider.whereRoutineLog(id: exerciseLog.routineLogId)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(splashColor: tealBlueLight),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(routineLog.name, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Row(children: [
              const Icon(
                Icons.date_range_rounded,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 1),
              Text(exerciseLog.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear(),
                  style: GoogleFonts.lato(
                      color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
            ]),
          ),
        ),
        _ProcedureWidget(exerciseLog: exerciseLog)
      ],
    );
  }
}

class _ProcedureWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;

  const _ProcedureWidget({required this.exerciseLog});

  @override
  Widget build(BuildContext context) {

    final exerciseString = exerciseLog.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseString);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        exerciseLog.notes.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(exerciseLog.notes,
              style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8), fontSize: 15)),
        )
            : const SizedBox.shrink(),
        switch (exerciseType) {
          ExerciseType.weightAndReps => DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS',),
          ExerciseType.weightedBodyWeight => DoubleSetHeader(firstLabel: "+${weightLabel().toUpperCase()}", secondLabel: 'REPS',),
          ExerciseType.assistedBodyWeight => DoubleSetHeader(firstLabel: '-${weightLabel().toUpperCase()}', secondLabel: 'REPS',),
          ExerciseType.weightAndDistance => DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: distanceTitle(type: ExerciseType.weightAndDistance)),
          ExerciseType.bodyWeightAndReps => const SingleSetHeader(label: 'REPS'),
          ExerciseType.duration => const SingleSetHeader(label: 'TIME'),
          ExerciseType.durationAndDistance => DoubleSetHeader(firstLabel: 'TIME', secondLabel: distanceTitle(type: ExerciseType.durationAndDistance)),
        },
        const SizedBox(height: 8),
        ...setsToWidgets(type: ExerciseType.fromString(exerciseLog.exercise.type), sets: exerciseLog.sets),
      ],
    );
  }
}
