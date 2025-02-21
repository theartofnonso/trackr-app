import 'dart:convert';

import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/training_goal_enums.dart';

import '../../models/RoutineUser.dart';

class RoutineUserDto {
  final String id;
  final String cognitoUserId;
  final String name;
  final String email;
  final num weight;
  final TrainingGoal trainingGoal;
  final List<MuscleGroup> muscleGroups;
  final String owner;

  RoutineUserDto(
      {required this.id,
      required this.name,
      required this.cognitoUserId,
      required this.email,
      required this.weight,
      this.trainingGoal = TrainingGoal.hypertrophy,
      required this.muscleGroups,
      required this.owner});

  factory RoutineUserDto.toDto(RoutineUser user) {
    return RoutineUserDto.fromJson(user);
  }

  factory RoutineUserDto.fromJson(RoutineUser user) {
    final json = jsonDecode(user.data);
    final cognitoUserId = json["cognitoUserId"] ?? "";
    final name = json["name"] ?? "";
    final email = json["email"] ?? "";
    final trainingGoal = TrainingGoal.fromString(json["trainingGoal"] ?? "");
    final weight = (json["weight"]) ?? 0.0;
    final muscleGroupStrings = (json["muscleGroups"] as List<dynamic>?) ?? [];
    final muscleGroups = muscleGroupStrings.isNotEmpty ? muscleGroupStrings.map((string) => MuscleGroup.fromString(string)).toList() : MuscleGroup.values;

    return RoutineUserDto(
        id: user.id,
        name: name,
        cognitoUserId: cognitoUserId,
        email: email,
        weight: weight,
        trainingGoal: trainingGoal,
        muscleGroups: muscleGroups,
        owner: user.owner ?? "");
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'cognitoUserId': cognitoUserId,
      'name': name,
      'email': email,
      'trainingGoal': trainingGoal.name,
      'weight': weight,
      'muscleGroups': muscleGroups.map((muscleGroup) => muscleGroup.name).toList(),
    };
  }

  RoutineUserDto copyWith({
    String? id,
    String? name,
    String? cognitoUserId,
    String? email,
    double? weight,
    TrainingGoal? trainingGoal,
    String? owner,
    List<MuscleGroup>? muscleGroups,
  }) {
    return RoutineUserDto(
        id: id ?? this.id,
        name: name ?? this.name,
        cognitoUserId: cognitoUserId ?? this.cognitoUserId,
        email: email ?? this.email,
        weight: weight ?? this.weight,
        trainingGoal: trainingGoal ?? this.trainingGoal,
        // Create a new list for secondaryMuscleGroups to avoid referencing the original.
        muscleGroups:
            muscleGroups != null ? List<MuscleGroup>.from(muscleGroups) : List<MuscleGroup>.from(this.muscleGroups),
        owner: owner ?? this.owner);
  }

  @override
  String toString() {
    return 'RoutineUserDto{id: $id, cognitoUserId: $cognitoUserId, name: $name, email: $email, weight: $weight, training: $trainingGoal owner: $owner, muscleGroups: $muscleGroups}';
  }
}
