import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../logger.dart';

class AmplifyRoutineTemplateRepository {

  final logger = getLogger(className: "AmplifyRoutineTemplateRepository");

  List<RoutineTemplateDto> _templates = [];

  UnmodifiableListView<RoutineTemplateDto> get templates => UnmodifiableListView(_templates);

  void loadTemplatesStream({required List<RoutineTemplate> templates, required VoidCallback onLoaded}) {
    _templates = templates.map((log) => RoutineTemplateDto.toDto(log)).toList();
    onLoaded();
  }

  Future<RoutineTemplateDto> saveTemplate({required RoutineTemplateDto templateDto}) async {
    final now = TemporalDateTime.now();

    final templateToCreate = RoutineTemplate(data: jsonEncode(templateDto), createdAt: now, updatedAt: now, owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineTemplate>(templateToCreate);

    logger.i("save template: $templateDto");

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
      logger.i("update template: $template");
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
      logger.i("remove template: $template");
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
