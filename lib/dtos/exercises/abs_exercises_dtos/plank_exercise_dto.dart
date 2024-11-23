import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_laying_position_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class PlanksExerciseDTO extends ExerciseDTO {

  @override
  String get id => "ABS_01";

  @override
  String get name => "Planks";

  @override
  String get description => "Strengthens the core by holding a static plank position, engaging the entire midsection.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.abs];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.glutes];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.duration],
    ExerciseConfigurationKey.layingPosition: [ExerciseLayingPosition.incline, ExerciseLayingPosition.decline, ExerciseLayingPosition.neutral],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.plate,
      ExerciseEquipment.sandBag,
      ExerciseEquipment.none,
    ],
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.duration,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.none,
          ExerciseConfigurationKey.layingPosition: ExerciseLayingPosition.neutral,
        });
    return variant;
  }
}
