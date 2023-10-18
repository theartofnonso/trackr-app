import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/workout/preview/procedure_in_workout_preview.dart';

import '../../../dtos/procedure_dto.dart';
import '../../../dtos/set_dto.dart';

class ExerciseInWorkoutPreview extends StatelessWidget {
  final ProcedureDto exerciseInWorkoutDto;
  final ProcedureDto? superSetExerciseInWorkoutDto;

  const ExerciseInWorkoutPreview({super.key, required this.exerciseInWorkoutDto, this.superSetExerciseInWorkoutDto});

  List<ProcedureInWorkoutPreview>? _displayProcedures() {
    final workingProcedures = [];

    return exerciseInWorkoutDto.sets.mapIndexed(((index, procedure) {
      final item = ProcedureInWorkoutPreview(
          index: index,
          workingIndex: procedure.type == SetType.working ? workingProcedures.length : -1,
          exerciseInWorkoutDto: exerciseInWorkoutDto,
          procedureDto: procedure);

      if (procedure.type == SetType.working) {
        workingProcedures.add(procedure);
      }

      return item;
    })).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      margin: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoListTile(
            padding: EdgeInsets.zero,
            title: Text(exerciseInWorkoutDto.exercise.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: exerciseInWorkoutDto.isSuperSet
                ? Text("Super set: ${superSetExerciseInWorkoutDto?.exercise.name}",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
                : const SizedBox.shrink(),
          ),
          exerciseInWorkoutDto.notes.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(exerciseInWorkoutDto.notes,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: CupertinoColors.white.withOpacity(0.8), fontSize: 15)),
              )
              : const SizedBox.shrink(),
        ],
      ),
      children: [
        ...?_displayProcedures(),
      ],
    );
  }
}
