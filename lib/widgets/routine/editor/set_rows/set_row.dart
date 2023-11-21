import 'package:flutter/cupertino.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editors/routine_editor_screen.dart';

abstract class SetRow extends StatelessWidget {
  final int index;
  final String label;
  final String procedureId;
  final SetDto setDto;
  final SetDto? pastSetDto;
  final RoutineEditorType editorType; // Assuming EditorType is defined somewhere
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final void Function(SetType) onChangedType;

  const SetRow({
    Key? key,
    required this.index,
    required this.label,
    required this.procedureId,
    required this.setDto,
    required this.pastSetDto,
    required this.editorType,
    required this.onRemoved,
    required this.onChangedType,
    required this.onCheck,
  }) : super(key: key);

// Define common methods here, if any.
}
