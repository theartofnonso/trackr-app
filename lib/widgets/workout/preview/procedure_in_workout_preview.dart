import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';

class ProcedureInWorkoutPreview extends StatelessWidget {
  const ProcedureInWorkoutPreview({
    super.key,
    required this.index,
    required this.workingIndex,
    required this.exerciseInWorkoutDto,
    required this.procedureDto,
  });

  final int index;
  final int workingIndex;
  final SetDto procedureDto;
  final ExerciseInWorkoutDto exerciseInWorkoutDto;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
        backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
        leading: LeadingIcon(type: procedureDto.type, label: workingIndex),
        title: Text("${procedureDto.rep} Reps - ${procedureDto.weight}kg", style: Theme.of(context).textTheme.bodyMedium,));
  }
}

class LeadingIcon extends StatelessWidget {
  const LeadingIcon({
    super.key,
    required this.type,
    required this.label,
  });

  final SetType type;
  final int label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: type.color,
      child: Text(
        _generateLabel(),
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  String _generateLabel() {
    return type == SetType.working ? "${label + 1}" : type.label;
  }
}
