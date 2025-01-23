import 'dart:convert';

import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';

class RecoveryLogDto {
  final String id;

  final Map<MuscleGroupFamily, int> muscleGroupFamily;

  final int recovery;

  final String owner;

  final DateTime createdAt;

  final DateTime updatedAt;

  RecoveryLogDto({
    required this.id,
    required this.muscleGroupFamily,
    required this.recovery,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecoveryLogDto.toDto(RecoveryLog log) {
    return RecoveryLogDto.fromLog(log);
  }

  factory RecoveryLogDto.fromLog(RecoveryLog log) {
    final dataJson = jsonDecode(log.data);
    final muscleGroupFamilyString = dataJson["muscleGroupFamily"] ?? "";
    final muscleGroupFamily = MuscleGroupFamily.fromString(muscleGroupFamilyString);
    final recovery = dataJson["recovery"] ?? 0;

    return RecoveryLogDto(
      id: log.id,
      muscleGroupFamily: muscleGroupFamily,
      recovery: recovery,
      createdAt: log.createdAt.getDateTimeInUtc(),
      updatedAt: log.updatedAt.getDateTimeInUtc(),
      owner: log.owner ?? "",
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'muscleGroupFamily': muscleGroupFamily.name,
      'recovery': recovery,
    };
  }

  RecoveryLogDto copyWith({
    String? id,
    MuscleGroupFamily? muscleGroupFamily,
    int? recovery,
    String? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecoveryLogDto(
      id: id ?? this.id,
      muscleGroupFamily: muscleGroupFamily ?? this.muscleGroupFamily,
      recovery: recovery ?? this.recovery,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RecoveryLogDto{id: $id, muscleGroupFamily: $muscleGroupFamily, recovery: $recovery, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
