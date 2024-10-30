import 'dart:collection';

import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/models/RoutineLog.dart';
import 'package:tracker_app/repositories/amplify/amplify_routine_log_repository.dart';

import '../dtos/appsync/exercise_dto.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/set_dto.dart';

class RoutineLogController extends ChangeNotifier {
  String errorMessage = '';

  late AmplifyRoutineLogRepository _amplifyLogRepository;

  RoutineLogController(AmplifyRoutineLogRepository amplifyLogRepository) {
    _amplifyLogRepository = amplifyLogRepository;
  }

  UnmodifiableListView<RoutineLogDto> get logs => _amplifyLogRepository.logs;

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogsById => _amplifyLogRepository.exerciseLogsById;

  UnmodifiableMapView<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType =>
      _amplifyLogRepository.exerciseLogsByType;

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

  /// Helper methods

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
