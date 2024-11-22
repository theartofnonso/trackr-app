import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class SquatExerciseDTO extends ExerciseDTO {

  @override
  String get id => "QUA_01";

  @override
  String get name => "Squats";

  @override
  String get description => "Targets the quadriceps, glutes, and hamstrings.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.quadriceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.hamstrings, MuscleGroup.glutes];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.none,
      ExerciseEquipment.barbell,
      ExerciseEquipment.machine,
      ExerciseEquipment.hackSquatMachine,
      ExerciseEquipment.smithMachine,
      ExerciseEquipment.kettleBell
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
