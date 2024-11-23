import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class PullThroughsExerciseDto extends ExerciseDTO {
  @override
  String get id => "GLU_02";

  @override
  String get name => "Pull Throughs";

  @override
  String get description =>
      "Engages the glutes and hamstrings while focusing on hip hinge movement.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.glutes];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.hamstrings, MuscleGroup.adductors, MuscleGroup.back];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.band, ExerciseEquipment.cableMachine
        ]
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.reps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.band,
    });
    return variant;
  }
}
