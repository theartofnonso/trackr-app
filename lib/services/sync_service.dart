import 'package:tracker_app/dtos/db/routine_template_dto.dart';
import 'package:tracker_app/dtos/db/routine_plan_dto.dart';
import 'package:tracker_app/dtos/db/routine_log_dto.dart';
import 'package:tracker_app/repositories/sqlite/sqlite_routine_template_repository.dart';
import 'package:tracker_app/repositories/sqlite/sqlite_routine_plan_repository.dart';
import 'package:tracker_app/repositories/sqlite/sqlite_routine_log_repository.dart';
import 'package:tracker_app/services/supabase_service.dart';
import 'package:tracker_app/logger.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline,
}

class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();

  SyncService._();

  final logger = getLogger(className: "SyncService");

  final SupabaseService _supabase = SupabaseService.instance;
  final SqliteRoutineTemplateRepository _templateRepo =
      SqliteRoutineTemplateRepository();
  final SqliteRoutinePlanRepository _planRepo = SqliteRoutinePlanRepository();
  final SqliteRoutineLogRepository _logRepo = SqliteRoutineLogRepository();

  SyncStatus _status = SyncStatus.idle;
  String? _lastError;

  SyncStatus get status => _status;
  String? get lastError => _lastError;

  /// Sync all data to/from Supabase
  Future<void> syncAll() async {
    if (!_supabase.isAuthenticated) {
      _status = SyncStatus.offline;
      return;
    }

    try {
      _status = SyncStatus.syncing;
      _lastError = null;

      // Sync templates
      await _syncTemplates();

      // Sync plans
      await _syncPlans();

      // Sync logs
      await _syncLogs();

      _status = SyncStatus.success;
      logger.i('Sync completed successfully');
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
      logger.e('Sync failed: $e');
      rethrow;
    }
  }

  /// Sync routine templates
  Future<void> _syncTemplates() async {
    try {
      // Get local templates
      final localTemplates = await _templateRepo.getTemplates();

      // Get remote templates
      final response = await _supabase.client
          .from('routine_templates')
          .select()
          .eq('owner', _supabase.currentUser!.id);

      final remoteTemplates = (response as List)
          .map((row) => RoutineTemplateDto.fromDatabaseRow(row))
          .toList();

      // Merge and resolve conflicts
      final mergedTemplates = _mergeTemplates(localTemplates, remoteTemplates);

      // Update local database
      for (final template in mergedTemplates) {
        await _templateRepo.saveTemplate(templateDto: template);
      }

      // Upload new/modified templates to Supabase
      for (final template in localTemplates) {
        if (template.updatedAt.isAfter(template.createdAt)) {
          await _uploadTemplate(template);
        }
      }

      logger.i('Templates synced successfully');
    } catch (e) {
      logger.e('Template sync failed: $e');
      rethrow;
    }
  }

  /// Sync routine plans
  Future<void> _syncPlans() async {
    try {
      // Get local plans
      final localPlans = await _planRepo.getPlans();

      // Get remote plans
      final response = await _supabase.client
          .from('routine_plans')
          .select()
          .eq('owner', _supabase.currentUser!.id);

      final remotePlans = (response as List)
          .map((row) => RoutinePlanDto.fromDatabaseRow(row))
          .toList();

      // Merge and resolve conflicts
      final mergedPlans = _mergePlans(localPlans, remotePlans);

      // Update local database
      for (final plan in mergedPlans) {
        await _planRepo.savePlan(planDto: plan);
      }

      // Upload new/modified plans to Supabase
      for (final plan in localPlans) {
        if (plan.updatedAt.isAfter(plan.createdAt)) {
          await _uploadPlan(plan);
        }
      }

      logger.i('Plans synced successfully');
    } catch (e) {
      logger.e('Plan sync failed: $e');
      rethrow;
    }
  }

  /// Sync routine logs
  Future<void> _syncLogs() async {
    try {
      // Get local logs
      final localLogs = await _logRepo.getLogs();

      // Get remote logs
      final response = await _supabase.client
          .from('routine_logs')
          .select()
          .eq('owner', _supabase.currentUser!.id);

      final remoteLogs = (response as List)
          .map((row) => RoutineLogDto.fromDatabaseRow(row))
          .toList();

      // Merge and resolve conflicts
      final mergedLogs = _mergeLogs(localLogs, remoteLogs);

      // Update local database
      for (final log in mergedLogs) {
        await _logRepo.saveLog(logDto: log);
      }

      // Upload new/modified logs to Supabase
      for (final log in localLogs) {
        if (log.updatedAt.isAfter(log.createdAt)) {
          await _uploadLog(log);
        }
      }

      logger.i('Logs synced successfully');
    } catch (e) {
      logger.e('Log sync failed: $e');
      rethrow;
    }
  }

  /// Merge templates with conflict resolution
  List<RoutineTemplateDto> _mergeTemplates(
    List<RoutineTemplateDto> local,
    List<RoutineTemplateDto> remote,
  ) {
    final Map<String, RoutineTemplateDto> merged = {};

    // Add remote templates
    for (final template in remote) {
      merged[template.id] = template;
    }

    // Add/update with local templates (local wins on conflict)
    for (final template in local) {
      if (!merged.containsKey(template.id) ||
          template.updatedAt.isAfter(merged[template.id]!.updatedAt)) {
        merged[template.id] = template;
      }
    }

    return merged.values.toList();
  }

  /// Merge plans with conflict resolution
  List<RoutinePlanDto> _mergePlans(
    List<RoutinePlanDto> local,
    List<RoutinePlanDto> remote,
  ) {
    final Map<String, RoutinePlanDto> merged = {};

    // Add remote plans
    for (final plan in remote) {
      merged[plan.id] = plan;
    }

    // Add/update with local plans (local wins on conflict)
    for (final plan in local) {
      if (!merged.containsKey(plan.id) ||
          plan.updatedAt.isAfter(merged[plan.id]!.updatedAt)) {
        merged[plan.id] = plan;
      }
    }

    return merged.values.toList();
  }

  /// Merge logs with conflict resolution
  List<RoutineLogDto> _mergeLogs(
    List<RoutineLogDto> local,
    List<RoutineLogDto> remote,
  ) {
    final Map<String, RoutineLogDto> merged = {};

    // Add remote logs
    for (final log in remote) {
      merged[log.id] = log;
    }

    // Add/update with local logs (local wins on conflict)
    for (final log in local) {
      if (!merged.containsKey(log.id) ||
          log.updatedAt.isAfter(merged[log.id]!.updatedAt)) {
        merged[log.id] = log;
      }
    }

    return merged.values.toList();
  }

  /// Upload template to Supabase
  Future<void> _uploadTemplate(RoutineTemplateDto template) async {
    final userId = _supabase.currentUser!.id;
    await _supabase.client
        .from('routine_templates')
        .upsert(template.toSupabaseRow(userId));
  }

  /// Upload plan to Supabase
  Future<void> _uploadPlan(RoutinePlanDto plan) async {
    final userId = _supabase.currentUser!.id;
    await _supabase.client
        .from('routine_plans')
        .upsert(plan.toSupabaseRow(userId));
  }

  /// Upload log to Supabase
  Future<void> _uploadLog(RoutineLogDto log) async {
    final userId = _supabase.currentUser!.id;
    await _supabase.client
        .from('routine_logs')
        .upsert(log.toSupabaseRow(userId));
  }
}
