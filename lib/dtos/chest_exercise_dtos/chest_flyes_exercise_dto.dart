import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../enums/exercise/exercise_configuration_key.dart';
import '../../enums/exercise/exercise_equipment_enum.dart';
import '../../enums/exercise/set_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class ChestFlyesExerciseDTO extends ExerciseDTO {
  @override
  String get id => "CHT_03";

  @override
  String get name => "Chest Flyes";

  @override
  String get description => "Stretches and strengthens the chest muscles with a fly motion.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.chest];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.shoulders, MuscleGroup.triceps];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.machine
        ]
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.weightsAndReps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.dumbbell,
    });
    return variant;
  }
}
