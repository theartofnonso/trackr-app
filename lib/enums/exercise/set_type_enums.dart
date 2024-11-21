import 'package:tracker_app/enums/exercise/exercise_configuration_key.dart';

import '../../dtos/abstract_class/exercise_dto.dart';

enum SetType implements ExerciseConfigValue {
  weightsAndReps(
      displayName: "With Weights",
      description: "Log the weight and reps for strength exercises like bench press or squats curls."),
  reps(
      displayName: "Without Weights",
      description: "Track the number of reps for bodyweight exercises like pull-ups, crunches, or burpees"),
  duration(
      displayName: "Duration",
      description: "Record how long you hold or perform time-based exercises like planks or Dead Hang.");

  const SetType({required this.displayName, required this.description});

  @override
  final String displayName;

  @override
  final String description;

  static SetType _fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

  static SetType fromJson(Map<String, dynamic> json) {
    final name = json["name"];
    return SetType._fromString(name);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": ExerciseConfigurationKey.setType.name,
      'name': name,
      'displayName': displayName,
      'description': description,
    };
  }
}
