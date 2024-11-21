import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_configuration_key.dart';
import 'package:tracker_app/enums/exercise/set_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../enums/exercise/exercise_equipment_enum.dart';

abstract class ExerciseConfig {
  final String displayName;
  final String description;

  ExerciseConfig(this.displayName, this.description);

  Map<String, dynamic> toJson();

  static ExerciseConfig fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case ExerciseConfigurationKey.equipment:
        return ExerciseEquipment.fromJson(json);
      case ExerciseConfigurationKey.setType:
        return SetType.fromJson(json);
      case ExerciseConfigurationKey.seatingPosition:
      default:
        throw ArgumentError('Unknown ExerciseConfig type: ${json['type']}');
    }
  }
}

abstract class ExerciseDTO {
  String get id;
  String get name;
  String get description;
  List<MuscleGroup> get primaryMuscleGroups;
  List<MuscleGroup> get secondaryMuscleGroups;
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions;


  ExerciseVariantDTO createVariant({required Map<ExerciseConfigurationKey, ExerciseConfig> configurations}) {
    // Validate configurations
    final validConfigurations = <ExerciseConfigurationKey, ExerciseConfig>{};

    for (final key in configurations.keys) {
      final value = configurations[key];
      final validOptions = configurationOptions[key];

      if (validOptions == null) {
        throw ArgumentError('Configuration "$key" is not valid for exercise "$name".');
      }

      if (!validOptions.contains(value)) {
        throw ArgumentError('Invalid configuration value "$value" for key "$key" in "$name".');
      }

      validConfigurations[key] = value!;
    }

    // Create the variant with validated configurations
    return ExerciseVariantDTO(
      baseExerciseId: id,
      name: name,
      primaryMuscleGroups: primaryMuscleGroups,
      secondaryMuscleGroups: secondaryMuscleGroups,
      configurations: validConfigurations,
    );
  }

  ExerciseVariantDTO defaultVariant();

  @override
  String toString() {
    return 'ExerciseDTO{id: $id, name: $name, description: $description, configurationOptions: $configurationOptions}';
  }
}
