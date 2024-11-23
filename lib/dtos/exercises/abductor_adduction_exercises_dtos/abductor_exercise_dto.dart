import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_stance_enum.dart';

import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/set_type_enums.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../abstract_class/exercise_dto.dart';

class AbductorExerciseDTO extends ExerciseDTO {

  @override
  String get id => "ABD_01";

  @override
  String get name => "Hip Abduction";

  @override
  String get description => "Activates and strengthens the hip abductors using resistance, focusing on lateral leg movement.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.abductors];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.glutes];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfigValue>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.reps, SetType.weightsAndReps],
    ExerciseConfigurationKey.stance: [ExerciseStance.seated, ExerciseStance.standing, ExerciseStance.lying, ExerciseStance.kneeling],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.machine,
      ExerciseEquipment.band,
      ExerciseEquipment.cableMachine
    ],
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.machine,
          ExerciseConfigurationKey.stance: ExerciseStance.seated,
        });
    return variant;
  }
}
