import 'package:collection/collection.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/routine_editor_type_enums.dart';

class ExerciseLogRepository {
  List<ExerciseLogDto> _exerciseLogs = [];

  Map<String, List<SetDto>> _sets = <String, List<SetDto>>{};

  UnmodifiableListView<ExerciseLogDto> get exerciseLogs => UnmodifiableListView(_exerciseLogs);

  UnmodifiableMapView<String, List<SetDto>> get sets => UnmodifiableMapView(_sets);

  void loadExercises({required List<ExerciseLogDto> logs, required RoutineEditorMode mode}) {
    _exerciseLogs = logs;
    _loadSets(mode: mode);
  }

  void _loadSets({required RoutineEditorMode mode}) {
    for (var exerciseLog in _exerciseLogs) {
      if (withDurationOnly(type: exerciseLog.exercise.type)) {
        if (mode == RoutineEditorMode.log) {
          _sets[exerciseLog.id] = exerciseLog.sets.map((set) => set.copyWith(checked: true)).toList();
          continue;
        } else {
          _sets[exerciseLog.id] = [];
          continue;
        }
      }
      _sets[exerciseLog.id] = exerciseLog.sets;
    }
  }

  List<ExerciseLogDto> mergeExerciseLogsAndSets() {
    return _exerciseLogs.map((exerciseLog) {
      final sets = _sets[exerciseLog.id] ?? [];
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
    final logIndex = _indexWhereExerciseLog(exerciseLogId: logId);
    if (logIndex == -1) {
      return;
    }
    final logToBeRemoved = _exerciseLogs[logIndex];

    if (logToBeRemoved.superSetId.isNotEmpty) {
      _removeSuperSet(superSetId: logToBeRemoved.superSetId);
    }

    final exerciseLogs = List.from(_exerciseLogs);

    exerciseLogs.removeAt(logIndex);

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

    exerciseLogs[oldExerciseLogIndex] = oldExerciseLog.copyWith(exercise: newExercise);

    _exerciseLogs = [...exerciseLogs];
  }

  void _removeAllSetsForExerciseLog({required String exerciseLogId}) {
    // Check if the key exists in the map
    if (!_sets.containsKey(exerciseLogId)) {
      // Handle the case where the key does not exist
      // e.g., log an error or throw an exception
      return;
    }

    // Creating a new map by copying the original map
    Map<String, List<SetDto>> newMap = Map<String, List<SetDto>>.from(_sets);

    // Remove the key-value pair from the new map
    newMap.remove(exerciseLogId);

    // Assign the new map to _sets to maintain immutability
    _sets = newMap;
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

    if (exerciseLogIndex != -1) {
      final currentSets = _sets[exerciseLogId] ?? [];

      int newIndex = currentSets.length;

      SetDto newSet = const SetDto(0, 0, false);

      SetDto? nextSet = currentSets.lastOrNull;
      if (nextSet != null) {
        newSet = nextSet.copyWith(checked: false);
      }

      SetDto? pastSet = _wherePastSetOrNull(index: newIndex, pastSets: pastSets);

      if (pastSet != null) {
        newSet = pastSet.copyWith(checked: false);
      }

      // Clone the old sets for the exerciseId, or create a new list if none exist
      List<SetDto> updatedSets = _sets[exerciseLogId] != null ? List<SetDto>.from(_sets[exerciseLogId]!) : [];

      // Add the new set to the cloned list
      updatedSets.add(newSet);

      // Create a new map by copying all key-value pairs from the original map
      Map<String, List<SetDto>> newMap = Map<String, List<SetDto>>.from(_sets);

      // Update the new map with the modified list of sets
      newMap[exerciseLogId] = updatedSets;

      // Assign the new map to _sets to maintain immutability
      _sets = newMap;
    }
  }

  void removeSet({required String exerciseLogId, required int index}) {
    // Check if the exercise ID exists in the map
    if (!_sets.containsKey(exerciseLogId)) {
      // Handle the case where the exercise ID does not exist
      // e.g., log an error or throw an exception
      return;
    }

    // Clone the old sets for the exercise ID
    List<SetDto> updatedSets = List<SetDto>.from(_sets[exerciseLogId]!);

    // Check if the index is valid
    if (index < 0 || index >= updatedSets.length) {
      // Handle the invalid index
      // e.g., log an error or throw an exception
      return;
    }

    // Remove the set at the specified index
    updatedSets.removeAt(index);

    // Create a new map by copying all key-value pairs from the original map
    Map<String, List<SetDto>> newMap = Map<String, List<SetDto>>.from(_sets);

    // Update the new map with the modified list of sets
    newMap[exerciseLogId] = updatedSets;

    // Assign the new map to _sets to maintain immutability
    _sets = newMap;
  }

  void _updateSet({required String exerciseLogId, required int index, required SetDto updatedSet}) {
    // Check if the exercise ID exists in the map and if the index is valid
    if (!_sets.containsKey(exerciseLogId) || index < 0 || index >= (_sets[exerciseLogId]?.length ?? 0)) {
      // Handle the case where the exercise ID does not exist or index is invalid
      // e.g., log an error or throw an exception
      return;
    }

    // Clone the old sets for the exercise ID
    List<SetDto> updatedSets = List<SetDto>.from(_sets[exerciseLogId]!);

    // Replace the set at the specified index with the updated set
    updatedSets[index] = updatedSet;

    // Create a new map by copying all key-value pairs from the original map
    Map<String, List<SetDto>> newMap = Map<String, List<SetDto>>.from(_sets);

    // Update the new map with the modified list of sets

    newMap[exerciseLogId] = updatedSets;

    _sets = newMap;
  }

  void updateWeight({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSet(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  void updateReps({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSet(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  void updateDuration({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSet(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  void updateSetCheck({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSet(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  /// Helper functions

  ExerciseLogDto _createExerciseLog(ExerciseDto exercise, {String? notes}) {
    return ExerciseLogDto(exercise.id, null, "", exercise, notes ?? "", [], DateTime.now());
  }

  List<SetDto> completedSets() {
    return _sets.values.expand((set) => set).where((set) => set.checked).toList();
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

  ExerciseLogDto? _whereExerciseLog({required String exerciseLogId}) {
    return _exerciseLogs.firstWhereOrNull((exerciseLog) => exerciseLog.id == exerciseLogId);
  }

  void clear() {
    _exerciseLogs = [];
    _sets = <String, List<SetDto>>{};
  }
}
