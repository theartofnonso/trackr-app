import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../enums/exercise/exercise_configuration_key.dart';
import '../../enums/exercise/exercise_equipment_enum.dart';
import '../../enums/exercise/set_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class ChestDipsExerciseDTO extends ExerciseDTO {

  @override
  String get id => "CHT_02";

  @override
  String get name => "Chest Dips";

  @override
  String get description => "Targets chest, triceps, and shoulders to build upper body strength.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.chest];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.shoulders, MuscleGroup.triceps];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.none,
      ExerciseEquipment.straightBar,
      ExerciseEquipment.parallelBars,
      ExerciseEquipment.assistedMachine
    ]
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.reps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.none,
        });
    return variant;
  }
}
