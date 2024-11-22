import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_upper_body_modality_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_lower_body_modality_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class CalfRaisesExerciseDTO extends ExerciseDTO {
  @override
  String get id => "CAL_01";

  @override
  String get name => "Calf Raises";

  @override
  String get description => "Strengthens the calf muscles by raising the heels from a standing position.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.calves];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
        ExerciseConfigurationKey.stance: [ExerciseStance.seated, ExerciseStance.standing],
        ExerciseConfigurationKey.lowerBodyModality: [
          ExerciseLowerBodyModality.unilateral,
          ExerciseLowerBodyModality.bilateral
        ],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.smithMachine,
          ExerciseEquipment.machine,
          ExerciseEquipment.plate,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.none
        ],
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.reps,
      ExerciseConfigurationKey.stance: ExerciseStance.standing,
      ExerciseConfigurationKey.lowerBodyModality: ExerciseLowerBodyModality.bilateral,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.none,
    });
    return variant;
  }
}
