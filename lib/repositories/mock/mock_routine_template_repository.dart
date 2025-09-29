import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';

class MockRoutineTemplateRepository {
  List<RoutineTemplateDto> _templates = [];

  UnmodifiableListView<RoutineTemplateDto> get templates =>
      UnmodifiableListView(_templates);

  void loadTemplates({required List<RoutineTemplateDto> templates}) {
    _templates = templates;
  }

  Future<RoutineTemplateDto> saveTemplate(
      {required RoutineTemplateDto templateDto}) async {
    final id = templateDto.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : templateDto.id;
    final created = templateDto.copyWith(
        id: id, createdAt: DateTime.now(), updatedAt: DateTime.now());
    _templates = [created, ..._templates];
    return created;
  }

  Future<void> updateTemplate({required RoutineTemplateDto template}) async {
    _templates = _templates
        .map((t) => t.id == template.id
            ? template.copyWith(updatedAt: DateTime.now())
            : t)
        .toList();
  }

  Future<void> removeTemplate({required RoutineTemplateDto template}) async {
    _templates = _templates.where((t) => t.id != template.id).toList();
  }

  RoutineTemplateDto? templateWhere({required String id}) {
    return _templates.firstWhereOrNull((dto) => dto.id == id);
  }

  RoutineTemplateDto? templateWherePlanId({required String id}) {
    return _templates.firstWhereOrNull((dto) => dto.planId == id);
  }

  void clear() {
    _templates.clear();
  }
}
