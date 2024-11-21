import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../enums/exercise/exercise_equipment_enum.dart';
import '../enums/exercise/exercise_metrics_enums.dart';
import 'exercise_dto.dart';

class SquatExerciseDTO extends ExerciseDTO {
  SquatExerciseDTO(
      {required super.id,
      required super.name,
      required super.description,
      required super.primaryMuscleGroups,
      required super.secondaryMuscleGroups,
      required super.configurationOptions});

  @override
  ExerciseVariantDTO createVariant(
      {required String baseExerciseId,
      required String name,
      required List<MuscleGroup> primaryMuscleGroups,
      required List<MuscleGroup> secondaryMuscleGroups,
      required Map<String, dynamic> configurations}) {
    /// Validate configurations
    Map<String, ExerciseConfig> validConfigurations = {};

    configurations.forEach((key, value) {
      if (configurationOptions.containsKey(key)) {
        if (configurationOptions[key]!.contains(value)) {
          validConfigurations[key] = value;
        } else {
          throw ArgumentError('Invalid configuration value "$value" for key "$key" in "$name".');
        }
      } else {
        throw ArgumentError('Configuration "$key" is not valid for exercise "$name".');
      }
    });
    return ExerciseVariantDTO(
        baseExerciseId: baseExerciseId,
        name: name,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        configurations: validConfigurations);
  }

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        baseExerciseId: id,
        name: name,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        configurations: {
          "metrics": ExerciseMetric.reps,
          "equipment": ExerciseEquipment.none,
        });
    return variant;
  }
}
