import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_lower_body_modality_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class LegCurlsExerciseDTO extends ExerciseDTO {
  @override
  String get id => "HAM_03";

  @override
  String get name => "Leg Curls";

  @override
  String get description =>
      "Isolates the hamstrings by curling the legs from a lying, seated or bent over position, enhancing muscle development.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.hamstrings];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.glutes];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
        ExerciseConfigurationKey.lowerBodyModality: [
          ExerciseLowerBodyModality.bilateral,
          ExerciseLowerBodyModality.unilateral
        ],
        ExerciseConfigurationKey.stance: [ExerciseStance.lying, ExerciseStance.seated, ExerciseStance.bentOver],
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.weightsAndReps,
      ExerciseConfigurationKey.stance: ExerciseStance.lying,
      ExerciseConfigurationKey.lowerBodyModality: ExerciseLowerBodyModality.bilateral
    });
    return variant;
  }
}
