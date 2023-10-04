import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/dtos/super_set_dto.dart';

class Workout {
  final String name;
  final List<Procedure> procedures;
  final SuperSet? superSet;
  final String? notes;
  final Duration? repsInterval;
  final Duration? setsInterval;

  Workout(this.name, this.procedures, this.superSet, this.notes, this.repsInterval, this.setsInterval);
}