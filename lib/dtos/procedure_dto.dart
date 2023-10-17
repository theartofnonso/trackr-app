
import 'package:tracker_app/dtos/set_dto.dart';

import 'exercise_dto.dart';

class ProcedureDto {

  String superSetId;
  final ExerciseDto exercise;
  String notes;
  List<SetDto> sets = [];
  bool isSuperSet;
  Duration? procedureDuration;

  ProcedureDto({this.superSetId = "", this.notes = "", required this.exercise, this.isSuperSet = false});

  @override
  String toString() {
    return 'ProcedureDto{superSetId: $superSetId, exercise: $exercise, notes: $notes, sets: $sets, isSuperSet: $isSuperSet}';
  }
}
