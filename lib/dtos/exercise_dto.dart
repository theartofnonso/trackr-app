import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../enums/exercise/exercise_equipment_enum.dart';

abstract class ExerciseConfig {
  String get name;
  String get description;

  Map<String, dynamic> toJson();

  static ExerciseConfig fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'ExerciseEquipment':
        return ExerciseEquipment.fromJson(json);
      case 'ExerciseMetric':
        return ExerciseMetric.fromJson(json);
      default:
        throw ArgumentError('Unknown ExerciseConfig type: ${json['type']}');
    }
  }
}

abstract class ExerciseDTO {
  final String id;
  final String name;
  final String description;
  final List<MuscleGroup> primaryMuscleGroups;
  final List<MuscleGroup> secondaryMuscleGroups;
  final Map<String, List<ExerciseConfig>> configurationOptions;

  ExerciseDTO(
      {required this.id,
      required this.name,
      required this.description,
      required this.primaryMuscleGroups,
      required this.secondaryMuscleGroups,
      required this.configurationOptions});

  ExerciseVariantDTO createVariant({required Map<String, dynamic> configurations});

  ExerciseVariantDTO defaultVariant();

  @override
  String toString() {
    return 'ExerciseDTO{id: $id, name: $name, description: $description, configurationOptions: $configurationOptions}';
  }
}
