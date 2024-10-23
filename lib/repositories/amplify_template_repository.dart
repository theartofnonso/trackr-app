import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_template_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../enums/routine_schedule_type_enums.dart';

class AmplifyTemplateRepository {

  List<RoutineTemplateDto> _templates = [];

  UnmodifiableListView<RoutineTemplateDto> get templates => UnmodifiableListView(_templates);

  void loadTemplatesStream({required List<RoutineTemplate> templates}) {
    _mapAndSortTemplates(templates: templates);
  }

  void _mapAndSortTemplates({required List<RoutineTemplate> templates}) {
    _templates = templates.map((template) {
      final templateDto = template.dto();
      if (templateDto.scheduleType == RoutineScheduleType.intervals) {
        _rescheduleRoutineTemplates(template: templateDto);
      }
      return templateDto;
    }).sorted((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _rescheduleRoutineTemplates({required RoutineTemplateDto template}) {
    final scheduledDate = template.scheduledDate;

    if (scheduledDate != null) {
      if (scheduledDate.isBefore(DateTime.now().withoutTime())) {
        final newSchedule = DateTime.now().add(Duration(days: template.scheduleIntervals)).withoutTime();
        final modifiedTemplate = template.copyWith(
            scheduledDate: newSchedule,
            scheduleType: RoutineScheduleType.intervals,
            scheduleIntervals: template.scheduleIntervals,
            scheduledDays: []);
        updateTemplate(template: modifiedTemplate);
      }
    }
  }

  Future<RoutineTemplateDto> saveTemplate({required RoutineTemplateDto templateDto}) async {
    final now = TemporalDateTime.now();

    final templateToCreate = RoutineTemplate(data: jsonEncode(templateDto), createdAt: now, updatedAt: now);

    await Amplify.DataStore.save<RoutineTemplate>(templateToCreate);

    final updatedWithId = templateDto.copyWith(id: templateToCreate.id, owner: SharedPrefs().userId);

    _templates.insert(0, updatedWithId);

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
      await Amplify.DataStore.save(newTemplate);
      final index = _indexWhereRoutineTemplate(id: template.id);
      _templates[index] = template;
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

      await Amplify.DataStore.save(newLog);
      final index = _indexWhereRoutineTemplate(id: newLog.id);
      _templates[index] = newTemplateDto;
    }
  }

  Future<void> removeTemplate({required RoutineTemplateDto template}) async {
    final result = (await Amplify.DataStore.query(
      RoutineTemplate.classType,
      where: RoutineTemplate.ID.eq(template.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete(oldTemplate);
      final index = _indexWhereRoutineTemplate(id: template.id);
      _templates.removeAt(index);
    }
  }

  /// Helper methods

  int _indexWhereRoutineTemplate({required String id}) {
    return _templates.indexWhere((template) => template.id == id);
  }

  RoutineTemplateDto? templateWhere({required String id}) {
    return _templates.firstWhereOrNull((dto) => dto.id == id);
  }

  void clear() {
    _templates.clear();
  }
}
