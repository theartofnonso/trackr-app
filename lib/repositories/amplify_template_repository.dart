import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/extensions/routine_template_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../enums/routine_template_library_workout_enum.dart';
import '../screens/template/default/routine_template_library.dart';

class AmplifyTemplateRepository {
  final List<Map<RoutineTemplateLibraryWorkoutEnum, List<RoutineLibraryTemplate>>> _defaultTemplates = [];

  List<RoutineTemplateDto> _templates = [];

  StreamSubscription<QuerySnapshot<RoutineTemplate>>? _routineTemplateStream;

  UnmodifiableListView<Map<RoutineTemplateLibraryWorkoutEnum, List<RoutineLibraryTemplate>>> get defaultTemplates =>
      UnmodifiableListView(_defaultTemplates);

  UnmodifiableListView<RoutineTemplateDto> get templates => UnmodifiableListView(_templates);

  Future<RoutineTemplateDto> _loadTemplatesFromAssets(
      {required String file, required List<ExerciseDto> exercises}) async {
    String jsonString = await rootBundle.loadString('workouts/$file');
    final templateJson = json.decode(jsonString) as dynamic;
    final id = templateJson["id"] as String;
    final name = templateJson["name"] as String;
    final notes = templateJson["notes"] as String;
    final exerciseLogs = templateJson["exercises"] as List<dynamic>;
    final exerciseLogDtos = exerciseLogs.map((exerciseLog) {
      final foundExercise = exercises.firstWhere((exercise) => exercise.id == exerciseLog["exercise"]);
      return ExerciseLogDto(
          foundExercise.id, id, "", foundExercise, "", [], DateTime.now());
    }).toList();

    return RoutineTemplateDto(
        id: id,
        name: name,
        exercises: exerciseLogDtos,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  Future<void> loadTemplatesFromAssets({required List<ExerciseDto> exercises}) async {
    final pushTemplate = await _loadTemplatesFromAssets(file: "push_workout.json", exercises: exercises);
    final pullTemplate = await _loadTemplatesFromAssets(file: "pull_workout.json", exercises: exercises);
    final legsTemplate = await _loadTemplatesFromAssets(file: "legs_workout.json", exercises: exercises);

    _defaultTemplates.add({
      RoutineTemplateLibraryWorkoutEnum.ppl: [
        RoutineLibraryTemplate(template: pushTemplate, image: "bench_press.jpg"),
        RoutineLibraryTemplate(template: pullTemplate, image: "pull_up.jpg"),
        RoutineLibraryTemplate(template: legsTemplate, image: "squat.jpg")
      ]
    });

    final upperOneTemplate = await _loadTemplatesFromAssets(file: "upper_one_workout.json", exercises: exercises);
    final lowerOneTemplate = await _loadTemplatesFromAssets(file: "lower_one_workout.json", exercises: exercises);
    final upperTwoTemplate = await _loadTemplatesFromAssets(file: "upper_two_workout.json", exercises: exercises);
    final lowerTwoTemplate = await _loadTemplatesFromAssets(file: "lower_two_workout.json", exercises: exercises);
    _defaultTemplates.add({
      RoutineTemplateLibraryWorkoutEnum.upperLower: [
        RoutineLibraryTemplate(template: upperOneTemplate, image: "bicep_curl.jpg"),
        RoutineLibraryTemplate(template: lowerOneTemplate, image: "deadlift.jpg"),
        RoutineLibraryTemplate(template: upperTwoTemplate, image: "pull_up.jpg"),
        RoutineLibraryTemplate(template: lowerTwoTemplate, image: "squat.jpg"),
      ]
    });

    final noEquipmentFullBodyTemplate =
        await _loadTemplatesFromAssets(file: "no_equipment_fullbody_workout.json", exercises: exercises);
    final noEquipmentCoreTemplate =
        await _loadTemplatesFromAssets(file: "no_equipment_core_workout.json", exercises: exercises);
    _defaultTemplates.add({
      RoutineTemplateLibraryWorkoutEnum.noEquipment: [
        RoutineLibraryTemplate(template: noEquipmentFullBodyTemplate, image: "plank.jpg"),
        RoutineLibraryTemplate(template: noEquipmentCoreTemplate, image: "sit_ups.jpg")
      ]
    });
  }

  Future<void> fetchTemplates({required void Function() onSyncCompleted}) async {
    List<RoutineTemplate> templates = await Amplify.DataStore.query(RoutineTemplate.classType);
    if (templates.isNotEmpty) {
      _loadTemplates(templates: templates);
    } else {
      _observeRoutineTemplateQuery(onSyncCompleted: onSyncCompleted);
    }
  }

  void _loadTemplates({required List<RoutineTemplate> templates}) {
    _templates = templates.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<RoutineTemplateDto> saveTemplate({required RoutineTemplateDto templateDto}) async {
    final now = TemporalDateTime.now();

    final templateToCreate = RoutineTemplate(data: jsonEncode(templateDto), createdAt: now, updatedAt: now);

    await Amplify.DataStore.save<RoutineTemplate>(templateToCreate);

    final updatedWithId = templateDto.copyWith(id: templateToCreate.id);

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

      final updatedExercises = oldTemplateDto.exercises.map((oldExercise) {
        final newExercise = newExercises.firstWhereOrNull((newExercise) => newExercise.id == oldExercise.id);

        if (newExercise == null) {
          return oldExercise;
        }

        final updatedSets = <SetDto>[];

        for (int i = 0; i < oldExercise.sets.length; i++) {
          final newSet = newExercise.sets[i];
          updatedSets.add(newSet.copyWith(checked: false));
        }
        return oldExercise.copyWith(sets: updatedSets);
      }).toList();

      final newTemplateDto = oldTemplateDto.copyWith(exercises: updatedExercises);

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

  void _observeRoutineTemplateQuery({required void Function() onSyncCompleted}) {
    _routineTemplateStream =
        Amplify.DataStore.observeQuery(RoutineTemplate.classType).listen((QuerySnapshot<RoutineTemplate> snapshot) {
      if (snapshot.items.isNotEmpty) {
        _loadTemplates(templates: snapshot.items);
        _routineTemplateStream?.cancel();
        onSyncCompleted();
      }
    })
          ..onDone(() {
            _routineTemplateStream?.cancel();
          });
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
