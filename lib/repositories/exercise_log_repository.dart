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
      if (withDurationOnly(type: exerciseLog.exercise.metric)) {
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
      return exerciseLog.copyWith(sets: withDurationOnly(type: exerciseLog.exercise.metric) ? _checkSets(sets) : sets);
    }).toList();
  }

  List<ExerciseLogDto> mergeAndCheckPastExerciseLogsAndSets({required DateTime datetime}) {
    return _exerciseLogs.map((exerciseLog) {
      final sets = _checkSets(exerciseLog.sets);
      return exerciseLog.copyWith(sets: sets, createdAt: datetime);
    }).toList();
  }

  List<SetDto> _checkSets(List<SetDto> sets) {
    return sets.map((set) => set.copyWith(checked: true)).toList();
  }

  void addExerciseLogs({required List<ExerciseDTO> exercises}) {
    final logsToAdd = exercises.map((exercise) => _createExerciseLog(exercise)).toList();
    _exerciseLogs = [..._exerciseLogs, ...logsToAdd];
  }

  void updateExerciseLog({required ExerciseLogDto newExerciseLog}) {
    final exerciseLogIndex = _indexWhereExerciseName(exerciseName: newExerciseLog.exercise.name);

    if (exerciseLogIndex > -1) {

      List<ExerciseLogDto> exerciseLogs = List<ExerciseLogDto>.from(_exerciseLogs);

      exerciseLogs[exerciseLogIndex] = newExerciseLog;

      _exerciseLogs = [...exerciseLogs];

    }
  }

  void reOrderExerciseLogs({required List<ExerciseLogDto> reOrderedList}) {
    _exerciseLogs = reOrderedList;
  }

  void removeExerciseLog({required String exerciseName}) {
    final exerciseLogIndex = _indexWhereExerciseName(exerciseName: exerciseName);
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

    _removeAllSetsForExerciseLog(exerciseName: exerciseName);
  }

  void replaceExercise({required String oldExerciseName, required ExerciseDTO newExercise}) {
    final oldExerciseLogIndex = _indexWhereExerciseName(exerciseName: oldExerciseName);
    final oldExerciseLog = _whereExerciseLog(exerciseName: oldExerciseName);
    if (oldExerciseLogIndex == -1 || oldExerciseLog == null) {
      return;
    }

    List<ExerciseLogDto> exerciseLogs = List<ExerciseLogDto>.from(_exerciseLogs);

    exerciseLogs[oldExerciseLogIndex] = oldExerciseLog.copyWith(exercise: newExercise, sets: []);

    _exerciseLogs = [...exerciseLogs];
  }

  void _removeAllSetsForExerciseLog({required String exerciseName}) {
    // Check if exercise exists
    final exerciseLogIndex = _indexWhereExerciseName(exerciseName: exerciseName);

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

  void updateExerciseLogNotes({required String exerciseName, required String value}) {
    final exerciseLogIndex = _indexWhereExerciseName(exerciseName: exerciseName);
    final exerciseLog = _exerciseLogs[exerciseLogIndex];
    _exerciseLogs[exerciseLogIndex] = exerciseLog.copyWith(notes: value);
  }

  void addSuperSets(
      {required String firstExerciseName, required String secondExerciseName, required String superSetId}) {
    final firstExerciseLogIndex = _indexWhereExerciseName(exerciseName: firstExerciseName);
    final secondExerciseLogIndex = _indexWhereExerciseName(exerciseName: secondExerciseName);

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

  void addSet({required String exerciseName, required List<SetDto> pastSets}) {
    int exerciseLogIndex = _indexWhereExerciseName(exerciseName: exerciseName);

    if (exerciseLogIndex == -1) {
      return;
    }

    final sets = _setsForExerciseLog(exerciseName: exerciseName);

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

  void removeSet({required String exerciseName, required int index}) {
    int exerciseLogIndex = _indexWhereExerciseName(exerciseName: exerciseName);

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

  void _updateSet({required String exerciseName, required int index, required SetDto set}) {
    int exerciseLogIndex = _indexWhereExerciseName(exerciseName: exerciseName);

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

  void updateWeight({required String exerciseName, required int index, required SetDto setDto}) {
    _updateSet(exerciseName: exerciseName, index: index, set: setDto);
  }

  void updateReps({required String exerciseName, required int index, required SetDto setDto}) {
    _updateSet(exerciseName: exerciseName, index: index, set: setDto);
  }

  void updateDuration({required String exerciseName, required int index, required SetDto setDto}) {
    _updateSet(exerciseName: exerciseName, index: index, set: setDto);
  }

  void updateSetCheck({required String exerciseName, required int index, required SetDto setDto}) {
    _updateSet(exerciseName: exerciseName, index: index, set: setDto);
  }

  /// Helper functions

  ExerciseLogDto _createExerciseLog(ExerciseDTO exercise) {
    return ExerciseLogDto(routineLogId: "", superSetId: "", exercise: exercise, notes: "", sets: [], createdAt: DateTime.now(), substituteExercises: []);
  }

  List<ExerciseLogDto> completedExerciseLogs() {
    return _exerciseLogs.where((exercise) {
      final numberOfCompletedSets = exercise.sets.where((set) => set.checked);
      return numberOfCompletedSets.length == exercise.sets.length;
    }).toList();
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

  int _indexWhereExerciseName({required String exerciseName}) {
    return _exerciseLogs.indexWhere((exerciseLog) => exerciseLog.exercise.name == exerciseName);
  }

  List<SetDto> _setsForExerciseLog({required String exerciseName}) {
    final exerciseLogIndex = _indexWhereExerciseName(exerciseName: exerciseName);
    if (exerciseLogIndex == -1) {
      return [];
    }
    final exerciseLog = _exerciseLogs[exerciseLogIndex];
    return exerciseLog.sets;
  }

  ExerciseLogDto? _whereExerciseLog({required String exerciseName}) {
    return _exerciseLogs.firstWhereOrNull((exerciseLog) => exerciseLog.exercise.name == exerciseName);
  }

  List<ExerciseLogDto> _copyExerciseLogs() {
    return List<ExerciseLogDto>.from(_exerciseLogs);
  }

  void clear() {
    _exerciseLogs = [];
  }
}
