import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../enums/exercise/exercise_configuration_key.dart';
import '../../enums/exercise/exercise_equipment_enum.dart';
import '../../enums/exercise/set_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class TricepsDipsExerciseDTO extends ExerciseDTO {

  @override
  String get id => "TRI_04";

  @override
  String get name => "Triceps Dips";

  @override
  String get description => "Strengthens the triceps by using body weight or weights attachments in a dipping motion with support from bars.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.chest];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.chest, MuscleGroup.shoulders];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.none,
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
