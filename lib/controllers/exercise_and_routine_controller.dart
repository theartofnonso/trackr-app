import 'dart:collection';

import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/dtos/milestones/milestone_dto.dart';
import 'package:tracker_app/models/RoutineLog.dart';
import 'package:tracker_app/repositories/amplify/amplify_routine_log_repository.dart';

import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/appsync/routine_template_dto.dart';
import '../dtos/appsync/routine_template_plan_dto.dart';
import '../dtos/exercise_dto.dart';
import '../dtos/set_dto.dart';
import '../models/RoutineTemplate.dart';
import '../models/RoutineTemplatePlan.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/amplify/amplify_routine_template_plan_repository.dart';
import '../repositories/amplify/amplify_routine_template_repository.dart';

class ExerciseAndRoutineController extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';

  late ExerciseRepository _amplifyExerciseRepository;
  late AmplifyRoutineTemplateRepository _amplifyTemplateRepository;
  late AmplifyRoutineTemplatePlanRepository _amplifyTemplatePlanRepository;
  late AmplifyRoutineLogRepository _amplifyLogRepository;

  ExerciseAndRoutineController(
      {required ExerciseRepository amplifyExerciseRepository,
      required AmplifyRoutineTemplateRepository amplifyTemplateRepository,
      required AmplifyRoutineLogRepository amplifyLogRepository,
      required AmplifyRoutineTemplatePlanRepository amplifyTemplatePlanRepository}) {
    _amplifyExerciseRepository = amplifyExerciseRepository;
    _amplifyTemplateRepository = amplifyTemplateRepository;
    _amplifyTemplatePlanRepository = amplifyTemplatePlanRepository;
    _amplifyLogRepository = amplifyLogRepository;
  }

  UnmodifiableListView<ExerciseDTO> get exercises => _amplifyExerciseRepository.exercises;

  UnmodifiableListView<RoutineTemplateDto> get templates => _amplifyTemplateRepository.templates;

  UnmodifiableListView<RoutineTemplatePlanDto> get templatePlans => _amplifyTemplatePlanRepository.templatePlans;

  UnmodifiableListView<RoutineLogDto> get logs => _amplifyLogRepository.logs;

  UnmodifiableListView<Milestone> get milestones => _amplifyLogRepository.milestones;

  UnmodifiableListView<Milestone> get pendingMilestones => _amplifyLogRepository.pendingMilestones();

  UnmodifiableListView<Milestone> get completedMilestones => _amplifyLogRepository.completedMilestones();

  UnmodifiableListView<Milestone> get newMilestones => _amplifyLogRepository.newMilestones;

  UnmodifiableMapView<String, List<ExerciseLogDTO>> get exerciseLogsByName => _amplifyLogRepository.exerciseLogsByName;

  /// Exercises
  void loadExercises() {
    _amplifyExerciseRepository.loadExercises();
  }

  /// Templates

  void streamTemplates({required List<RoutineTemplate> templates}) {
    _amplifyTemplateRepository.loadTemplatesStream(templates: templates);
    notifyListeners();
  }

  Future<RoutineTemplateDto?> saveTemplate(
      {required RoutineTemplateDto templateDto, RoutineTemplatePlan? templatePlan}) async {
    RoutineTemplateDto? savedTemplate;
    isLoading = true;
    try {
      savedTemplate =
          await _amplifyTemplateRepository.saveTemplate(templateDto: templateDto, templatePlan: templatePlan);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
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
      await _amplifyTemplateRepository.updateTemplate(template: template);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> removeTemplate({required RoutineTemplateDto template}) async {
    isLoading = true;
    try {
      await _amplifyTemplateRepository.removeTemplate(template: template);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  /// TemplatePlans

  void streamTemplatePlans({required List<RoutineTemplatePlan> templatePlans}) {
    _amplifyTemplatePlanRepository.loadTemplatePlansStream(templatesPlans: templatePlans, onData: () {});
    notifyListeners();
  }

  Future<RoutineTemplatePlan?> saveTemplatePlan({required RoutineTemplatePlanDto templatePlanDto}) async {
    RoutineTemplatePlan? savedTemplatePlan;
    isLoading = true;
    try {
      savedTemplatePlan = await _amplifyTemplatePlanRepository.saveTemplatePlan(templatePlanDto: templatePlanDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
    return savedTemplatePlan;
  }

  Future<void> updateTemplatePlan({required RoutineTemplatePlanDto templatePlan}) async {
    isLoading = true;
    try {
      await _amplifyTemplatePlanRepository.updateTemplatePlan(templatePlanDto: templatePlan);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> removeTemplatePlan({required RoutineTemplatePlanDto templatePlan}) async {
    isLoading = true;
    try {
      await _amplifyTemplatePlanRepository.removeTemplatePlan(templatePlanDto: templatePlan);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  /// Logs

  void streamLogs({required List<RoutineLog> logs}) {
    _amplifyLogRepository.loadLogStream(logs: logs);
    notifyListeners();
  }

  Future<RoutineLogDto?> saveLog({required RoutineLogDto logDto, TemporalDateTime? datetime}) async {
    RoutineLogDto? savedLog;
    try {
      savedLog = await _amplifyLogRepository.saveLog(logDto: logDto, datetime: datetime);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
    return savedLog;
  }

  Future<void> updateLog({required RoutineLogDto log}) async {
    try {
      await _amplifyLogRepository.updateLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeLog({required RoutineLogDto log}) async {
    try {
      await _amplifyLogRepository.removeLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
  }

  void cacheLog({required RoutineLogDto logDto}) {
    _amplifyLogRepository.cacheLog(logDto: logDto);
  }

  RoutineLogDto? cachedLog() {
    return _amplifyLogRepository.cachedRoutineLog();
  }

  /// Logs Helper methods

  RoutineLogDto? logWhereId({required String id}) {
    return _amplifyLogRepository.logWhereId(id: id);
  }

  RoutineLogDto? whereLogIsSameDay({required DateTime dateTime}) {
    return _amplifyLogRepository.whereLogIsSameDay(dateTime: dateTime);
  }

  RoutineLogDto? whereLogIsSameMonth({required DateTime dateTime}) {
    return _amplifyLogRepository.whereLogIsSameMonth(dateTime: dateTime);
  }

  RoutineLogDto? whereLogIsSameYear({required DateTime dateTime}) {
    return _amplifyLogRepository.whereLogIsSameYear(dateTime: dateTime);
  }

  List<RoutineLogDto> whereLogsIsSameDay({required DateTime dateTime}) {
    return _amplifyLogRepository.whereLogsIsSameDay(dateTime: dateTime);
  }

  List<RoutineLogDto> whereLogsIsSameMonth({required DateTime dateTime}) {
    return _amplifyLogRepository.whereLogsIsSameMonth(dateTime: dateTime);
  }

  List<RoutineLogDto> whereLogsIsSameYear({required DateTime dateTime}) {
    return _amplifyLogRepository.whereLogsIsSameYear(dateTime: dateTime);
  }

  List<RoutineLogDto> whereLogsIsWithinRange({required DateTimeRange range}) {
    return _amplifyLogRepository.whereLogsIsWithinRange(range: range);
  }

  List<ExerciseLogDTO> whereExerciseLogsBefore({required ExerciseVariantDTO exerciseVariant, required DateTime date}) {
    return _amplifyLogRepository.whereExerciseLogsBefore(exerciseVariant: exerciseVariant, date: date);
  }

  List<SetDto> whereSetsForExercise({required ExerciseVariantDTO exerciseVariant}) {
    return _amplifyLogRepository.whereSetsForExercise(exerciseVariant: exerciseVariant);
  }

  /// Exercise Helpers methods
  ExerciseDTO whereExercise({required String name}) {
    return _amplifyExerciseRepository.whereExercise(name: name);
  }

  /// Template Helpers methods
  RoutineTemplateDto? templateWhere({required String id}) {
    return _amplifyTemplateRepository.templateWhere(id: id);
  }

  RoutineTemplateDto? templateByTemplatePlanId({required String id}) {
    return _amplifyTemplateRepository.templateByTemplatePlanId(id: id);
  }

  List<RoutineTemplateDto> templatesByTemplatePlanId({required String id}) {
    return _amplifyTemplateRepository.templatesByTemplatePlanId(id: id);
  }

  /// TemplatePlan Helpers methods
  RoutineTemplatePlanDto? templatePlanWhere({required String id}) {
    return _amplifyTemplatePlanRepository.templatePlanWhere(id: id);
  }

  void clear() {
    _amplifyExerciseRepository.clear();
    _amplifyTemplateRepository.clear();
    _amplifyTemplatePlanRepository.clear();
    _amplifyLogRepository.clear();
    notifyListeners();
  }
}
