import 'package:flutter/cupertino.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editor/routine_editor_screen.dart';

abstract class SetRow extends StatelessWidget {
  final int index;
  final String label;
  final String exerciseId;
  final SetDto setDto;
  final SetDto? pastSetDto;
  final RoutineEditorType editorType;  // Assuming EditorType is defined somewhere
  final VoidCallback onRemoved;
  final void Function() onCheck; // Assuming the signature of onCheck
  final void Function(SetType) onChangedType;

  const SetRow({
    Key? key,
    required this.index,
    required this.label,
    required this.exerciseId,
    required this.setDto,
    required this.pastSetDto,
    required this.editorType,
    required this.onRemoved,
    required this.onCheck,
    required this.onChangedType,
  }) : super(key: key);

// Define common methods here, if any.
}
