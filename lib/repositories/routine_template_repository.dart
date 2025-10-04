import 'package:tracker_app/dtos/db/routine_template_dto.dart';

abstract class RoutineTemplateRepository {
  Future<List<RoutineTemplateDto>> getTemplates();
  Future<RoutineTemplateDto?> getTemplateById(String id);
  Future<RoutineTemplateDto?> saveTemplate(
      {required RoutineTemplateDto templateDto});
  Future<RoutineTemplateDto?> updateTemplate(
      {required RoutineTemplateDto template});
  Future<bool> removeTemplate({required RoutineTemplateDto template});
}
