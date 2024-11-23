import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class AdductorExerciseDTO extends ExerciseDTO {

  @override
  String get id => "ADD_01";

  @override
  String get name => "Hip Adduction";

  @override
  String get description => "Targets the inner thigh muscles, specifically the adductors, to improve leg stability and strength.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.adductors];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
        });
    return variant;
  }
}
