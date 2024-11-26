import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/list_view_empty_state.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../enums/exercise_type_enums.dart';
import '../../utils/general_utils.dart';
import '../routine/preview/set_headers/double_set_header.dart';
import '../routine/preview/set_headers/single_set_header.dart';
import '../routine/preview/sets_listview.dart';

class ExerciseHistoryLogWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;

  const ExerciseHistoryLogWidget({
    super.key,
    required this.exerciseLog,
  });

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    final routineLog = routineLogController.logWhereId(id: exerciseLog.routineLogId ?? "");

    if (routineLog == null) {
      return const ListViewEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(splashColor: sapphireLight),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(routineLog.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center),
            subtitle: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(
                Icons.date_range_rounded,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 1),
              Text(exerciseLog.createdAt.formattedDayAndMonthAndYear(),
                  style: GoogleFonts.ubuntu(
                      color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
        _ExerciseLogWidget(exerciseLog: exerciseLog)
      ],
    );
  }
}

class _ExerciseLogWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;

  const _ExerciseLogWidget({required this.exerciseLog});

  @override
  Widget build(BuildContext context) {
    final exerciseType = exerciseLog.exercise.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        exerciseLog.notes.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(exerciseLog.notes,
                    style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8), fontSize: 15)),
              )
            : const SizedBox.shrink(),
        switch (exerciseType) {
          ExerciseType.weights => DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS'),
          ExerciseType.bodyWeight => const SingleSetHeader(label: 'REPS'),
          ExerciseType.duration => const SingleSetHeader(label: 'TIME'),
          ExerciseType.all => throw Exception("Unable to return Set header for type ExerciseType.all"),
        },
        const SizedBox(height: 8),
        SetsListview(type: exerciseType, sets: exerciseLog.sets, pbs: [])
      ],
    );
  }
}
