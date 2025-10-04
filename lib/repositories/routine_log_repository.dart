import 'package:tracker_app/dtos/db/routine_log_dto.dart';

abstract class RoutineLogRepository {
  Future<List<RoutineLogDto>> getLogs();
  Future<RoutineLogDto?> getLogById(String id);
  Future<RoutineLogDto?> saveLog({required RoutineLogDto logDto});
  Future<RoutineLogDto?> updateLog({required RoutineLogDto log});
  Future<bool> removeLog({required RoutineLogDto log});
  Future<List<RoutineLogDto>> getLogsByDateRange(
      {required DateTime startDate, required DateTime endDate});
  Future<List<RoutineLogDto>> getLogsByTemplateId({required String templateId});
}
