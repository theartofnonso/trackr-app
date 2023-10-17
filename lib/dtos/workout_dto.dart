import 'package:tracker_app/dtos/procedure_dto.dart';

class WorkoutDto {
  final String id;
  final String name;
  final List<ProcedureDto> exercises;
  final String notes;
  final Duration? setsInterval;

  WorkoutDto({required this.id, required this.name, required this.exercises, this.notes = "", this.setsInterval});
}