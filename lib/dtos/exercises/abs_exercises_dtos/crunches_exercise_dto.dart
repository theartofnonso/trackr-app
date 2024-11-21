import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class CrunchesExerciseDto extends ExerciseDTO {

  @override
  String get id => "ABS_02";

  @override
  String get name => "Crunches";

  @override
  String get description => "Targets the upper abs in a crunching motion.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.abs];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.glutes];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.stance: [ExerciseStance.seated, ExerciseStance.kneeling],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.machine,
      ExerciseEquipment.cableMachine,
      ExerciseEquipment.plate,
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.barbell,
      ExerciseEquipment.none,
    ],
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.reps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.none,
          ExerciseConfigurationKey.stance: ExerciseStance.kneeling,
        });
    return variant;
  }
}
