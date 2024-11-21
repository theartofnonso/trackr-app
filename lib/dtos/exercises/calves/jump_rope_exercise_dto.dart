import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_upper_body_modality_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class JumpRopeExerciseDto extends ExerciseDTO {
  @override
  String get id => "CAL_02";

  @override
  String get name => "Jump Rope";

  @override
  String get description => "Engages the calves through repetitive jumping motions, building strength, endurance, and coordination while improving overall lower-body mobility and agility.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.calves];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
        ExerciseConfigurationKey.stance: [ExerciseStance.seated, ExerciseStance.standing],
        ExerciseConfigurationKey.lowerBodyModality: [
          ExerciseUpperBodyModality.unilateral,
          ExerciseUpperBodyModality.bilateral
        ],
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.reps,
      ExerciseConfigurationKey.lowerBodyModality: ExerciseUpperBodyModality.bilateral
    });
    return variant;
  }
}
