import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_laying_position_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class ChestPushUpsExerciseDto extends ExerciseDTO {
  @override
  String get id => "CHT_04";

  @override
  String get name => "Push Ups";

  @override
  String get description => "Strengthens the chest and triceps with a bodyweight.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.chest];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.shoulders, MuscleGroup.triceps];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
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
