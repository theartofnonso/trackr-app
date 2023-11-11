import 'package:flutter/material.dart';

import '../../../../../dtos/set_dto.dart';
import '../../../../../screens/editor/routine_editor_screen.dart';

abstract class SetWidget extends StatelessWidget {
  const SetWidget({
    super.key,
    required this.index,
    required this.workingIndex,
    required this.setDto,
    required this.pastSetDto,
    this.editorType = RoutineEditorType.edit,
    required this.onTapCheck,
    required this.onRemoved,
    this.onChangedReps,
    this.onChangedWeight,
    this.onChangedType,
    this.onChangedDuration,
    this.onChangedDistance,
  });

  final int index;
  final int workingIndex;
  final SetDto setDto;
  final SetDto? pastSetDto;
  final RoutineEditorType editorType;
  final void Function() onTapCheck;
  final void Function() onRemoved;
  final void Function(int value)? onChangedReps;
  final void Function(double value)? onChangedWeight;
  final void Function(SetType type)? onChangedType;
  final void Function(Duration duration)? onChangedDuration;
  final void Function(int distance)? onChangedDistance;
}
