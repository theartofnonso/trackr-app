import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class StepUpsExerciseDTO extends ExerciseDTO {

  @override
  String get id => "QUA_05";

  @override
  String get name => "Step Ups";

  @override
  String get description => "Targets the quadriceps and glutes by stepping onto an elevated platform, enhancing lower body strength.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.quadriceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.hamstrings, MuscleGroup.glutes];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.equipment: [ExerciseEquipment.none, ExerciseEquipment.dumbbell, ExerciseEquipment.kettleBell, ExerciseEquipment.barbell, ExerciseEquipment.sandBag,],
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
