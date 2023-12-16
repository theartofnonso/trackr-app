import 'package:flutter/cupertino.dart';

import '../../../../dtos/set_dto.dart';
import '../../../../enums/routine_editor_type_enums.dart';

abstract class SetRow extends StatelessWidget {
  final SetDto setDto;
  final RoutineEditorMode editorType;
  final VoidCallback onRemoved;
  final VoidCallback onCheck;

  const SetRow({
    Key? key,
    required this.setDto,
    required this.editorType,
    required this.onRemoved,
    required this.onCheck,
  }) : super(key: key);
}
