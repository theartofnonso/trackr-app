import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/repositories/amplify_log_repository.dart';
import '../dtos/exercise_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/muscle_group_enums.dart';

class RoutineLogController with ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';

  final AmplifyLogRepository _amplifyLogRepository = AmplifyLogRepository();

  UnmodifiableListView<RoutineLogDto> get routineLogs => _amplifyLogRepository.routineLogs;

  UnmodifiableMapView<DateTimeRange, List<RoutineLogDto>> get weeklyLogs => _amplifyLogRepository.weeklyLogs;

  UnmodifiableMapView<DateTimeRange, List<RoutineLogDto>> get monthlyLogs => _amplifyLogRepository.monthlyLogs;

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogsById => _amplifyLogRepository.exerciseLogsById;

  UnmodifiableMapView<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType => _amplifyLogRepository.exerciseLogsByType;

  void fetchLogs() async {
    isLoading = true;
    try {
      await _amplifyLogRepository.fetchLogs(onDone: () {
        notifyListeners();
      });
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<RoutineLogDto?> saveLog({required RoutineLogDto logDto}) async {
    RoutineLogDto? savedLog;
    isLoading = true;
    try {
      savedLog = await _amplifyLogRepository.saveLog(logDto: logDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
    return savedLog;
  }

  Future<void> updateLog({required RoutineLogDto log}) async {
    isLoading = true;
    try {
      await _amplifyLogRepository.updateLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> removeLog({required RoutineLogDto log}) async {
    isLoading = true;
    try {
      _amplifyLogRepository.removeLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  void cacheLog({required RoutineLogDto logDto}) {
    _amplifyLogRepository.cacheLog(logDto: logDto);
  }

  RoutineLogDto? cachedLog() {
    return _amplifyLogRepository.cachedRoutineLog();
  }

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

  List<SetDto> wherePastSetsForExerciseBefore({required ExerciseDto exercise, required DateTime date}) {
    return _amplifyLogRepository.whereSetsForExerciseBefore(exercise: exercise, date: date);
  }

  List<ExerciseLogDto> wherePastExerciseLogsBefore({required ExerciseDto exercise, required DateTime date}) {
    return _amplifyLogRepository.whereExerciseLogsBefore(exercise: exercise, date: date);
  }

  List<SetDto> whereSetsForExercise({required ExerciseDto exercise}) {
    return _amplifyLogRepository.whereSetsForExercise(exercise: exercise);
  }

  List<SetDto> setsForMuscleGroupWhereDateRange({required MuscleGroupFamily muscleGroupFamily, DateTimeRange? range}) {
    return _amplifyLogRepository.setsForMuscleGroupWhereDateRange(muscleGroupFamily: muscleGroupFamily, range: range);
  }
}
