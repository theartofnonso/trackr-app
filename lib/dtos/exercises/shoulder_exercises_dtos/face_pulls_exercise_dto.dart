import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class FacePullsExerciseDto extends ExerciseDTO {
  @override
  String get id => "SHO_06";

  @override
  String get name => "Face Pulls";

  @override
  String get description => "Improves shoulder health by targeting the rear delts and upper back.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.shoulders];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
        ExerciseConfigurationKey.stance: [ExerciseStance.standing, ExerciseStance.seated],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.straightBarHandle,
          ExerciseEquipment.rope,
          ExerciseEquipment.vBarHandle,
          ExerciseEquipment.band,
        ]
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.weightsAndReps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.rope,
      ExerciseConfigurationKey.stance: ExerciseStance.standing,
    });
    return variant;
  }
}
