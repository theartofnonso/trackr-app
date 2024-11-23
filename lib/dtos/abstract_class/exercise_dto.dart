import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_configuration_key.dart';
import 'package:tracker_app/enums/exercise/exercise_movement_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_seating_position_enum.dart';
import 'package:tracker_app/enums/exercise/set_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../enums/exercise/exercise_equipment_enum.dart';
import '../../enums/exercise/exercise_laying_position_enum.dart';
import '../../enums/exercise/exercise_lower_body_modality_enum.dart';
import '../../enums/exercise/exercise_stance_enum.dart';
import '../../enums/exercise/exercise_standing_position_enum.dart';
import '../../enums/exercise/exercise_upper_body_modality_enum.dart';

abstract class ExerciseConfigValue {
  final String displayName;
  final String description;

  ExerciseConfigValue(this.displayName, this.description);

  Map<String, dynamic> toJson();

  static ExerciseConfigValue fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case "equipment":
        return ExerciseEquipment.fromJson(json);
      case "setType":
        return SetType.fromJson(json);
      case "seatingPosition":
        return ExerciseSeatingPosition.fromJson(json);
      case "standingPosition":
        return ExerciseStandingPosition.fromJson(json);
      case "layingPosition":
        return ExerciseLayingPosition.fromJson(json);
      case "upperBodyModality":
        return ExerciseUpperBodyModality.fromJson(json);
      case "lowerBodyModality":
        return ExerciseLowerBodyModality.fromJson(json);
      case "stance":
        return ExerciseStance.fromJson(json);
      case "movement":
        return ExerciseMovement.fromJson(json);
      default:
        throw ArgumentError('Unknown ExerciseConfigValue type: ${json['type']}');
    }
  }
}

abstract class ExerciseDTO {
  String get id;

  String get name;

  String get description;

  List<MuscleGroup> get primaryMuscleGroups;

  List<MuscleGroup> get secondaryMuscleGroups;

  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions;

  ExerciseVariantDTO createVariant({required Map<ExerciseConfigurationKey, ExerciseConfigValue> configurations}) {
    // Validate configurations
    final validConfigurations = <ExerciseConfigurationKey, ExerciseConfigValue>{};

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
