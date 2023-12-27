import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/models/RoutineTemplate.dart';
import 'package:tracker_app/providers/user_provider.dart';
import '../dtos/exercise_log_dto.dart';

class RoutineTemplateProvider with ChangeNotifier {
  List<RoutineTemplate> _templates = [];

  UnmodifiableListView<RoutineTemplate> get templates => UnmodifiableListView(_templates);

  void listTemplates() async {
    _templates = await Amplify.DataStore.query(RoutineTemplate.classType);
    _templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<RoutineTemplate?> saveTemplate(
      {required BuildContext context,
      required String name,
      required String notes,
      required List<ExerciseLogDto> procedures}) async {
    RoutineTemplate? templateToCreate;

    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null) {
      final exerciseJsons = procedures.map((procedure) => procedure.toJson()).toList();
      templateToCreate = RoutineTemplate(
          name: name,
          exercises: exerciseJsons,
          notes: notes,
          createdAt: TemporalDateTime.now(),
          updatedAt: TemporalDateTime.now(),
          user: user);
      await Amplify.DataStore.save<RoutineTemplate>(templateToCreate);
      _templates.insert(0, templateToCreate);
      notifyListeners();
    }
    return templateToCreate;
  }

  Future<void> updateTemplate({required RoutineTemplate template}) async {
    final request = ModelMutations.update(template);
    final response = await Amplify.API.mutate(request: request).response;
    final updatedRoutineTemplate = response.data;
    if (updatedRoutineTemplate != null) {
      final index = _indexWhereRoutineTemplate(id: template.id);
      _templates[index] = template;
      notifyListeners();
    }
  }

  Future<void> removeTemplate({required String id}) async {
    final index = _indexWhereRoutineTemplate(id: id);
    final templateToBeRemoved = _templates[index];
    final request = ModelMutations.delete(templateToBeRemoved);
    final response = await Amplify.API.mutate(request: request).response;
    final deletedRoutineTemplate = response.data;
    if (deletedRoutineTemplate != null) {
      _templates.removeAt(index);
      notifyListeners();
    }
  }

  int _indexWhereRoutineTemplate({required String id}) {
    return _templates.indexWhere((template) => template.id == id);
  }

  RoutineTemplate? templateWhere({required String id}) {
    return _templates.firstWhereOrNull((dto) => dto.id == id);
  }

  void reset() {
    _templates.clear();
    notifyListeners();
  }
}
