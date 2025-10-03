import 'package:tracker_app/database/database_helper.dart';
import 'package:tracker_app/dtos/db/routine_log_dto.dart';
import 'package:tracker_app/logger.dart';
import 'package:tracker_app/repositories/routine_log_repository.dart';

class SqliteRoutineLogRepository implements RoutineLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final logger = getLogger(className: "SqliteRoutineLogRepository");

  @override
  Future<List<RoutineLogDto>> getLogs() async {
    try {
      final results =
          await _dbHelper.query('routine_logs', orderBy: 'created_at DESC');
      return results.map((row) => _mapRowToLog(row)).toList();
    } catch (e) {
      logger.e("Error getting logs: $e");
      return [];
    }
  }

  @override
  Future<RoutineLogDto?> getLogById(String id) async {
    try {
      final results = await _dbHelper.query(
        'routine_logs',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isNotEmpty) {
        return _mapRowToLog(results.first);
      }
      return null;
    } catch (e) {
      logger.e("Error getting log by id $id: $e");
      return null;
    }
  }

  @override
  Future<RoutineLogDto?> saveLog({required RoutineLogDto logDto}) async {
    try {
      final values = _mapLogToRow(logDto);
      final id = await _dbHelper.insert('routine_logs', values);

      if (id > 0) {
        logger.i("Log saved successfully: ${logDto.name}");
        return logDto;
      }
      return null;
    } catch (e) {
      logger.e("Error saving log: $e");
      return null;
    }
  }

  @override
  Future<RoutineLogDto?> updateLog({required RoutineLogDto log}) async {
    try {
      final values = _mapLogToRow(log);
      final rowsAffected = await _dbHelper.update(
        'routine_logs',
        values,
        where: 'id = ?',
        whereArgs: [log.id],
      );

      if (rowsAffected > 0) {
        logger.i("Log updated successfully: ${log.name}");
        return log;
      }
      return null;
    } catch (e) {
      logger.e("Error updating log: $e");
      return null;
    }
  }

  @override
  Future<bool> removeLog({required RoutineLogDto log}) async {
    try {
      final rowsAffected = await _dbHelper.delete(
        'routine_logs',
        where: 'id = ?',
        whereArgs: [log.id],
      );

      if (rowsAffected > 0) {
        logger.i("Log removed successfully: ${log.name}");
        return true;
      }
      return false;
    } catch (e) {
      logger.e("Error removing log: $e");
      return false;
    }
  }

  @override
  Future<List<RoutineLogDto>> getLogsByDateRange(
      {required DateTime startDate, required DateTime endDate}) async {
    try {
      final results = await _dbHelper.query(
        'routine_logs',
        where: 'start_time >= ? AND start_time <= ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'start_time DESC',
      );

      return results.map((row) => _mapRowToLog(row)).toList();
    } catch (e) {
      logger.e("Error getting logs by date range: $e");
      return [];
    }
  }

  @override
  Future<List<RoutineLogDto>> getLogsByTemplateId(
      {required String templateId}) async {
    try {
      final results = await _dbHelper.query(
        'routine_logs',
        where: 'template_id = ?',
        whereArgs: [templateId],
        orderBy: 'start_time DESC',
      );

      return results.map((row) => _mapRowToLog(row)).toList();
    } catch (e) {
      logger.e("Error getting logs by template id $templateId: $e");
      return [];
    }
  }

  RoutineLogDto _mapRowToLog(Map<String, dynamic> row) {
    return RoutineLogDto.fromDatabaseRow(row);
  }

  Map<String, dynamic> _mapLogToRow(RoutineLogDto log) {
    return log.toDatabaseRow();
  }
}
