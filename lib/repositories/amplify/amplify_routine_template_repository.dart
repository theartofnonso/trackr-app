import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:tracker_app/extensions/amplify_models/routine_template_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';

class AmplifyRoutineTemplateRepository {
  List<RoutineTemplateDto> _templates = [];

  UnmodifiableListView<RoutineTemplateDto> get templates => UnmodifiableListView(_templates);

  void loadTemplatesStream({required List<RoutineTemplate> templates}) {
    _templates = templates.map((template) {
      final templateDto = template.dto();
      return templateDto;
    }).toList();
  }

  Future<RoutineTemplateDto> saveTemplate({required RoutineTemplateDto templateDto}) async {
    final now = TemporalDateTime.now();

    final templateToCreate = RoutineTemplate(data: jsonEncode(templateDto), createdAt: now, updatedAt: now, owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineTemplate>(templateToCreate);

    final updatedWithId = templateDto.copyWith(id: templateToCreate.id);

    return updatedWithId;
  }

  Future<void> updateTemplate({required RoutineTemplateDto template}) async {
    final result = (await Amplify.DataStore.query(
      RoutineTemplate.classType,
      where: RoutineTemplate.ID.eq(template.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      final newTemplate = oldTemplate.copyWith(data: jsonEncode(template));
      await Amplify.DataStore.save<RoutineTemplate>(newTemplate);
    }
  }

  Future<void> updateTemplateSetsOnly({required String templateId, required List<ExerciseLogDto> newExercises}) async {
    final result = (await Amplify.DataStore.query(
      RoutineTemplate.classType,
      where: RoutineTemplate.ID.eq(templateId),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      final oldTemplateDto = oldTemplate.dto();

      final updatedExercisesTemplates = oldTemplateDto.exerciseTemplates.map((oldExerciseTemplate) {
        final newExerciseTemplate =
            newExercises.firstWhereOrNull((newExercise) => newExercise.id == oldExerciseTemplate.id);

        if (newExerciseTemplate == null) {
          return oldExerciseTemplate;
        }

        final updatedSets = <SetDto>[];

        for (int i = 0; i < oldExerciseTemplate.sets.length; i++) {
          final newSet = newExerciseTemplate.sets[i];
          updatedSets.add(newSet.copyWith(checked: false));
        }
        return oldExerciseTemplate.copyWith(sets: updatedSets);
      }).toList();

      final newTemplateDto = oldTemplateDto.copyWith(exerciseTemplates: updatedExercisesTemplates);

      final newLog = oldTemplate.copyWith(data: jsonEncode(newTemplateDto));

      await Amplify.DataStore.save<RoutineTemplate>(newLog);
    }
  }

  Future<void> removeTemplate({required RoutineTemplateDto template}) async {
    final result = (await Amplify.DataStore.query(
      RoutineTemplate.classType,
      where: RoutineTemplate.ID.eq(template.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete<RoutineTemplate>(oldTemplate);
    }
  }

  void syncTemplatesWithExercisesFromLibrary({required List<ExerciseDto> exercises}) {
    final updatedTemplates = _templates.map((template) {
      final updatedExerciseTemplates =  template.exerciseTemplates.map((exerciseTemplate) {
        final foundExercise = exercises.firstWhere((exerciseInLibrary) => exerciseInLibrary.id == exerciseTemplate.exercise.id, orElse: () => exerciseTemplate.exercise);
        return exerciseTemplate.copyWith(exercise: foundExercise);
      }).toList();
      return template.copyWith(exerciseTemplates: updatedExerciseTemplates);
    }).toList();
    _templates = updatedTemplates;
  }

  /// Helper methods

  RoutineTemplateDto? templateWhere({required String id}) {
    return _templates.firstWhereOrNull((dto) => dto.id == id);
  }

  void clear() {
    _templates.clear();
  }
}
