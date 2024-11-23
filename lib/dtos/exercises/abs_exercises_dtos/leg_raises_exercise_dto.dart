import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class LegRaisesExerciseDto extends ExerciseDTO {

  @override
  String get id => "ABS_03";

  @override
  String get name => "Leg Raises";

  @override
  String get description => "Targets the lower abs by lifting the legs while suspended.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.abs];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.stance: [ExerciseStance.lying, ExerciseStance.seated, ExerciseStance.hanging],
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.reps,
          ExerciseConfigurationKey.stance: ExerciseStance.hanging,
        });
    return variant;
  }
}
