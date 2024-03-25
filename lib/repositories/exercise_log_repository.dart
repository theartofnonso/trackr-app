import 'package:collection/collection.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/routine_editor_type_enums.dart';

class ExerciseLogRepository {
  List<ExerciseLogDto> _exerciseLogs = [];

  UnmodifiableListView<ExerciseLogDto> get exerciseLogs => UnmodifiableListView(_exerciseLogs);

  void loadExerciseLogs({required List<ExerciseLogDto> exerciseLogs, required RoutineEditorMode mode}) {
    List<ExerciseLogDto> logs = [];
    for (var exerciseLog in exerciseLogs) {
      if (withDurationOnly(type: exerciseLog.exercise.type)) {
        if (mode == RoutineEditorMode.log) {
          final checkedSets = exerciseLog.sets.map((set) => set.copyWith(checked: true)).toList();
          final updatedExerciseLog = exerciseLog.copyWith(sets: checkedSets);
          logs.add(updatedExerciseLog);
          continue;
        } else {
          final updatedExerciseLog = exerciseLog.copyWith(sets: []);
          logs.add(updatedExerciseLog);
          continue;
        }
      }
      logs.add(exerciseLog);
    }
    _exerciseLogs = logs;
  }

  List<ExerciseLogDto> mergeExerciseLogsAndSets() {
    return _exerciseLogs.map((exerciseLog) {
      final sets = exerciseLog.sets;
      return exerciseLog.copyWith(sets: withDurationOnly(type: exerciseLog.exercise.type) ? _checkSets(sets) : sets);
    }).toList();
  }

  List<SetDto> _checkSets(List<SetDto> sets) {
    return sets.map((set) => set.copyWith(checked: true)).toList();
  }

  void addExerciseLogs({required List<ExerciseDto> exercises}) {
    final logsToAdd = exercises.map((exercise) => _createExerciseLog(exercise)).toList();
    _exerciseLogs = [..._exerciseLogs, ...logsToAdd];
  }

  void reOrderExerciseLogs({required List<ExerciseLogDto> reOrderedList}) {
    _exerciseLogs = reOrderedList;
  }

  void removeExerciseLog({required String logId}) {
    final exerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: logId);
    if (exerciseLogIndex == -1) {
      return;
    }
    final logToBeRemoved = _exerciseLogs[exerciseLogIndex];

    if (logToBeRemoved.superSetId.isNotEmpty) {
      _removeSuperSet(superSetId: logToBeRemoved.superSetId);
    }

    final exerciseLogs = List.from(_exerciseLogs);

    exerciseLogs.removeAt(exerciseLogIndex);

    _exerciseLogs = [...exerciseLogs];

    _removeAllSetsForExerciseLog(exerciseLogId: logId);
  }

  void replaceExercise({required String oldExerciseId, required ExerciseDto newExercise}) {
    final oldExerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: oldExerciseId);
    final oldExerciseLog = _whereExerciseLog(exerciseLogId: oldExerciseId);
    if (oldExerciseLogIndex == -1 || oldExerciseLog == null) {
      return;
    }

    List<ExerciseLogDto> exerciseLogs = List<ExerciseLogDto>.from(_exerciseLogs);

    exerciseLogs[oldExerciseLogIndex] = oldExerciseLog.copyWith(id: newExercise.id, exercise: newExercise);

    _exerciseLogs = [...exerciseLogs];
  }

  void _removeAllSetsForExerciseLog({required String exerciseLogId}) {
    // Check if exercise exists
    final exerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: exerciseLogId);

    if (exerciseLogIndex == -1) {
      return;
    }

    // Creating a new list by copying the original list
    List<ExerciseLogDto> newExerciseLogs = _copyExerciseLogs();

    final exerciseLog = newExerciseLogs[exerciseLogIndex];
    newExerciseLogs[exerciseLogIndex] = exerciseLog.copyWith(sets: []);

    // Assign the new list to maintain immutability
    _exerciseLogs = newExerciseLogs;
  }

  void updateExerciseLogNotes({required String exerciseLogId, required String value}) {
    final exerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: exerciseLogId);
    final exerciseLog = _exerciseLogs[exerciseLogIndex];
    _exerciseLogs[exerciseLogIndex] = exerciseLog.copyWith(notes: value);
  }

  void addSuperSets(
      {required String firstExerciseLogId, required String secondExerciseLogId, required String superSetId}) {
    final firstExerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: firstExerciseLogId);
    final secondExerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: secondExerciseLogId);

    if (firstExerciseLogIndex == -1 && secondExerciseLogIndex == -1) {
      return;
    }
    List<ExerciseLogDto> updatedExerciseLogs = List<ExerciseLogDto>.from(_exerciseLogs);

    updatedExerciseLogs[firstExerciseLogIndex] =
        updatedExerciseLogs[firstExerciseLogIndex].copyWith(superSetId: superSetId);
    updatedExerciseLogs[secondExerciseLogIndex] =
        updatedExerciseLogs[secondExerciseLogIndex].copyWith(superSetId: superSetId);

    final reorderedLogs = _reOrderSuperSets(oldExerciseLogs: updatedExerciseLogs);

    _exerciseLogs = [...reorderedLogs];
  }

  void removeSuperSet({required String superSetId}) {
    _removeSuperSet(superSetId: superSetId);
  }

  SetDto? _wherePastSetOrNull({required int index, required List<SetDto> pastSets}) {
    return pastSets.firstWhereIndexedOrNull((i, set) => index == i);
  }

  void addSet({required String exerciseLogId, required List<SetDto> pastSets}) {
    int exerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: exerciseLogId);

    if (exerciseLogIndex == -1) {
      return;
    }

    final sets = _setsForExerciseLog(exerciseLogId: exerciseLogId);

    int newIndex = sets.length;

    SetDto newSet = sets.lastOrNull != null ? sets.last.copyWith(checked: false) : const SetDto(0, 0, false);

    SetDto? pastSet = _wherePastSetOrNull(index: newIndex, pastSets: pastSets);

    if (pastSet != null) {
      newSet = pastSet.copyWith(checked: false);
    }

    sets.add(newSet);

    // Creating a new list by copying the original list
    List<ExerciseLogDto> newExerciseLogs = _copyExerciseLogs();

    // Updating the exerciseLog
    final exerciseLog = newExerciseLogs[exerciseLogIndex];
    newExerciseLogs[exerciseLogIndex] = exerciseLog.copyWith(sets: sets);

    // Assign the new list to maintain immutability
    _exerciseLogs = newExerciseLogs;
  }

  void removeSet({required String exerciseLogId, required int index}) {
    int exerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: exerciseLogId);

    if (exerciseLogIndex == -1) {
      return;
    }

    // Creating a new list by copying the original list
    List<ExerciseLogDto> newExerciseLogs = _copyExerciseLogs();

    // Updating the exerciseLog
    final exerciseLog = newExerciseLogs[exerciseLogIndex];
    final sets =  exerciseLog.sets;
    if (index >= 0 || index < sets.length) {
      sets.removeAt(index);

      newExerciseLogs[exerciseLogIndex] = exerciseLog.copyWith(sets: sets);

      // Assign the new list to maintain immutability
      _exerciseLogs = newExerciseLogs;
    }

  }

  void _updateSet({required String exerciseLogId, required int index, required SetDto set}) {
    int exerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: exerciseLogId);

    if (exerciseLogIndex == -1) {
      return;
    }

    // Creating a new list by copying the original list
    List<ExerciseLogDto> newExerciseLogs = _copyExerciseLogs();

    // Updating the exerciseLog
    final exerciseLog = newExerciseLogs[exerciseLogIndex];
    final sets =  exerciseLog.sets;
    if (index >= 0 || index < sets.length) {
      sets[index] = set;

      newExerciseLogs[exerciseLogIndex] = exerciseLog.copyWith(sets: sets);

      // Assign the new list to maintain immutability
      _exerciseLogs = newExerciseLogs;
    }
  }

  void updateWeight({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSet(exerciseLogId: exerciseLogId, index: index, set: setDto);
  }

  void updateReps({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSet(exerciseLogId: exerciseLogId, index: index, set: setDto);
  }

  void updateDuration({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSet(exerciseLogId: exerciseLogId, index: index, set: setDto);
  }

  void updateSetCheck({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSet(exerciseLogId: exerciseLogId, index: index, set: setDto);
  }

  /// Helper functions

  ExerciseLogDto _createExerciseLog(ExerciseDto exercise, {String? notes}) {
    return ExerciseLogDto(exercise.id, null, "", exercise, notes ?? "", [], DateTime.now());
  }

  List<SetDto> completedSets() {
    return _exerciseLogs.expand((exerciseLog) => exerciseLog.sets).where((set) => set.checked).toList();
  }

  void _removeSuperSet({required String superSetId}) {
    // Create a new list where modifications will be made
    List<ExerciseLogDto> updatedExerciseLogs = [];

    // Iterate over the original exerciseLogs list
    for (ExerciseLogDto exerciseLog in _exerciseLogs) {
      if (exerciseLog.superSetId == superSetId) {
        // Create a new exerciseLogDto with an updated superSetId
        updatedExerciseLogs.add(exerciseLog.copyWith(superSetId: ""));
      } else {
        // Add the original exerciseLogDto to the new list
        updatedExerciseLogs.add(exerciseLog);
      }
    }

    // Update the _exerciseLogs with the new list
    _exerciseLogs = updatedExerciseLogs;
  }

  Iterable<ExerciseLogDto> _reOrderSuperSets({required List<ExerciseLogDto> oldExerciseLogs}) {
    Set<ExerciseLogDto> reorderedLogs = {};
    for (final exerciseLog in oldExerciseLogs) {
      if (exerciseLog.superSetId.isEmpty) {
        reorderedLogs.add(exerciseLog);
      } else {
        final logs = oldExerciseLogs.where((log) => log.superSetId == exerciseLog.superSetId).toList();
        reorderedLogs.addAll(logs);
        continue;
      }
    }
    return reorderedLogs;
  }

  int _indexWhereExerciseLog({required String exerciseLogId}) {
    return _exerciseLogs.indexWhere((exerciseLog) => exerciseLog.id == exerciseLogId);
  }

  List<SetDto> _setsForExerciseLog({required String exerciseLogId}) {
    final exerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: exerciseLogId);
    if (exerciseLogIndex == -1) {
      return [];
    }
    final exerciseLog = _exerciseLogs[exerciseLogIndex];
    return exerciseLog.sets;
  }

  ExerciseLogDto? _whereExerciseLog({required String exerciseLogId}) {
    return _exerciseLogs.firstWhereOrNull((exerciseLog) => exerciseLog.id == exerciseLogId);
  }

  List<ExerciseLogDto> _copyExerciseLogs() {
    return List<ExerciseLogDto>.from(_exerciseLogs);
  }

  void clear() {
    _exerciseLogs = [];
  }
}
