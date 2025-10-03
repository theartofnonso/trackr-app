import 'package:tracker_app/database/database_helper.dart';
import 'package:tracker_app/dtos/db/routine_plan_dto.dart';
import 'package:tracker_app/logger.dart';
import 'package:tracker_app/repositories/routine_plan_repository.dart';

class SqliteRoutinePlanRepository implements RoutinePlanRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final logger = getLogger(className: "SqliteRoutinePlanRepository");

  @override
  Future<List<RoutinePlanDto>> getPlans() async {
    try {
      final results =
          await _dbHelper.query('routine_plans', orderBy: 'name ASC');
      return results.map((row) => _mapRowToPlan(row)).toList();
    } catch (e) {
      logger.e("Error getting plans: $e");
      return [];
    }
  }

  @override
  Future<RoutinePlanDto?> getPlanById(String id) async {
    try {
      final results = await _dbHelper.query(
        'routine_plans',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isNotEmpty) {
        return _mapRowToPlan(results.first);
      }
      return null;
    } catch (e) {
      logger.e("Error getting plan by id $id: $e");
      return null;
    }
  }

  @override
  Future<RoutinePlanDto?> savePlan({required RoutinePlanDto planDto}) async {
    try {
      final values = _mapPlanToRow(planDto);
      final id = await _dbHelper.insert('routine_plans', values);

      if (id > 0) {
        logger.i("Plan saved successfully: ${planDto.name}");
        return planDto;
      }
      return null;
    } catch (e) {
      logger.e("Error saving plan: $e");
      return null;
    }
  }

  @override
  Future<RoutinePlanDto?> updatePlan({required RoutinePlanDto plan}) async {
    try {
      final values = _mapPlanToRow(plan);
      final rowsAffected = await _dbHelper.update(
        'routine_plans',
        values,
        where: 'id = ?',
        whereArgs: [plan.id],
      );

      if (rowsAffected > 0) {
        logger.i("Plan updated successfully: ${plan.name}");
        return plan;
      }
      return null;
    } catch (e) {
      logger.e("Error updating plan: $e");
      return null;
    }
  }

  @override
  Future<bool> removePlan({required RoutinePlanDto plan}) async {
    try {
      final rowsAffected = await _dbHelper.delete(
        'routine_plans',
        where: 'id = ?',
        whereArgs: [plan.id],
      );

      if (rowsAffected > 0) {
        logger.i("Plan removed successfully: ${plan.name}");
        return true;
      }
      return false;
    } catch (e) {
      logger.e("Error removing plan: $e");
      return false;
    }
  }

  RoutinePlanDto _mapRowToPlan(Map<String, dynamic> row) {
    return RoutinePlanDto(
      id: row['id'] as String,
      name: row['name'] as String,
      notes: row['notes'] as String,
      templates: [], // Simplified - will be empty for now
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Map<String, dynamic> _mapPlanToRow(RoutinePlanDto plan) {
    return {
      'id': plan.id,
      'name': plan.name,
      'notes': plan.notes,
      'created_at': plan.createdAt.toIso8601String(),
      'updated_at': plan.updatedAt.toIso8601String(),
    };
  }
}
