import 'package:tracker_app/dtos/db/exercise_dto.dart';
import 'package:tracker_app/dtos/db/routine_plan_dto.dart';
import 'package:tracker_app/dtos/db/routine_template_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

class DataConverterService {
  DataConverterService();

  /// Converts workout API response to RoutineTemplateDto
  RoutineTemplateDto convertWorkoutToRoutineTemplate(
      Map<String, dynamic> workout) {
    final exercises = <ExerciseDto>[];

    for (final exerciseData in workout['exercises'] as List<dynamic>) {
      exercises.add(_convertExerciseData(exerciseData));
    }

    return RoutineTemplateDto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: workout['name'] ?? 'Workout',
      notes: workout['notes'] ?? '',
      exerciseTemplates: _convertExercisesToExerciseLogs(exercises),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Converts plan API response to RoutinePlanDto
  RoutinePlanDto convertPlanToRoutinePlan(Map<String, dynamic> plan) {
    final templates = <RoutineTemplateDto>[];

    for (final templateData in plan['templates'] as List<dynamic>) {
      final exercises = <ExerciseDto>[];

      for (final exerciseData in templateData['exercises'] as List<dynamic>) {
        exercises.add(_convertExerciseData(exerciseData));
      }

      templates.add(RoutineTemplateDto(
        id: '${DateTime.now().millisecondsSinceEpoch}_${templates.length}',
        name: templateData['name'] ?? 'Template',
        notes: templateData['notes'] ?? '',
        exerciseTemplates: _convertExercisesToExerciseLogs(exercises),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    return RoutinePlanDto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: plan['name'] ?? 'Plan',
      notes: plan['notes'] ?? '',
      templates: templates,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Converts ExerciseDto list to ExerciseLogDto list
  List<ExerciseLogDto> _convertExercisesToExerciseLogs(
      List<ExerciseDto> exercises) {
    return exercises.map((exercise) {
      return ExerciseLogDto(
        id: exercise.id,
        routineLogId: '',
        superSetId: '',
        exercise: exercise,
        sets: [],
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  /// Converts exercise data from API to ExerciseDto
  ExerciseDto _convertExerciseData(Map<String, dynamic> exerciseData) {
    return ExerciseDto(
      id: '${DateTime.now().millisecondsSinceEpoch}_${exerciseData['name']}',
      name: exerciseData['name'] ?? 'Exercise',
      type: ExerciseType.fromString(exerciseData['type']),
      primaryMuscleGroup:
          MuscleGroup.fromString(exerciseData['primaryMuscleGroup']),
      secondaryMuscleGroups:
          (exerciseData['secondaryMuscleGroups'] as List<dynamic>?)
                  ?.map((group) => MuscleGroup.fromString(group))
                  .toList() ??
              [],
    );
  }
}
