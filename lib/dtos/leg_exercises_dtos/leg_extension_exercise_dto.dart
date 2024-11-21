import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../enums/exercise/exercise_equipment_enum.dart';
import '../../enums/exercise/set_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class LegExtensionsExerciseDTO extends ExerciseDTO {

  @override
  String get id => "QUA_04";

  @override
  String get name => "Leg Extensions";

  @override
  String get description => "An isolation exercise for strengthening the quadriceps using a leg extension machine.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.quadriceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.hamstrings, MuscleGroup.glutes];

  @override
  Map<String, List<ExerciseConfig>> get configurationOptions => {
    "set_type": [SetType.weightsAndReps],
    "equipment": [
      ExerciseEquipment.machine,
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
          "set_type": SetType.weightsAndReps,
          "equipment": ExerciseEquipment.machine,
        });
    return variant;
  }
}
