import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class BackExtensionExerciseDTO extends ExerciseDTO {

  @override
  String get id => "BAC_04";

  @override
  String get name => "Back Extension (Hyperextension)";

  @override
  String get description => "Targets the lower back and hamstrings with a bodyweight or weighted hyperextension.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.biceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.machine,
      ExerciseEquipment.plate,
      ExerciseEquipment.kettleBell,
    ],
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.reps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.machine,
        });
    return variant;
  }
}
