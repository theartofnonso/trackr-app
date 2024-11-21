import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_laying_position_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class TricepsPushUpsExerciseDto extends ExerciseDTO {
  @override
  String get id => "CHT_05";

  @override
  String get name => "Close-Grip Push Ups";

  @override
  String get description => "Focuses on strengthening the triceps by positioning the hands close together.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.chest];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.shoulders, MuscleGroup.triceps];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.none,
          ExerciseEquipment.plate
        ],
    ExerciseConfigurationKey.layingPosition: [ExerciseLayingPosition.neutral, ExerciseLayingPosition.incline, ExerciseLayingPosition.decline],
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.reps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.none,
      ExerciseConfigurationKey.layingPosition: ExerciseLayingPosition.neutral
    });
    return variant;
  }
}
