import 'dart:convert';

import 'package:tracker_app/models/ModelProvider.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_template_dto.dart';

extension RoutineExtension on RoutineTemplate {

  RoutineTemplateDto dto() {
    final dataJson = jsonDecode(data);

    final name = dataJson["name"];
    final notes = dataJson["notes"];
    final exercises = dataJson["exercise"].map((exerciseLog) => ExerciseLogDto.fromJson(json: exerciseLog)).toList();

    return RoutineTemplateDto(
      id: id,
      name: name,
      exercises: exercises,
      notes: notes,
      createdAt: createdAt.getDateTimeInUtc(),
      updatedAt: updatedAt.getDateTimeInUtc(),
    );
  }

}