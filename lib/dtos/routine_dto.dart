import 'package:tracker_app/dtos/procedure_dto.dart';

class RoutineDto {
  final String id;
  final String name;
  final List<ProcedureDto> procedures;
  final String notes;

  RoutineDto(
      {required this.id,
      required this.name,
      required this.procedures,
      this.notes = ""});
}
