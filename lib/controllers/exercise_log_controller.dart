import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/exercise_variant_dto.dart';
import '../dtos/sets_dtos/set_dto.dart';
import '../enums/exercise/exercise_metrics_enums.dart';
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
    _exerciseLogRepository.removeExerciseLog(exerciseId: logId);
    notifyListeners();
  }

  void replaceExerciseLog({required String oldExerciseId, required ExerciseVariantDTO newExerciseVariant}) {
    _exerciseLogRepository.replaceExercise(oldExerciseName: oldExerciseId, newExerciseVariant: newExerciseVariant);
    notifyListeners();
  }

  void updateExerciseLogNotes({required String exerciseId, required String value}) {
    _exerciseLogRepository.updateExerciseLogNotes(exerciseId: exerciseId, value: value);
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

  void addSet({required String exerciseId, required List<SetDTO> pastSets, required SetType metric}) {
    _exerciseLogRepository.addSet(exerciseId: exerciseId, pastSets: pastSets, metric: metric);
    notifyListeners();
  }

  void removeSetForExerciseLog({required String exerciseId, required int index}) {
    _exerciseLogRepository.removeSet(exerciseId: exerciseId, index: index);
    notifyListeners();
  }

  void updateWeight({required String exerciseId, required int index, required SetDTO setDto}) {
    _exerciseLogRepository.updateWeight(exerciseId: exerciseId, index: index, setDto: setDto);
    notifyListeners();
  }

  void updateReps({required String exerciseId, required int index, required SetDTO setDto}) {
    _exerciseLogRepository.updateReps(exerciseId: exerciseId, index: index, setDto: setDto);
    notifyListeners();
  }

  void updateDuration(
      {required String exerciseId, required int index, required SetDTO setDto, required bool notify}) {
    _exerciseLogRepository.updateDuration(exerciseId: exerciseId, index: index, setDto: setDto);
    if (notify) {
      notifyListeners();
    }
  }

  void updateSetCheck({required String exerciseId, required int index, required SetDTO setDto}) {
    _exerciseLogRepository.updateSetCheck(exerciseId: exerciseId, index: index, setDto: setDto);
    notifyListeners();
  }

  List<SetDTO> completedSets() {
    return _exerciseLogRepository.completedSets();
  }

  List<ExerciseLogDTO> completedExerciseLog() {
    return _exerciseLogRepository.completedExerciseLogs();
  }

  void onClear() {
    _exerciseLogRepository.clear();
  }
}
