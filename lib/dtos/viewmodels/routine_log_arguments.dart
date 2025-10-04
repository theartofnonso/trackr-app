import 'package:tracker_app/dtos/db/routine_log_dto.dart';

import '../../enums/routine_editor_type_enums.dart';

class RoutineLogArguments {
  final RoutineLogDto log;
  final RoutineEditorMode editorMode;
  final bool cached;

  RoutineLogArguments(
      {required this.log, required this.editorMode, this.cached = false});
}
