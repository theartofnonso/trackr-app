import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_seating_position_enum.dart';

import '../../enums/exercise/exercise_configuration_key.dart';
import '../../enums/exercise/exercise_equipment_enum.dart';
import '../../enums/exercise/set_type_enums.dart';
import '../../enums/muscle_group_enums.dart';
import '../exercise_dto.dart';

class BenchPressesExerciseDTO extends ExerciseDTO {

  @override
  String get id => "CHT_01";

  @override
  String get name => "Bench Presses";

  @override
  String get description => "Strengthens the chest, shoulders, and triceps with a pressing motion.";

  @override
  List<MuscleGroup> get primaryMuscleGroups => [MuscleGroup.chest];

  @override
  List<MuscleGroup> get secondaryMuscleGroups => [MuscleGroup.shoulders, MuscleGroup.triceps];

  @override
  Map<ExerciseConfigurationKey, List<ExerciseConfig>> get configurationOptions => {
    ExerciseConfigurationKey.setType: [SetType.weightsAndReps],
    ExerciseConfigurationKey.seatingPosition: [ExerciseSeatingPosition.neutral, ExerciseSeatingPosition.incline, ExerciseSeatingPosition.decline],
    ExerciseConfigurationKey.equipment: [
      ExerciseEquipment.dumbbell,
      ExerciseEquipment.barbell,
    ]
  };

  @override
  ExerciseVariantDTO defaultVariant() {
    final variant = createVariant(
        configurations: {
          ExerciseConfigurationKey.setType: SetType.weightsAndReps,
          ExerciseConfigurationKey.equipment: ExerciseEquipment.barbell,
          ExerciseConfigurationKey.seatingPosition: ExerciseSeatingPosition.neutral
        });
    return variant;
  }
}
