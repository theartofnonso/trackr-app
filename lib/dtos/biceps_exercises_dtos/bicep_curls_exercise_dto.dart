import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_seating_position_enum.dart';

import '../../enums/exercise/exercise_configuration_key.dart';
import '../../enums/exercise/exercise_equipment_enum.dart';
import '../../enums/exercise/exercise_upper_body_modality_enum.dart';
import '../../enums/exercise/set_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class BicepCurlsExerciseDTO extends ExerciseDTO {

  @override
  String get id => "BIC_01";

  @override
  String get name => "Bicep Curls";

  @override
  String get description => "Focuses on building overall biceps mass with weights.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.biceps];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
    ExerciseConfigurationKey.seatingPosition: [ExerciseSeatingPosition.neutral, ExerciseSeatingPosition.incline, ExerciseSeatingPosition.decline],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.barbell,
      ExerciseEquipment.ezBar,
      ExerciseEquipment.cableMachine,
      ExerciseEquipment.machine,
      ExerciseEquipment.band,
      ExerciseEquipment.kettleBell
    ],
    ExerciseConfigurationKey.upperBodyModality: [ExerciseUpperBodyModality.unilateral, ExerciseUpperBodyModality.bilateral]
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.barbell,
          ExerciseConfigurationKey.seatingPosition: ExerciseSeatingPosition.neutral,
          ExerciseConfigurationKey.upperBodyModality: ExerciseUpperBodyModality.unilateral
        });
    return variant;
  }
}
