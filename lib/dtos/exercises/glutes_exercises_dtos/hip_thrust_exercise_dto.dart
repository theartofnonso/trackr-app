import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_lower_body_modality_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class HipThrustsExerciseDto extends ExerciseDTO {
  @override
  String get id => "GLU_03";

  @override
  String get name => "Hip Thrusts";

  @override
  String get description => "Targets the gluteus maximus for strength and size through hip extension.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.glutes];

  @override
  List<MuscleGroup> get secondaryMuscleGroups =>
      [MuscleGroup.hamstrings, MuscleGroup.quadriceps, MuscleGroup.adductors, MuscleGroup.back];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.barbell,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.smithMachine,
          ExerciseEquipment.machine,
          ExerciseEquipment.plate
        ],
    ExerciseConfigurationKey.lowerBodyModality: [ExerciseLowerBodyModality.unilateral, ExerciseLowerBodyModality.bilateral],
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.weightsAndReps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.barbell,
      ExerciseConfigurationKey.lowerBodyModality: ExerciseLowerBodyModality.bilateral,
    });
    return variant;
  }
}
