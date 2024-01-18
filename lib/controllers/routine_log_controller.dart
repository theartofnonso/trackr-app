import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/repositories/amplify_logs_repository.dart';
import '../dtos/exercise_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../dtos/set_dto.dart';

class RoutineLogController with ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';

  final AmplifyLogsRepository _amplifyLogsRepository = AmplifyLogsRepository();
  
  List<RoutineLogDto> get logs => _amplifyLogsRepository.routineLogs;
  
  Map<DateTimeRange, List<RoutineLogDto>> get weeklyLogs => _amplifyLogsRepository.weeklyLogs;
  
  Map<DateTimeRange, List<RoutineLogDto>> get monthlyLogs => _amplifyLogsRepository.monthlyLogs;
  
  Map<String, List<ExerciseLogDto>> get exerciseLogsById => _amplifyLogsRepository.exerciseLogsById;

  Map<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType => _amplifyLogsRepository.exerciseLogsByType;
  
  Future<RoutineLogDto?> saveLog({required RoutineLogDto logDto}) async {
    RoutineLogDto? savedLog;
    isLoading = true;
    try {
      savedLog = await _amplifyLogsRepository.saveLog(logDto: logDto);
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
      await _amplifyLogsRepository.updateLog(log: log);
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
      _amplifyLogsRepository.removeLog(log: log);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  void cacheLog({required RoutineLogDto logDto}) {
    _amplifyLogsRepository.cacheLog(logDto: logDto);
  }

  RoutineLogDto? logWhereId({required String id}) {
    return _amplifyLogsRepository.logWhereId(id: id);
  }

  RoutineLogDto? logWhereDate({required DateTime dateTime}) {
    return _amplifyLogsRepository.logWhereDate(dateTime: dateTime);
  }

  List<RoutineLogDto> logsWhereDate({required DateTime dateTime}) {
    return _amplifyLogsRepository.logsWhereDate(dateTime: dateTime);
  }

  List<ExerciseLogDto> exerciseLogsForExercise({required ExerciseDto exercise}) {
    return _amplifyLogsRepository.exerciseLogsForExercise(exercise: exercise);
  }

  List<SetDto> wherePastSetsForExerciseBefore({required ExerciseDto exercise, required DateTime date}) {
    return _amplifyLogsRepository.whereSetsForExerciseBefore(exercise: exercise, date: date);
  }

  List<ExerciseLogDto> wherePastExerciseLogsBefore({required ExerciseDto exercise, required DateTime date}) {
    return _amplifyLogsRepository.whereExerciseLogsBefore(exercise: exercise, date: date);
  }

  List<SetDto> whereSetsForExercise({required ExerciseDto exercise}) {
    return _amplifyLogsRepository.whereSetsForExercise(exercise: exercise);
  }
}
