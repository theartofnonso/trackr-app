import 'package:tracker_app/dtos/routine_log_dto.dart';

import '../../enums/routine_editor_type_enums.dart';

class RoutineLogArguments {
  final RoutineLogDto log;
  final RoutineEditorMode editorMode;
  final bool emptySession;

  RoutineLogArguments({required this.log, required this.editorMode, this.emptySession = false});
}