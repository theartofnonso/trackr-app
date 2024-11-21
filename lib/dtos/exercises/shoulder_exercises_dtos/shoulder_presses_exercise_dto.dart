import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_upper_body_modality_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class ShoulderPressesExerciseDTO extends ExerciseDTO {

  @override
  String get id => "SHO_03";

  @override
  String get name => "Shoulder Presses";

  @override
  String get description => "An overhead pushing movement targeting the shoulders, triceps, and upper chest";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.shoulders];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.chest, MuscleGroup.triceps];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.stance: [ExerciseStance.seated, ExerciseStance.standing],
    ExerciseConfigurationKey.upperBodyModality: [ExerciseUpperBodyModality.unilateral, ExerciseUpperBodyModality.bilateral],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.barbell,
      ExerciseEquipment.ezBar,
      ExerciseEquipment.band,
      ExerciseEquipment.machine
    ]
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.dumbbell,
          ExerciseConfigurationKey.upperBodyModality: ExerciseUpperBodyModality.unilateral,
          ExerciseConfigurationKey.stance: ExerciseStance.seated,
        });
    return variant;
  }
}
