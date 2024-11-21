import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_seating_position_enum.dart';

import '../../enums/exercise/exercise_configuration_key.dart';
import '../../enums/exercise/exercise_equipment_enum.dart';
import '../../enums/exercise/exercise_stance_enum.dart';
import '../../enums/exercise/exercise_upper_body_modality_enum.dart';
import '../../enums/exercise/set_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class TricepsPushdownsExerciseDTO extends ExerciseDTO {

  @override
  String get id => "TRI_02";

  @override
  String get name => "Triceps Pushdowns";

  @override
  String get description => "Isolates the triceps with a unique underhand grip, emphasizing the medial head of the muscle.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.triceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
    ExerciseConfigurationKey.stance: [ExerciseStance.standing],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.vBarHandle,
      ExerciseEquipment.straightBarHandle,
      ExerciseEquipment.rope,
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
