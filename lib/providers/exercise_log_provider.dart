import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/template_changes_messages_dto.dart';

import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../enums/template_changes_type_message_enums.dart';

class ExerciseLogProvider extends ChangeNotifier {
  List<ExerciseLogDto> _exerciseLogs = [];

  Map<String, List<SetDto>> _sets = <String, List<SetDto>>{};

  UnmodifiableListView<ExerciseLogDto> get exerciseLogs => UnmodifiableListView(_exerciseLogs);

  UnmodifiableMapView<String, List<SetDto>> get sets => UnmodifiableMapView(_sets);

  void loadExercises({required List<ExerciseLogDto> logs, bool shouldNotifyListeners = false}) {
    _exerciseLogs = logs;
    _loadSets();
    if (shouldNotifyListeners) {
      notifyListeners();
    }
  }

  void _loadSets() {
    for (var exerciseLog in _exerciseLogs) {
      if(exerciseLog.exercise.type == ExerciseType.duration) {
        _sets[exerciseLog.id] = [];
      } else {
        _sets[exerciseLog.id] = exerciseLog.sets;
      }
    }
  }

  List<ExerciseLogDto> mergeSetsIntoExerciseLogs({bool includeEmptySets = false}) {
    return _exerciseLogs
        .map((exercise) {
          final sets = _sets[exercise.id] ?? [];
          final hasSets = sets.isNotEmpty;
          if (hasSets || includeEmptySets) {
            return exercise.copyWith(sets: sets);
          }
        })
        .whereType<ExerciseLogDto>()
        .toList();
  }

  void addExerciseLogs({required List<ExerciseDto> exercises}) {
    final logsToAdd = exercises.map((exercise) => _createExerciseLog(exercise)).toList();
    _exerciseLogs = [..._exerciseLogs, ...logsToAdd];
    notifyListeners();
  }

  void reOrderExerciseLogs({required List<ExerciseLogDto> reOrderedList}) {
    _exerciseLogs = reOrderedList;
    notifyListeners();
  }

  void removeExerciseLog({required String logId}) {
    final logIndex = _indexWhereExerciseLog(exerciseLogId: logId);
    if (logIndex != -1) {
      final logToBeRemoved = _exerciseLogs[logIndex];

      if (logToBeRemoved.superSetId.isNotEmpty) {
        _removeSuperSet(superSetId: logToBeRemoved.superSetId);
      }

      final exerciseLogs = List.from(_exerciseLogs);

      exerciseLogs.removeAt(logIndex);

      _exerciseLogs = [...exerciseLogs];

      _removeAllSetsForExerciseLog(exerciseLogId: logId);

      notifyListeners();
    }
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
    notifyListeners();
  }

  void superSetExerciseLogs(
      {required String firstExerciseLogId, required String secondExerciseLogId, required String superSetId}) {
    final firstExerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: firstExerciseLogId);
    final secondExerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: secondExerciseLogId);

    if (firstExerciseLogIndex != -1 && secondExerciseLogIndex != -1) {
      List<ExerciseLogDto> updatedExerciseLogs = List<ExerciseLogDto>.from(_exerciseLogs);

      updatedExerciseLogs[firstExerciseLogIndex] =
          updatedExerciseLogs[firstExerciseLogIndex].copyWith(superSetId: superSetId);
      updatedExerciseLogs[secondExerciseLogIndex] =
          updatedExerciseLogs[secondExerciseLogIndex].copyWith(superSetId: superSetId);

      _exerciseLogs = [...updatedExerciseLogs];

      notifyListeners();
    }
  }

  void removeSuperSetForLogs({required String superSetId}) {
    _removeSuperSet(superSetId: superSetId);
    notifyListeners();
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

      // Notify listeners about the change
      notifyListeners();
    }
  }

  void removeSetForExerciseLog({required String exerciseLogId, required int index}) {
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

    // Notify listeners about the change
    notifyListeners();
  }

  void _updateSetForExerciseLog({required String exerciseLogId, required int index, required SetDto updatedSet}) {
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

    notifyListeners();
  }

  void updateWeight({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSetForExerciseLog(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  void updateReps({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSetForExerciseLog(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  void updateDuration({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSetForExerciseLog(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  void updateSetCheck({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSetForExerciseLog(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  void onClearProvider() {
    _exerciseLogs = [];
    _sets = <String, List<SetDto>>{};
  }

  /// Helper functions

  ExerciseLogDto _createExerciseLog(ExerciseDto exercise, {String? notes}) {
    return ExerciseLogDto(exercise.id, null, "", exercise, notes ?? "", [], DateTime.now());
  }

  List<SetDto> completedSets() {
    return _sets.values.expand((set) => set).where((set) => set.checked).toList();
  }

  double totalWeight() {
    double totalWeight = 0.0;

    for (var exerciseLog in _exerciseLogs) {
      final exerciseType = exerciseLog.exercise.type;

      for (var set in exerciseLog.sets) {
        if (set.checked) {
          double weightPerSet = 0.0;
          if (exerciseType == ExerciseType.weights) {
            weightPerSet = set.value1.toDouble() * set.value2;
          }
          totalWeight += weightPerSet;
        }
      }
    }

    return totalWeight;
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

  int _indexWhereExerciseLog({required String exerciseLogId}) {
    return _exerciseLogs.indexWhere((exerciseLog) => exerciseLog.id == exerciseLogId);
  }

  TemplateChangesMessageDto? hasDifferentExerciseLogsLength(
      {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2}) {
    final int difference = exerciseLog2.length - exerciseLog1.length;

    if (difference > 0) {
      return TemplateChangesMessageDto(
          message: "Added $difference exercise(s)", type: TemplateChangesMessageType.exerciseLogLength);
    } else if (difference < 0) {
      return TemplateChangesMessageDto(
          message: "Removed ${-difference} exercise(s)", type: TemplateChangesMessageType.exerciseLogLength);
    }

    return null; // No change in length
  }

  TemplateChangesMessageDto? hasReOrderedExercises(
      {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2}) {
    final length = exerciseLog1.length > exerciseLog2.length ? exerciseLog2.length : exerciseLog1.length;
    for (int i = 0; i < length; i++) {
      if (exerciseLog1[i].exercise.id != exerciseLog2[i].exercise.id) {
        return TemplateChangesMessageDto(
            message: "Exercises have been re-ordered",
            type: TemplateChangesMessageType.exerciseOrder); // Re-orderedList
      }
    }
    return null;
  }

  TemplateChangesMessageDto? hasDifferentSetsLength(
      {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2}) {
    int addedSetsCount = 0;
    int removedSetsCount = 0;

    for (ExerciseLogDto proc1 in exerciseLog1) {
      ExerciseLogDto? matchingProc2 = exerciseLog2.firstWhereOrNull((p) => p.exercise.id == proc1.exercise.id);

      if (matchingProc2 == null) continue;

      int difference = matchingProc2.sets.length - proc1.sets.length;
      if (difference > 0) {
        addedSetsCount += difference;
      } else if (difference < 0) {
        removedSetsCount -= difference; // Subtracting a negative number to add its absolute value
      }
    }

    String message = '';
    if (addedSetsCount > 0) {
      message = "Added $addedSetsCount set(s)";
    }

    if (removedSetsCount > 0) {
      if (message.isNotEmpty) message += ' and ';
      message += "Removed $removedSetsCount set(s)";
    }

    return message.isNotEmpty
        ? TemplateChangesMessageDto(message: message, type: TemplateChangesMessageType.setsLength)
        : null;
  }

  TemplateChangesMessageDto? hasExercisesChanged({
    required List<ExerciseLogDto> exerciseLog1,
    required List<ExerciseLogDto> exerciseLog2,
  }) {
    Set<String> exerciseIds1 = exerciseLog1.map((p) => p.exercise.id).toSet();
    Set<String> exerciseIds2 = exerciseLog2.map((p) => p.exercise.id).toSet();

    int changes = exerciseIds1.difference(exerciseIds2).length;

    return changes > 0
        ? TemplateChangesMessageDto(
            message: "Changed $changes exercise(s)", type: TemplateChangesMessageType.exerciseLogChange)
        : null;
  }

  TemplateChangesMessageDto? hasSuperSetIdChanged({
    required List<ExerciseLogDto> exerciseLog1,
    required List<ExerciseLogDto> exerciseLog2,
  }) {
    Set<String> superSetIds1 =
        exerciseLog1.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();
    Set<String> superSetIds2 =
        exerciseLog2.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();

    final changes = superSetIds2.difference(superSetIds1).length;

    return changes > 0
        ? TemplateChangesMessageDto(
            message: "Changed $changes supersets(s)", type: TemplateChangesMessageType.supersetId)
        : null;
  }

  void reset() {
    _exerciseLogs.clear();
    _sets.clear();
    notifyListeners();
  }
}
