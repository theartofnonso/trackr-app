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

    final templateToCreate = RoutineTemplate(data: jsonEncode(templateDto.toJson()), createdAt: now, updatedAt: now, userID: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineTemplate>(templateToCreate);
    _templates.insert(0, templateDto);
    notifyListeners();

    return templateDto;
  }

  Future<void> updateTemplate({required RoutineTemplateDto template}) async {
    // final request = ModelMutations.update(template);
    // final response = await Amplify.API.mutate(request: request).response;
    // final updatedRoutineTemplate = response.data;
    // if (updatedRoutineTemplate != null) {
    //   final index = _indexWhereRoutineTemplate(id: template.id);
    //   _templates[index] = template;
    //   notifyListeners();
    // }
  }

  Future<void> removeTemplate({required String id}) async {
    // final index = _indexWhereRoutineTemplate(id: id);
    // final templateToBeRemoved = _templates[index];
    // final request = ModelMutations.delete(templateToBeRemoved);
    // final response = await Amplify.API.mutate(request: request).response;
    // final deletedRoutineTemplate = response.data;
    // if (deletedRoutineTemplate != null) {
    //   _templates.removeAt(index);
    //   notifyListeners();
    // }
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
