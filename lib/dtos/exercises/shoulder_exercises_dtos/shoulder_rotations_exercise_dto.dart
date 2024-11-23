import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_movement_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_upper_body_modality_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class ShoulderRotationsExerciseDTO extends ExerciseDTO {

  @override
  String get id => "SHO_05";

  @override
  String get name => "Shoulder Rotations";

  @override
  String get description => "A movement involving the circular motion of the shoulder joint, focusing on mobility and stability.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.shoulders];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.stance: [ExerciseStance.seated, ExerciseStance.standing, ExerciseStance.lying],
    ExerciseConfigurationKey.movement: [ExerciseMovement.internalRotation, ExerciseMovement.externalRotation],
    ExerciseConfigurationKey.upperBodyModality: [ExerciseUpperBodyModality.unilateral, ExerciseUpperBodyModality.bilateral],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.band,
      ExerciseEquipment.cableMachine
    ]
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.dumbbell,
          ExerciseConfigurationKey.upperBodyModality: ExerciseUpperBodyModality.unilateral,
          ExerciseConfigurationKey.stance: ExerciseStance.standing,
          ExerciseConfigurationKey.movement: ExerciseMovement.internalRotation,
        });
    return variant;
  }
}
