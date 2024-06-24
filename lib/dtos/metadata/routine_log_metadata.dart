class RoutineLogMetadata {
  final String id;
  final List<String> minimisedExerciseLogIds;

  RoutineLogMetadata({required this.id, required this.minimisedExerciseLogIds});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'minimisedExerciseLogIds': minimisedExerciseLogIds,
    };
  }

  factory RoutineLogMetadata.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? "";
    final minimisedExerciseLogIds = json["minimisedExerciseLogIds"] as List<String>;

    return RoutineLogMetadata(id: id, minimisedExerciseLogIds: minimisedExerciseLogIds);
  }

  @override
  String toString() {
    return 'ExerciseDto{id: $id, minimisedExerciseLogIds: $minimisedExerciseLogIds}';
  }
}
