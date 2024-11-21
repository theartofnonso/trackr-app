import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../enums/exercise/exercise_equipment_enum.dart';
import '../../enums/exercise/exercise_metrics_enums.dart';
import '../exercise_dto.dart';

class SplitSquatExerciseDTO extends ExerciseDTO {

  @override
  String get id => "QUA_06";

  @override
  String get name => "Split Squats";

  @override
  String get description => "A single-leg squat variation that isolates the quadriceps and glutes.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.quadriceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.hamstrings, MuscleGroup.glutes];

  @override
  Map<String, List<ExerciseConfig>> get configurationOptions => {
    "set_type": [SetType.reps, SetType.weightsAndReps],
    "equipment": [
      ExerciseEquipment.none,
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.kettleBell,
      ExerciseEquipment.smithMachine
    ]
  };

  @override
  ExerciseVariantDTO createVariant({required Map<String, dynamic> configurations}) {
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
        baseExerciseId: id,
        name: name,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        configurations: validConfigurations);
  }

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          "set_type": SetType.reps,
          "equipment": ExerciseEquipment.none,
        });
    return variant;
  }
}
