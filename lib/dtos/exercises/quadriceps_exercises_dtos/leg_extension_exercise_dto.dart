import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_lower_body_modality_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class LegExtensionsExerciseDTO extends ExerciseDTO {

  @override
  String get id => "QUA_04";

  @override
  String get name => "Leg Extensions";

  @override
  String get description => "An isolation exercise for strengthening the quadriceps using a leg extension machine.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.quadriceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.hamstrings, MuscleGroup.glutes];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
    ExerciseConfigurationKey.lowerBodyModality: [ExerciseLowerBodyModality.bilateral, ExerciseLowerBodyModality.unilateral]
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.lowerBodyModality: ExerciseLowerBodyModality.bilateral
        });
    return variant;
  }
}
