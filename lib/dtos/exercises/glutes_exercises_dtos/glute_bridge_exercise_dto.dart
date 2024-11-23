import 'package:tracker_app/dtos/exercise_variant_dto.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_lower_body_modality_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class GluteBridgeExerciseDTO extends ExerciseDTO {
  @override
  String get id => "GLU_04";

  @override
  String get name => "Glute Bridge";

  @override
  String get description => "Strengthens the glutes during a hip-lifting movement.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.glutes];

  @override
  List<MuscleGroup> get secondaryMuscleGroups =>
      [MuscleGroup.hamstrings, MuscleGroup.back];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
        ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.lowerBodyModality: [ExerciseLowerBodyModality.unilateral, ExerciseLowerBodyModality.bilateral],
        ExerciseConfigurationKey.equipment: [
          ExerciseEquipment.none,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.barbell,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.sandBag,
          ExerciseEquipment.plate
        ]
      };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(configurations: {
      ExerciseConfigurationKey.setType: SetType.reps,
      ExerciseConfigurationKey.equipment: ExerciseEquipment.none,
      ExerciseConfigurationKey.lowerBodyModality: ExerciseLowerBodyModality.bilateral,
    });
    return variant;
  }
}
