import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_upper_body_modality_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class PullUpsExerciseDTO extends ExerciseDTO {
  @override
  String get id => "BAC_03";

  @override
  String get name => "Pull Ups";

  @override
  String get description => "Activates the lats and upper back, promoting overall back strength.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.back];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.biceps, MuscleGroup.shoulders];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
        ExerciseConfigurationKey.upperBodyModality: [
          ExerciseUpperBodyModality.unilateral,
          ExerciseUpperBodyModality.bilateral
        ],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.plate,
          ExerciseEquipment.assistedMachine,
          ExerciseEquipment.band,
          ExerciseEquipment.none
        ],
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.reps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.none,
      ExerciseConfigurationKey.upperBodyModality: ExerciseUpperBodyModality.bilateral
    });
    return variant;
  }
}
