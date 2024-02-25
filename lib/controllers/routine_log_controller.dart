import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/repositories/amplify_log_repository.dart';
import '../dtos/achievement_dto.dart';
import '../dtos/exercise_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../dtos/set_dto.dart';
import '../dtos/untrained_muscle_group_families_notification_dto.dart';
import '../enums/muscle_group_enums.dart';
import '../repositories/achievement_repository.dart';
import '../shared_prefs.dart';
import '../utils/general_utils.dart';

class RoutineLogController extends ChangeNotifier {
  String errorMessage = '';

  late AmplifyLogRepository _amplifyLogRepository;
  late AchievementRepository _achievementRepository;

  RoutineLogController(AmplifyLogRepository amplifyLogRepository, AchievementRepository achievementRepository) {
    _amplifyLogRepository = amplifyLogRepository;
    _achievementRepository = achievementRepository;
  }

  UnmodifiableListView<RoutineLogDto> get routineLogs => _amplifyLogRepository.routineLogs;

  UnmodifiableMapView<DateTimeRange, List<RoutineLogDto>> get weeklyLogs => _amplifyLogRepository.weeklyLogs;

  UnmodifiableMapView<DateTimeRange, List<RoutineLogDto>> get monthlyLogs => _amplifyLogRepository.monthlyLogs;

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogsById => _amplifyLogRepository.exerciseLogsById;

  UnmodifiableMapView<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType =>
      _amplifyLogRepository.exerciseLogsByType;

  UnmodifiableListView<AchievementDto> get achievements => _achievementRepository.achievements;

  List<MuscleGroupFamily> _untrainedMuscleGroupFamilies = [];

  List<MuscleGroupFamily> get untrainedMuscleGroupFamilies => _untrainedMuscleGroupFamilies;

  void fetchLogs() async {
    try {
      await _amplifyLogRepository.fetchLogs(onSyncCompleted: _onSyncCompleted);
      _achievementRepository.loadAchievements(routineLogs: routineLogs);
      _weeklyUntrainedMuscleGroupFamilies();
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
  }

  void _onSyncCompleted() {
    _achievementRepository.loadAchievements(routineLogs: routineLogs);
    notifyListeners();
  }

  Future<RoutineLogDto?> saveLog({required RoutineLogDto logDto}) async {
    RoutineLogDto? savedLog;
    try {
      savedLog = await _amplifyLogRepository.saveLog(logDto: logDto);
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

  List<AchievementDto> fetchAchievements() {
    return _achievementRepository.fetchAchievements(routineLogs: routineLogs);
  }

  List<AchievementDto> calculateNewLogAchievements() {
    return _achievementRepository.calculateNewLogAchievements(routineLogs: routineLogs);
  }

  void _weeklyUntrainedMuscleGroupFamilies() {
    final lastWeeksRange = DateTime.now().lastWeekRange();

    final thisWeeksRange = DateTime.now().currentWeekRange();

    final lastWeeksLogs = _amplifyLogRepository.weeklyLogs[lastWeeksRange] ?? [];

    final thisWeeksLogs = _amplifyLogRepository.weeklyLogs[thisWeeksRange] ?? [];

    final lastWeeksMuscleGroupFamilies = lastWeeksLogs
        .map((log) => log.exerciseLogs)
        .expand((exerciseLogs) => exerciseLogs)
        .map((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup.family)
        .toSet();

    final thisWeeksMuscleGroupFamilies = thisWeeksLogs
        .map((log) => log.exerciseLogs)
        .expand((exerciseLogs) => exerciseLogs)
        .map((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup.family)
        .toSet();

    final listOfPopularMuscleGroupFamilies = popularMuscleGroupFamilies().toSet();

    final lastWeeksUntrainedMuscleGroups = listOfPopularMuscleGroupFamilies.difference(lastWeeksMuscleGroupFamilies);

    final thisWeeksUntrainedMuscleGroups = lastWeeksUntrainedMuscleGroups.difference(thisWeeksMuscleGroupFamilies);

    _untrainedMuscleGroupFamilies = thisWeeksUntrainedMuscleGroups.toList();
  }

  void cacheUntrainedMGFNotification({required UntrainedMGFNotificationDto dto}) {
    SharedPrefs().cachedUntrainedMGFNotification = jsonEncode(dto);
    notifyListeners();
  }

  UntrainedMGFNotificationDto cachedUntrainedMGFNotification() {
    UntrainedMGFNotificationDto dto;
    final cache = SharedPrefs().cachedUntrainedMGFNotification;
    final json = jsonDecode(cache);
    dto = UntrainedMGFNotificationDto.fromJson(json);
    return dto;
  }

  /// Helper methods

  RoutineLogDto? logWhereId({required String id}) {
    return _amplifyLogRepository.logWhereId(id: id);
  }

  RoutineLogDto? logWhereDate({required DateTime dateTime}) {
    return _amplifyLogRepository.logWhereDate(dateTime: dateTime);
  }

  List<RoutineLogDto> logsWhereDate({required DateTime dateTime}) {
    return _amplifyLogRepository.logsWhereDate(dateTime: dateTime);
  }

  List<ExerciseLogDto> exerciseLogsForExercise({required ExerciseDto exercise}) {
    return _amplifyLogRepository.exerciseLogsForExercise(exercise: exercise);
  }

  List<ExerciseLogDto> whereExerciseLogsBefore({required ExerciseDto exercise, required DateTime date}) {
    return _amplifyLogRepository.whereExerciseLogsBefore(exercise: exercise, date: date);
  }

  List<SetDto> whereSetsForExercise({required ExerciseDto exercise}) {
    return _amplifyLogRepository.whereSetsForExercise(exercise: exercise);
  }

  void clear() {
    _amplifyLogRepository.clear();
    notifyListeners();
  }
}
