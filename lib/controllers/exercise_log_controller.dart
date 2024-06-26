import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/routine_editor_type_enums.dart';
import '../repositories/exercise_log_repository.dart';

class ExerciseLogController extends ChangeNotifier {
  late ExerciseLogRepository _exerciseLogRepository;

  ExerciseLogController(ExerciseLogRepository exerciseLogRepository) {
    _exerciseLogRepository = exerciseLogRepository;
  }

  UnmodifiableListView<ExerciseLogDto> get exerciseLogs => _exerciseLogRepository.exerciseLogs;

  void loadExerciseLogs({required List<ExerciseLogDto> exerciseLogs, required RoutineEditorMode mode}) {
    _exerciseLogRepository.loadExerciseLogs(exerciseLogs: exerciseLogs, mode: mode);
  }

  List<ExerciseLogDto> mergeExerciseLogsAndSets() {
    return _exerciseLogRepository.mergeExerciseLogsAndSets();
  }

  void addExerciseLogs({required List<ExerciseDto> exercises}) {
    _exerciseLogRepository.addExerciseLogs(exercises: exercises);
    notifyListeners();
  }

  void reOrderExerciseLogs({required List<ExerciseLogDto> reOrderedList}) {
    _exerciseLogRepository.reOrderExerciseLogs(reOrderedList: reOrderedList);
    notifyListeners();
  }

  void removeExerciseLog({required String logId}) {
    _exerciseLogRepository.removeExerciseLog(logId: logId);
    notifyListeners();
  }

  void replaceExerciseLog({required String oldExerciseId, required ExerciseDto newExercise}) {
    _exerciseLogRepository.replaceExercise(oldExerciseId: oldExerciseId, newExercise: newExercise);
    notifyListeners();
  }

  void updateExerciseLogNotes({required String exerciseLogId, required String value}) {
    _exerciseLogRepository.updateExerciseLogNotes(exerciseLogId: exerciseLogId, value: value);
  }

  void superSetExerciseLogs(
      {required String firstExerciseLogId, required String secondExerciseLogId, required String superSetId}) {
    _exerciseLogRepository.addSuperSets(
        firstExerciseLogId: firstExerciseLogId, secondExerciseLogId: secondExerciseLogId, superSetId: superSetId);
    notifyListeners();
  }

  void removeSuperSet({required String superSetId}) {
    _exerciseLogRepository.removeSuperSet(superSetId: superSetId);
    notifyListeners();
  }

  void addSet({required String exerciseLogId, required List<SetDto> pastSets}) {
    _exerciseLogRepository.addSet(exerciseLogId: exerciseLogId, pastSets: pastSets);
    notifyListeners();
  }

  void removeSetForExerciseLog({required String exerciseLogId, required int index}) {
    _exerciseLogRepository.removeSet(exerciseLogId: exerciseLogId, index: index);
    notifyListeners();
  }

  void updateWeight({required String exerciseLogId, required int index, required SetDto setDto}) {
    _exerciseLogRepository.updateWeight(exerciseLogId: exerciseLogId, index: index, setDto: setDto);
    notifyListeners();
  }

  void updateReps({required String exerciseLogId, required int index, required SetDto setDto}) {
    _exerciseLogRepository.updateReps(exerciseLogId: exerciseLogId, index: index, setDto: setDto);
    notifyListeners();
  }

  void updateDuration(
      {required String exerciseLogId, required int index, required SetDto setDto, required bool notify}) {
    _exerciseLogRepository.updateDuration(exerciseLogId: exerciseLogId, index: index, setDto: setDto);
    if (notify) {
      notifyListeners();
    }
  }

  void updateSetCheck({required String exerciseLogId, required int index, required SetDto setDto}) {
    _exerciseLogRepository.updateSetCheck(exerciseLogId: exerciseLogId, index: index, setDto: setDto);
    notifyListeners();
  }

  List<SetDto> completedSets() {
    return _exerciseLogRepository.completedSets();
  }

  void onClear() {
    _exerciseLogRepository.clear();
  }
}
