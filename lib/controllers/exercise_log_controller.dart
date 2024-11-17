import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/exercise_variant_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/routine_editor_type_enums.dart';
import '../repositories/exercise_log_repository.dart';

class ExerciseLogController extends ChangeNotifier {
  late ExerciseLogRepository _exerciseLogRepository;

  ExerciseLogController(ExerciseLogRepository exerciseLogRepository) {
    _exerciseLogRepository = exerciseLogRepository;
  }

  UnmodifiableListView<ExerciseLogDTO> get exerciseLogs => _exerciseLogRepository.exerciseLogs;

  void loadExerciseLogs({required List<ExerciseLogDTO> exerciseLogs, required RoutineEditorMode mode}) {
    _exerciseLogRepository.loadExerciseLogs(exerciseLogs: exerciseLogs, mode: mode);
  }

  List<ExerciseLogDTO> mergeExerciseLogsAndSets() {
    return _exerciseLogRepository.mergeExerciseLogsAndSets();
  }

  List<ExerciseLogDTO> mergeAndCheckExerciseLogsAndSets({required DateTime datetime}) {
    return _exerciseLogRepository.mergeAndCheckPastExerciseLogsAndSets(datetime: datetime);
  }

  void addExerciseLogs({required List<ExerciseVariantDTO> exercisesVariants}) {
    _exerciseLogRepository.addExerciseLogs(exerciseVariants: exercisesVariants);
    notifyListeners();
  }

  void updateExerciseLog({required ExerciseLogDTO newExerciseLog}) {
    _exerciseLogRepository.updateExerciseLog(newExerciseLog: newExerciseLog);
    notifyListeners();
  }

  void reOrderExerciseLogs({required List<ExerciseLogDTO> reOrderedList}) {
    _exerciseLogRepository.reOrderExerciseLogs(reOrderedList: reOrderedList);
    notifyListeners();
  }

  void removeExerciseLog({required String logId}) {
    _exerciseLogRepository.removeExerciseLog(exerciseName: logId);
    notifyListeners();
  }

  void replaceExerciseLog({required String oldExerciseId, required ExerciseVariantDTO newExerciseVariant}) {
    _exerciseLogRepository.replaceExercise(oldExerciseName: oldExerciseId, newExerciseVariant: newExerciseVariant);
    notifyListeners();
  }

  void updateExerciseLogNotes({required String exerciseName, required String value}) {
    _exerciseLogRepository.updateExerciseLogNotes(exerciseName: exerciseName, value: value);
  }

  void superSetExerciseLogs(
      {required String firstExerciseName, required String secondExerciseName, required String superSetId}) {
    _exerciseLogRepository.addSuperSets(
        firstExerciseName: firstExerciseName, secondExerciseName: secondExerciseName, superSetId: superSetId);
    notifyListeners();
  }

  void removeSuperSet({required String superSetId}) {
    _exerciseLogRepository.removeSuperSet(superSetId: superSetId);
    notifyListeners();
  }

  void addSet({required String exerciseName, required List<SetDto> pastSets}) {
    _exerciseLogRepository.addSet(exerciseName: exerciseName, pastSets: pastSets);
    notifyListeners();
  }

  void removeSetForExerciseLog({required String exerciseName, required int index}) {
    _exerciseLogRepository.removeSet(exerciseName: exerciseName, index: index);
    notifyListeners();
  }

  void updateWeight({required String exerciseName, required int index, required SetDto setDto}) {
    _exerciseLogRepository.updateWeight(exerciseName: exerciseName, index: index, setDto: setDto);
    notifyListeners();
  }

  void updateReps({required String exerciseName, required int index, required SetDto setDto}) {
    _exerciseLogRepository.updateReps(exerciseName: exerciseName, index: index, setDto: setDto);
    notifyListeners();
  }

  void updateDuration(
      {required String exerciseName, required int index, required SetDto setDto, required bool notify}) {
    _exerciseLogRepository.updateDuration(exerciseName: exerciseName, index: index, setDto: setDto);
    if (notify) {
      notifyListeners();
    }
  }

  void updateSetCheck({required String exerciseName, required int index, required SetDto setDto}) {
    _exerciseLogRepository.updateSetCheck(exerciseName: exerciseName, index: index, setDto: setDto);
    notifyListeners();
  }

  List<SetDto> completedSets() {
    return _exerciseLogRepository.completedSets();
  }

  List<ExerciseLogDTO> completedExerciseLog() {
    return _exerciseLogRepository.completedExerciseLogs();
  }

  void onClear() {
    _exerciseLogRepository.clear();
  }
}
