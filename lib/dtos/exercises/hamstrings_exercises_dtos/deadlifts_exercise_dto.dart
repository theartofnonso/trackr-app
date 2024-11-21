import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_lower_body_modality_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class DeadliftsExerciseDTO extends ExerciseDTO {
  @override
  String get id => "HAM_02";

  @override
  String get name => "Deadlifts";

  @override
  String get description =>
      "Targets the hamstrings and lower back with a hinge motion, building posterior chain strength.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.hamstrings];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.glutes, MuscleGroup.back, MuscleGroup.abs];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
        ExerciseConfigurationKey.lowerBodyModality: [ExerciseLowerBodyModality.bilateral, ExerciseLowerBodyModality.unilateral],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.barbell,
          ExerciseEquipment.smithMachine,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell
        ]
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.weightsAndReps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.barbell,
      ExerciseConfigurationKey.lowerBodyModality: ExerciseLowerBodyModality.bilateral
    });
    return variant;
  }
}
