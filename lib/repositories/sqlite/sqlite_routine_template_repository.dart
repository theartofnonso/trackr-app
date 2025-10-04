import 'package:tracker_app/database/database_helper.dart';
import 'package:tracker_app/dtos/db/routine_template_dto.dart';
import 'package:tracker_app/logger.dart';
import 'package:tracker_app/repositories/routine_template_repository.dart';

class SqliteRoutineTemplateRepository implements RoutineTemplateRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final logger = getLogger(className: "SqliteRoutineTemplateRepository");

  @override
  Future<List<RoutineTemplateDto>> getTemplates() async {
    try {
      final results = await _dbHelper.query('routine_templates',
          orderBy: 'created_at DESC');
      return results.map((row) => _mapRowToTemplate(row)).toList();
    } catch (e) {
      logger.e("Error getting templates: $e");
      return [];
    }
  }

  @override
  Future<RoutineTemplateDto?> getTemplateById(String id) async {
    try {
      final results = await _dbHelper.query(
        'routine_templates',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isNotEmpty) {
        return _mapRowToTemplate(results.first);
      }
      return null;
    } catch (e) {
      logger.e("Error getting template by id $id: $e");
      return null;
    }
  }

  @override
  Future<RoutineTemplateDto?> saveTemplate(
      {required RoutineTemplateDto templateDto}) async {
    try {
      final values = _mapTemplateToRow(templateDto);
      final id = await _dbHelper.insert('routine_templates', values);

      if (id > 0) {
        logger.i("Template saved successfully: ${templateDto.name}");
        return templateDto;
      }
      return null;
    } catch (e) {
      logger.e("Error saving template: $e");
      return null;
    }
  }

  @override
  Future<RoutineTemplateDto?> updateTemplate(
      {required RoutineTemplateDto template}) async {
    try {
      final values = _mapTemplateToRow(template);
      final rowsAffected = await _dbHelper.update(
        'routine_templates',
        values,
        where: 'id = ?',
        whereArgs: [template.id],
      );

      if (rowsAffected > 0) {
        logger.i("Template updated successfully: ${template.name}");
        return template;
      }
      return null;
    } catch (e) {
      logger.e("Error updating template: $e");
      return null;
    }
  }

  @override
  Future<bool> removeTemplate({required RoutineTemplateDto template}) async {
    try {
      final rowsAffected = await _dbHelper.delete(
        'routine_templates',
        where: 'id = ?',
        whereArgs: [template.id],
      );

      if (rowsAffected > 0) {
        logger.i("Template removed successfully: ${template.name}");
        return true;
      }
      return false;
    } catch (e) {
      logger.e("Error removing template: $e");
      return false;
    }
  }

  RoutineTemplateDto _mapRowToTemplate(Map<String, dynamic> row) {
    return RoutineTemplateDto.fromDatabaseRow(row);
  }

  Map<String, dynamic> _mapTemplateToRow(RoutineTemplateDto template) {
    return template.toDatabaseRow();
  }
}
