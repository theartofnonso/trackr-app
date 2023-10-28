import 'dart:convert';

import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/models/ModelProvider.dart';

extension RoutineExtension on Routine {
  RoutineDto toRoutineDto(BuildContext context) {
    final procedureDtos = procedures.map((procedureJson) => ProcedureDto.fromJson(json.decode(procedureJson), context)).toList();
    return RoutineDto(
        id: id,
        name: name,
        notes: notes,
        procedures: procedureDtos,
        updatedAt: updatedAt.getDateTimeInUtc(), createdAt: createdAt.getDateTimeInUtc());
  }
}

extension RoutineDtoExtension on RoutineDto {
  Routine toRoutine() {
    final procedureJsons = procedures.map((procedure) => procedure.toJson()).toList();
    return Routine(
        id: id,
        name: name,
        notes: notes,
        procedures: procedureJsons,
        updatedAt: TemporalDateTime.fromString("${updatedAt.toLocal().toIso8601String()}Z"),
        createdAt: TemporalDateTime.fromString("${createdAt.toLocal().toIso8601String()}Z"));
  }

  RoutineLogDto toRoutineLog() {
    return RoutineLogDto(
        id: id,
        name: name,
        notes: notes,
        procedures: procedures,
        startTime: startTime!,
        endTime: endTime!,
        updatedAt: updatedAt,
        createdAt: createdAt);
  }
}

class RoutineDto {
  final String id;
  final String name;
  final String notes;
  final List<ProcedureDto> procedures;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineDto({
    required this.id,
    required this.name,
    this.notes = "",
    required this.procedures,
    this.startTime,
    this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  RoutineDto copyWith(
      {String? id,
      String? name,
      String? notes,
      List<ProcedureDto>? procedures,
      DateTime? startTime,
      DateTime? endTime,
      DateTime? createdAt,
      DateTime? updatedAt}) {
    return RoutineDto(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      procedures: procedures ?? this.procedures,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RoutineDto{id: $id, name: $name, notes: $notes, procedures: $procedures, startTime: $startTime, endTime: $endTime, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
