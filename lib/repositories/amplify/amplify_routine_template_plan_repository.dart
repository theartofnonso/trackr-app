import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/appsync/routine_template_plan_dto.dart';

class AmplifyRoutineTemplatePlanRepository {
  List<RoutineTemplatePlanDto> _templatePlans = [];

  UnmodifiableListView<RoutineTemplatePlanDto> get templatePlans => UnmodifiableListView(_templatePlans);

  void loadTemplatePlansStream({required List<RoutineTemplatePlan> templatesPlans, required VoidCallback onData}) {
    _templatePlans = templatesPlans.map((templatePlan) => RoutineTemplatePlanDto.toDto(templatePlan)).toList();
    onData();
  }

  Future<RoutineTemplatePlanDto> saveTemplatePlan({required RoutineTemplatePlanDto templatePlanDto}) async {
    final now = TemporalDateTime.now();

    final templatePlanToCreate =
    RoutineTemplatePlan(data: jsonEncode(templatePlanDto), createdAt: now, updatedAt: now, owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineTemplatePlan>(templatePlanToCreate);

    final updatedWithId = templatePlanDto.copyWith(id: templatePlanToCreate.id, owner: templatePlanToCreate.owner);

    return updatedWithId;
  }

  Future<void> updateTemplatePlan({required RoutineTemplatePlanDto template}) async {
    final result = (await Amplify.DataStore.query(
      RoutineTemplatePlan.classType,
      where: RoutineTemplatePlan.ID.eq(template.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      final newTemplate = oldTemplate.copyWith(data: jsonEncode(template));
      await Amplify.DataStore.save<RoutineTemplatePlan>(newTemplate);
    }
  }

  Future<void> removeTemplatePlan({required RoutineTemplatePlanDto template}) async {
    final result = (await Amplify.DataStore.query(
      RoutineTemplatePlan.classType,
      where: RoutineTemplatePlan.ID.eq(template.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete<RoutineTemplatePlan>(oldTemplate);
    }
  }

  void syncTemplatePlansWithExercisesFromLibrary({required List<ExerciseDto> exercises}) {
    final updatedTemplatePlans = _templatePlans.map((templatePlan) {
      final updatedTemplates = templatePlan.templates.map((template) {
        final updatedExerciseTemplates = template.exerciseTemplates.map((exerciseTemplate) {
          final foundExercise = exercises.firstWhere(
                  (exerciseInLibrary) => exerciseInLibrary.id == exerciseTemplate.exercise.id,
              orElse: () => exerciseTemplate.exercise);
          return exerciseTemplate.copyWith(exercise: foundExercise);
        }).toList();
        return template.copyWith(exerciseTemplates: updatedExerciseTemplates);
      }).toList();
      return templatePlan.copyWith(templates: updatedTemplates);
    }).toList();
    _templatePlans = updatedTemplatePlans;
  }

  /// Helper methods

  RoutineTemplatePlanDto? templatePlanWhere({required String id}) {
    return _templatePlans.firstWhereOrNull((dto) => dto.id == id);
  }

  void clear() {
    _templatePlans.clear();
  }
}
