import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_movement_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class ShoulderRaisesExerciseDTO extends ExerciseDTO {

  @override
  String get id => "SHO_01";

  @override
  String get name => "Shoulder Raises";

  @override
  String get description => "Targets the front/lateral deltoid muscles to build shoulder size.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.shoulders];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.movement: [ExerciseMovement.lateral, ExerciseMovement.front],
    ExerciseConfigurationKey.stance: [ExerciseStance.seated, ExerciseStance.standing],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.ezBar,
      ExerciseEquipment.barbell,
      ExerciseEquipment.band,
      ExerciseEquipment.cableMachine,
      ExerciseEquipment.sandBag,
      ExerciseEquipment.machine
    ]
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.dumbbell,
          ExerciseConfigurationKey.stance: ExerciseStance.seated,
          ExerciseConfigurationKey.movement: ExerciseMovement.lateral,
        });
    return variant;
  }
}
