import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/repositories/routine_log_repository.dart';
import 'package:tracker_app/repositories/routine_plan_repository.dart';
import 'package:tracker_app/repositories/routine_template_repository.dart';

import '../dtos/db/exercise_dto.dart';
import '../dtos/db/routine_log_dto.dart';
import '../dtos/db/routine_plan_dto.dart';
import '../dtos/db/routine_template_dto.dart';
import '../dtos/set_dtos/set_dto.dart';
import '../logger.dart';

class ExerciseAndRoutineController extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';

  final logger = getLogger(className: "ExerciseAndRoutineController");

  late RoutineTemplateRepository _templateRepository;
  late RoutinePlanRepository _planRepository;
  late RoutineLogRepository _logRepository;

  // Data storage
  List<RoutineTemplateDto> _templates = [];
  List<RoutinePlanDto> _plans = [];
  List<RoutineLogDto> _logs = [];

  ExerciseAndRoutineController(
      {required RoutineTemplateRepository templateRepository,
      required RoutinePlanRepository planRepository,
      required RoutineLogRepository logRepository}) {
    _templateRepository = templateRepository;
    _planRepository = planRepository;
    _logRepository = logRepository;

    // Load initial data
    _loadInitialData();
  }

  UnmodifiableListView<RoutineTemplateDto> get templates =>
      UnmodifiableListView(_templates);

  UnmodifiableListView<RoutinePlanDto> get plans =>
      UnmodifiableListView(_plans);

  UnmodifiableListView<RoutineLogDto> get logs => UnmodifiableListView(_logs);

  // Simplified getters for now - these would need to be implemented based on your needs
  UnmodifiableMapView<String, List<ExerciseLogDto>>
      get exerciseLogsByExerciseId => UnmodifiableMapView({});

  UnmodifiableMapView<MuscleGroup, List<ExerciseLogDto>>
      get exerciseLogsByMuscleGroup => UnmodifiableMapView({});

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadTemplates(),
      _loadPlans(),
      _loadLogs(),
    ]);
  }

  /// Public method to refresh all data from SQLite
  Future<void> refreshData() async {
    await _loadInitialData();
  }

  Future<void> _loadTemplates() async {
    try {
      _templates = await _templateRepository.getTemplates();
      notifyListeners();
    } catch (e) {
      logger.e("Error loading templates: $e");
    }
  }

  Future<void> _loadPlans() async {
    try {
      _plans = await _planRepository.getPlans();
      notifyListeners();
    } catch (e) {
      logger.e("Error loading plans: $e");
    }
  }

  Future<void> _loadLogs() async {
    try {
      _logs = await _logRepository.getLogs();
      notifyListeners();
    } catch (e) {
      logger.e("Error loading logs: $e");
    }
  }

  /// Find exercise logs by name from workout logs
  List<ExerciseLogDto> whereExerciseLogsBefore(
      {required ExerciseDto exercise, required DateTime date}) {
    final List<ExerciseLogDto> matchingLogs = [];

    for (final log in _logs) {
      for (final exerciseLog in log.exerciseLogs) {
        if (exerciseLog.exercise.name.toLowerCase() ==
                exercise.name.toLowerCase() &&
            exerciseLog.createdAt.isBefore(date)) {
          matchingLogs.add(exerciseLog);
        }
      }
    }

    return matchingLogs;
  }

  /// Find recent sets for an exercise by name from workout logs
  List<SetDto> whereRecentSetsForExercise({required ExerciseDto exercise}) {
    final List<MapEntry<SetDto, DateTime>> recentSetsWithDates = [];

    for (final log in _logs) {
      for (final exerciseLog in log.exerciseLogs) {
        if (exerciseLog.exercise.name.toLowerCase() ==
            exercise.name.toLowerCase()) {
          for (final set in exerciseLog.sets) {
            recentSetsWithDates.add(MapEntry(set, exerciseLog.createdAt));
          }
        }
      }
    }

    // Sort by exercise log creation date (most recent first) and take the most recent sets
    recentSetsWithDates.sort((a, b) => b.value.compareTo(a.value));
    return recentSetsWithDates.take(10).map((entry) => entry.key).toList();
  }

  /// Find previous sets for an exercise by name from workout logs
  List<SetDto> wherePrevSetsForExercise(
      {required ExerciseDto exercise, int? take}) {
    final List<MapEntry<SetDto, DateTime>> previousSetsWithDates = [];

    for (final log in _logs) {
      for (final exerciseLog in log.exerciseLogs) {
        if (exerciseLog.exercise.name.toLowerCase() ==
            exercise.name.toLowerCase()) {
          for (final set in exerciseLog.sets) {
            previousSetsWithDates.add(MapEntry(set, exerciseLog.createdAt));
          }
        }
      }
    }

    // Sort by exercise log creation date (most recent first)
    previousSetsWithDates.sort((a, b) => b.value.compareTo(a.value));

    // Return the specified number of sets, or all if take is null
    final sets = previousSetsWithDates.map((entry) => entry.key).toList();
    return take != null ? sets.take(take).toList() : sets;
  }

  /// Find workout templates that contain a specific exercise by name
  /// If exerciseName is empty, returns all templates
  List<RoutineTemplateDto> findTemplatesContainingExercise(
      {required String exerciseName}) {
    if (exerciseName.isEmpty) {
      // Return all templates sorted by creation date (most recent first)
      final allTemplates = List<RoutineTemplateDto>.from(_templates);
      allTemplates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allTemplates;
    }

    final List<RoutineTemplateDto> matchingTemplates = [];

    for (final template in _templates) {
      for (final exerciseTemplate in template.exerciseTemplates) {
        if (exerciseTemplate.exercise.name.toLowerCase() ==
            exerciseName.toLowerCase()) {
          matchingTemplates.add(template);
          break; // Found this template, no need to check other exercises
        }
      }
    }

    // Sort by creation date (most recent first)
    matchingTemplates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matchingTemplates;
  }

  Future<RoutinePlanDto?> savePlan({required RoutinePlanDto planDto}) async {
    RoutinePlanDto? savedPlan;
    isLoading = true;
    try {
      savedPlan = await _planRepository.savePlan(planDto: planDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error saving exercise template", error: e);
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
    return savedPlan;
  }

  Future<void> updatePlan({required RoutinePlanDto planDto}) async {
    isLoading = true;
    try {
      await _planRepository.updatePlan(plan: planDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error updating exercise template", error: e);
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> removePlan({required RoutinePlanDto planDto}) async {
    isLoading = true;
    try {
      await _planRepository.removePlan(plan: planDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error removing exercise template", error: e);
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  /// Templates

  // Streams removed

  Future<RoutineTemplateDto?> saveTemplate(
      {required RoutineTemplateDto templateDto}) async {
    RoutineTemplateDto? savedTemplate;
    isLoading = true;
    try {
      savedTemplate =
          await _templateRepository.saveTemplate(templateDto: templateDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error saving exercise template", error: e);
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
    return savedTemplate;
  }

  Future<void> updateTemplate({required RoutineTemplateDto template}) async {
    isLoading = true;
    try {
      await _templateRepository.updateTemplate(template: template);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error updating exercise template", error: e);
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> removeTemplate({required RoutineTemplateDto template}) async {
    isLoading = true;
    try {
      await _templateRepository.removeTemplate(template: template);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error removing exercise template", error: e);
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  /// Logs
  // Streams removed

  Future<RoutineLogDto?> saveLog(
      {required RoutineLogDto logDto, DateTime? datetime}) async {
    RoutineLogDto? savedLog;
    try {
      savedLog = await _logRepository.saveLog(logDto: logDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error saving log exercise", error: e);
    } finally {
      notifyListeners();
    }
    return savedLog;
  }

  Future<void> updateLog({required RoutineLogDto log}) async {
    try {
      await _logRepository.updateLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error update log", error: e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeLog({required RoutineLogDto log}) async {
    try {
      await _logRepository.removeLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error remove log", error: e);
    } finally {
      notifyListeners();
    }
  }

  /// Logs Helper methods - Simplified versions using in-memory data

  RoutineLogDto? logWhereId({required String id}) {
    try {
      return _logs.firstWhere((log) => log.id == id);
    } catch (e) {
      return null;
    }
  }

  RoutineLogDto? whereLogIsSameDay({required DateTime dateTime}) {
    try {
      return _logs.firstWhere((log) =>
          log.startTime.year == dateTime.year &&
          log.startTime.month == dateTime.month &&
          log.startTime.day == dateTime.day);
    } catch (e) {
      return null;
    }
  }

  RoutineLogDto? whereLogIsSameMonth({required DateTime dateTime}) {
    try {
      return _logs.firstWhere((log) =>
          log.startTime.year == dateTime.year &&
          log.startTime.month == dateTime.month);
    } catch (e) {
      return null;
    }
  }

  RoutineLogDto? whereLogIsSameYear({required DateTime dateTime}) {
    try {
      return _logs.firstWhere((log) => log.startTime.year == dateTime.year);
    } catch (e) {
      return null;
    }
  }

  List<RoutineLogDto> whereLogsIsSameDay({required DateTime dateTime}) {
    return _logs
        .where((log) =>
            log.startTime.year == dateTime.year &&
            log.startTime.month == dateTime.month &&
            log.startTime.day == dateTime.day)
        .toList();
  }

  List<RoutineLogDto> whereLogsIsSameMonth({required DateTime dateTime}) {
    return _logs
        .where((log) =>
            log.startTime.year == dateTime.year &&
            log.startTime.month == dateTime.month)
        .toList();
  }

  List<RoutineLogDto> whereLogsIsSameYear({required DateTime dateTime}) {
    return _logs.where((log) => log.startTime.year == dateTime.year).toList();
  }

  List<RoutineLogDto> whereLogsIsWithinRange({required DateTimeRange range}) {
    return _logs
        .where((log) =>
            log.startTime.isAfter(range.start) &&
            log.startTime.isBefore(range.end))
        .toList();
  }

  List<RoutineLogDto> whereLogsWithTemplateId({required String templateId}) {
    return _logs.where((log) => log.templateId == templateId).toList();
  }

  List<RoutineLogDto> whereLogsWithTemplateName(
      {required String templateName}) {
    return _logs.where((log) => log.name == templateName).toList();
  }

  List<RoutineLogDto> whereRoutineLogsBefore(
      {required String templateId, required DateTime datetime}) {
    return _logs
        .where((log) =>
            log.templateId == templateId && log.startTime.isBefore(datetime))
        .toList();
  }

  /// Template Helpers methods
  RoutineTemplateDto? templateWhere({required String id}) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Plan Helpers methods
  RoutinePlanDto? planWhere({required String id}) {
    try {
      return _plans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }

  void clear() {
    _templates.clear();
    _plans.clear();
    _logs.clear();
    notifyListeners();
  }
}
