import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../dtos/appsync/routine_template_plan_dto.dart';

class AmplifyRoutineTemplatePlanRepository {
  List<RoutineTemplatePlanDto> _templatePlans = [];

  UnmodifiableListView<RoutineTemplatePlanDto> get templatePlans => UnmodifiableListView(_templatePlans);

  void loadTemplatePlansStream(
      {required List<RoutineTemplatePlan> templatesPlans, required VoidCallback onData}) async {
    for (final templatePlan in templatesPlans) {
      final templates = await Amplify.DataStore.query(
        RoutineTemplate.classType,
        where: RoutineTemplate.TEMPLATEPLAN.eq(templatePlan.id),
      );
      final templatePlanDto = RoutineTemplatePlanDto.toDto(templatePlan, templates: templates);
      _templatePlans.add(templatePlanDto);
    }
    onData();
  }

  Future<RoutineTemplatePlan> saveTemplatePlan({required RoutineTemplatePlanDto templatePlanDto}) async {
    final now = TemporalDateTime.now();

    final templatePlanToCreate = RoutineTemplatePlan(
        data: jsonEncode(templatePlanDto), createdAt: now, updatedAt: now, owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineTemplatePlan>(templatePlanToCreate);

    return templatePlanToCreate;
  }

  Future<void> updateTemplatePlan({required RoutineTemplatePlanDto templatePlanDto}) async {
    final result = (await Amplify.DataStore.query(
      RoutineTemplatePlan.classType,
      where: RoutineTemplatePlan.ID.eq(templatePlanDto.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      final newTemplate = oldTemplate.copyWith(data: jsonEncode(templatePlanDto));
      await Amplify.DataStore.save<RoutineTemplatePlan>(newTemplate);
    }
  }

  Future<void> removeTemplatePlan({required RoutineTemplatePlanDto templatePlanDto}) async {
    final result = (await Amplify.DataStore.query(
      RoutineTemplatePlan.classType,
      where: RoutineTemplatePlan.ID.eq(templatePlanDto.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete<RoutineTemplatePlan>(oldTemplate);
    }
  }

  /// Helper methods

  RoutineTemplatePlanDto? templatePlanWhere({required String id}) {
    return _templatePlans.firstWhereOrNull((dto) => dto.id == id);
  }

  void clear() {
    _templatePlans.clear();
  }
}
