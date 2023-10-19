
import 'dart:convert';

import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/dtos/routine_dto.dart';

import '../models/RoutineLog.dart';

extension RoutineLogExtension on RoutineLog {
  RoutineLogDto toRoutineLogDto(BuildContext context) {
    final procedureDtos =
    procedures.map((procedureJson) => ProcedureDto.fromJson(json.decode(procedureJson), context)).toList();

    return RoutineLogDto(
        id: id,
        name: name,
        notes: notes,
        procedures: procedureDtos,
        startTime: startTime.getDateTimeInUtc(),
        endTime: endTime.getDateTimeInUtc(),
        createdAt: createdAt.getDateTimeInUtc(),
        updatedAt: updatedAt.getDateTimeInUtc());
  }
}

extension RoutineLogDtoExtension on RoutineLogDto {

  RoutineLog toRoutineLog() {
    final procedureJsons = procedures.map((procedure) => procedure.toJson()).toList();
    return RoutineLog(
        id: id,
        name: name,
        notes: notes,
        procedures: procedureJsons,
        startTime: TemporalDateTime.fromString("${startTime?.toIso8601String()}Z"),
        endTime: TemporalDateTime.fromString("${endTime?.toIso8601String()}Z"),
        createdAt: TemporalDateTime.fromString("${createdAt.toLocal().toIso8601String()}Z"),
        updatedAt: TemporalDateTime.fromString("${updatedAt.toIso8601String()}Z"));
  }
}

class RoutineLogDto extends RoutineDto {

  RoutineLogDto({required super.id, required super.name, super.notes = "", required super.procedures, required DateTime super.startTime, required DateTime super.endTime, required super.createdAt, required super.updatedAt});

  @override
  RoutineLogDto copyWith(
      {String? id,
      String? name,
      String? notes,
      List<ProcedureDto>? procedures,
      DateTime? startTime,
      DateTime? endTime,
      DateTime? createdAt,
      DateTime? updatedAt}) {
    return RoutineLogDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      procedures: procedures ?? this.procedures,
      startTime: startTime ?? this.startTime!,
      endTime: endTime ?? this.endTime!,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
