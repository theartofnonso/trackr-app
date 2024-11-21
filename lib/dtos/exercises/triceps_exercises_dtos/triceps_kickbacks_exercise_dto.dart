import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_stance_enum.dart';
import '../../../enums/exercise/exercise_upper_body_modality_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class TricepsKickbacksExerciseDTO extends ExerciseDTO {

  @override
  String get id => "TRI_03";

  @override
  String get name => "Triceps Kickbacks";

  @override
  String get description => "Isolate the triceps by extending the arm backward in a controlled motion.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.triceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.stance: [ExerciseStance.bentOver],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.rope,
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.band
    ],
    ExerciseConfigurationKey.upperBodyModality: [ExerciseUpperBodyModality.unilateral, ExerciseUpperBodyModality.bilateral]
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.dumbbell,
          ExerciseConfigurationKey.stance: ExerciseStance.bentOver,
          ExerciseConfigurationKey.upperBodyModality: ExerciseUpperBodyModality.bilateral
        });
    return variant;
  }
}
