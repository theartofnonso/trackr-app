import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class GluteKickBacksExerciseDTO extends ExerciseDTO {
  @override
  String get id => "GLU_01";

  @override
  String get name => "Glute Kickbacks";

  @override
  String get description => "Isolates the glutes with a backward kicking motion.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.glutes];

  @override
  List<MuscleGroup> get secondaryMuscleGroups =>
      [MuscleGroup.hamstrings, MuscleGroup.quadriceps, MuscleGroup.adductors, MuscleGroup.back, MuscleGroup.abs];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
        ExerciseConfigurationKey.stance: [ExerciseStance.bentOver, ExerciseStance.kneeling],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.none,
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.machine,
          ExerciseEquipment.band,
        ]
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.reps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.none,
      ExerciseConfigurationKey.stance: ExerciseStance.bentOver
    });
    return variant;
  }
}
