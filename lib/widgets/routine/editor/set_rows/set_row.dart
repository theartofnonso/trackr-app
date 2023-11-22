import 'package:flutter/cupertino.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../screens/editors/routine_editor_screen.dart';

abstract class SetRow extends StatelessWidget {
  final int index;
  final int setTypeIndex;
  final String procedureId;
  final SetDto setDto;
  final SetDto? pastSetDto;
  final RoutineEditorMode editorType;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;
  final void Function(SetType type) onChangedType;
  final void Function(SetDto setDto) onUpdateSetWithPastSet;

  const SetRow({
    Key? key,
    required this.index,
    required this.setTypeIndex,
    required this.procedureId,
    required this.setDto,
    required this.pastSetDto,
    required this.editorType,
    required this.onRemoved,
    required this.onChangedType,
    required this.onCheck,
    required this.onUpdateSetWithPastSet,
  }) : super(key: key);

// Define common methods here, if any.
}
