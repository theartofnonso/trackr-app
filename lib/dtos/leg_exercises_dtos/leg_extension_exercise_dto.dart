import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../enums/exercise/exercise_configuration_key.dart';
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
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.machine,
    ]
  };

  @override
  ExerciseVariantDTO createVariant({required Map<ExerciseConfigurationKey, dynamic> configurations}) {
    /// Validate configurations
    Map<ExerciseConfigurationKey, ExerciseConfig> validConfigurations = {};

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
    ExerciseVariantDTO newVariant = ExerciseVariantDTO(
        baseExerciseId: id,
        name: name,
        primaryMuscleGroups: primaryMuscleGroups,
        secondaryMuscleGroups: secondaryMuscleGroups,
        configurations: validConfigurations);

    final equipmentConfig = newVariant.getExerciseEquipmentConfiguration();
    final setTypeConfig = newVariant.getSetTypeConfiguration();

    final noEquipment = equipmentConfig == ExerciseEquipment.none;
    final onlyReps = setTypeConfig == SetType.reps;

    if(noEquipment || onlyReps) {
      validConfigurations[ExerciseConfigurationKey.setType] = SetType.reps;
      validConfigurations[ExerciseConfigurationKey.equipment] = ExerciseEquipment.none;
      newVariant = newVariant.copyWith(configurations: validConfigurations);
    }

    return newVariant;
  }

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.machine,
        });
    return variant;
  }
}
