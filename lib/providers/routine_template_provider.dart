import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/routine_template_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import '../dtos/routine_template_dto.dart';
import '../shared_prefs.dart';

class RoutineTemplateProvider with ChangeNotifier {
  List<RoutineTemplateDto> _templates = [];

  UnmodifiableListView<RoutineTemplateDto> get templates => UnmodifiableListView(_templates);

  void listTemplates() async {
    final templates = await Amplify.DataStore.query(RoutineTemplate.classType);
    _templates = templates.map((template) => template.dto()).toList();
    _templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<RoutineTemplateDto> saveTemplate({required RoutineTemplateDto templateDto}) async {
    final now = TemporalDateTime.now();

    final templateToCreate = RoutineTemplate(
        data: jsonEncode(templateDto), createdAt: now, updatedAt: now, userId: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineTemplate>(templateToCreate);
    _templates.insert(0, templateDto);
    notifyListeners();

    return templateDto;
  }

  Future<void> updateTemplate({required RoutineTemplateDto template}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineTemplate.ID.eq(template.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      final newTemplate = oldTemplate.copyWith(data: jsonEncode(template));
      await Amplify.DataStore.save(newTemplate);
      final index = _indexWhereRoutineTemplate(id: template.id);
      _templates[index] = template;
      notifyListeners();
    }
  }

  Future<void> removeTemplate({required String id}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineTemplate.ID.eq(id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete(oldTemplate);
      final index = _indexWhereRoutineTemplate(id: id);
      _templates.removeAt(index);
      notifyListeners();
    }
  }

  int _indexWhereRoutineTemplate({required String id}) {
    return _templates.indexWhere((template) => template.id == id);
  }

  RoutineTemplateDto? templateWhere({required String id}) {
    return _templates.firstWhereOrNull((dto) => dto.id == id);
  }

  void reset() {
    _templates.clear();
    notifyListeners();
  }
}
