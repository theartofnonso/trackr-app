import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

abstract class ExerciseConfig {
  String get name;
  String get description;
}

abstract class ExerciseDTO {
  final String id;
  final String name;
  final String description;
  final List<MuscleGroup> primaryMuscleGroups;
  final List<MuscleGroup> secondaryMuscleGroups;
  final Map<String, List<ExerciseConfig>> configurationOptions;

  ExerciseDTO(
      {required this.id,
      required this.name,
      required this.description,
      required this.primaryMuscleGroups,
      required this.secondaryMuscleGroups,
      required this.configurationOptions});

  ExerciseVariantDTO createVariant({required String baseExerciseId, required String name, required List<MuscleGroup> primaryMuscleGroups, required List<MuscleGroup> secondaryMuscleGroups, required Map<String, dynamic> configurations});

  ExerciseVariantDTO defaultVariant();

  @override
  String toString() {
    return 'ExerciseDTO{id: $id, name: $name, description: $description, configurationOptions: $configurationOptions}';
  }
}
