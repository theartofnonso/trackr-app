import 'dart:convert';

import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';

class RecoveryLogDto {
  final String id;

  final Map<MuscleGroupFamily, int> muscleGroupFamily;

  final String owner;

  final DateTime createdAt;

  final DateTime updatedAt;

  RecoveryLogDto({
    required this.id,
    required this.muscleGroupFamily,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecoveryLogDto.toDto(RecoveryLog log) {
    return RecoveryLogDto.fromLog(log);
  }

  factory RecoveryLogDto.fromLog(RecoveryLog log) {
    final dataJson = jsonDecode(log.data);
    final mgfMap = (dataJson["muscleGroupFamily"] ?? {}) as Map<String, dynamic>;
    final muscleGroupFamily = mgfMap.map((key, value) {
      return MapEntry(MuscleGroupFamily.fromString(key), value as int);
    });

    return RecoveryLogDto(
      id: log.id,
      muscleGroupFamily: muscleGroupFamily,
      createdAt: log.createdAt.getDateTimeInUtc(),
      updatedAt: log.updatedAt.getDateTimeInUtc(),
      owner: log.owner ?? "",
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'muscleGroupFamily': muscleGroupFamily.map((mgf, value) {
        return MapEntry(mgf.name, value);
      }),
    };
  }

  RecoveryLogDto copyWith({
    String? id,
    Map<MuscleGroupFamily, int>? muscleGroupFamily,
    String? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecoveryLogDto(
      id: id ?? this.id,
      muscleGroupFamily: muscleGroupFamily ?? this.muscleGroupFamily,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RecoveryLogDto{id: $id, muscleGroupFamily: $muscleGroupFamily, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
