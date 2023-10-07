import 'package:tracker_app/dtos/procedure_dto.dart';

class Workout {
  final String name;
  final List<ProcedureDto> procedures;
  final String? notes;
  final Duration? repsInterval;
  final Duration? setsInterval;

  Workout(this.name, this.procedures, this.notes, this.repsInterval, this.setsInterval);
}