import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../dtos/appsync/routine_template_dto.dart';

class AmplifyRoutineTemplateRepository {
  List<RoutineTemplateDto> _templates = [];

  UnmodifiableListView<RoutineTemplateDto> get templates => UnmodifiableListView(_templates);

  void loadTemplatesStream({required List<RoutineTemplate> templates}) {
    _templates = templates
        .map((template) => RoutineTemplateDto.toDto(template))
        .toList();
  }

  Future<RoutineTemplateDto> saveTemplate(
      {required RoutineTemplateDto templateDto, RoutineTemplatePlan? templatePlan}) async {
    final now = TemporalDateTime.now();

    final templateToCreate = RoutineTemplate(
        data: jsonEncode(templateDto),
        templatePlan: templatePlan,
        createdAt: now,
        updatedAt: now,
        owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineTemplate>(templateToCreate);

    final updatedWithId = templateDto.copyWith(id: templateToCreate.id, owner: templateToCreate.owner);

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

  /// Helper methods

  RoutineTemplateDto? templateWhere({required String id}) {
    return _templates.firstWhereOrNull((dto) => dto.id == id);
  }

  RoutineTemplateDto? templateByTemplatePlanId({required String id}) {
    return _templates.firstWhereOrNull((dto) => dto.templatePlanDto?.id == id);
  }

  List<RoutineTemplateDto> templatesByTemplatePlanId({required String id}) {
    return _templates.where((dto) => dto.templatePlanDto?.id == id).toList();
  }

  List<RoutineTemplateDto> templatesWithoutTemplatePlanId({required String id}) {
    return _templates.where((dto) => dto.templatePlanDto?.id == id).toList();
  }

  void clear() {
    _templates.clear();
  }
}
