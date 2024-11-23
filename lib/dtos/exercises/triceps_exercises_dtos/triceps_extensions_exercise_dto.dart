import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_stance_enum.dart';
import '../../../enums/exercise/exercise_upper_body_modality_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class TricepsExtensionsExerciseDTO extends ExerciseDTO {

  @override
  String get id => "TRI_01";

  @override
  String get name => "Triceps Extensions";

  @override
  String get description => "Targets the long head of the triceps by stretching and contracting through the motion.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.triceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
    ExerciseConfigurationKey.stance: [ExerciseStance.standing, ExerciseStance.seated, ExerciseStance.lying],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.vBarHandle,
      ExerciseEquipment.straightBarHandle,
      ExerciseEquipment.rope,
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.ezBar,
    ],
    ExerciseConfigurationKey.upperBodyModality: [ExerciseUpperBodyModality.unilateral, ExerciseUpperBodyModality.bilateral]
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.vBarHandle,
          ExerciseConfigurationKey.stance: ExerciseStance.standing,
          ExerciseConfigurationKey.upperBodyModality: ExerciseUpperBodyModality.bilateral
        });
    return variant;
  }
}
