import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class GoodMorningExerciseDTO extends ExerciseDTO {
  @override
  String get id => "HAM_01";

  @override
  String get name => "Good Morning";

  @override
  String get description =>
      "Targets the hamstrings and lower back with a hinge motion, building posterior chain strength.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.hamstrings];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.glutes, MuscleGroup.back, MuscleGroup.abs];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
        ExerciseConfigurationKey.equipment: [ExerciseEquipment.barbell, ExerciseEquipment.smithMachine]
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.weightsAndReps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.barbell,
    });
    return variant;
  }
}
