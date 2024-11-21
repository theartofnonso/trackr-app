import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_upper_body_modality_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class PulldownExerciseDTO extends ExerciseDTO {
  @override
  String get id => "BAC_02";

  @override
  String get name => "Lat Pulldowns";

  @override
  String get description => "Activates the lats and upper back, promoting overall back strength.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.back];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.biceps, MuscleGroup.shoulders];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
        ExerciseConfigurationKey.stance: [ExerciseStance.bentOver, ExerciseStance.seated],
        ExerciseConfigurationKey.upperBodyModality: [
          ExerciseUpperBodyModality.unilateral,
          ExerciseUpperBodyModality.bilateral
        ],
        ExerciseConfigurationKey.equipment: [ExerciseEquipment.cableMachine, ExerciseEquipment.band],
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.weightsAndReps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.cableMachine,
      ExerciseConfigurationKey.stance: ExerciseStance.seated,
      ExerciseConfigurationKey.upperBodyModality: ExerciseUpperBodyModality.bilateral
    });
    return variant;
  }
}
