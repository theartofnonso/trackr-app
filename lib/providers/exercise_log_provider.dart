import 'dart:math';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/unsaved_changes_messages_dto.dart';
import 'package:uuid/uuid.dart';

import '../dtos/exercise_log_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../models/Exercise.dart';

class ExerciseLogProvider extends ChangeNotifier {
  List<ExerciseLogDto> _exerciseLogs = [];

  Map<String, List<SetDto>> _sets = <String, List<SetDto>>{};

  UnmodifiableListView<ExerciseLogDto> get exerciseLogs => UnmodifiableListView(_exerciseLogs);

  UnmodifiableMapView<String, List<SetDto>> get sets => UnmodifiableMapView(_sets);

  void loadExerciseLogs({required List<ExerciseLogDto> logs, bool shouldNotifyListeners = false}) {
    _exerciseLogs = logs;
    _loadSets();
    if (shouldNotifyListeners) {
      notifyListeners();
    }
  }

  void _loadSets() {
    for (var exerciseLog in _exerciseLogs) {
      _sets[exerciseLog.id] = exerciseLog.sets;
    }
  }

  List<ExerciseLogDto> mergeSetsIntoExerciseLogs({updateRoutineSets = false}) {
    // Create a new list to hold the merged exerciseLogs
    List<ExerciseLogDto> mergedLogs = [];

    for (var exerciseLog in _exerciseLogs) {
      // Find the matching sets based on exerciseId and add them to the new exerciseLog
      List<SetDto> matchingSets = _sets[exerciseLog.id] ?? [];

      // Create a new instance of exerciseLogDto with existing data
      ExerciseLogDto newLog;

      if (updateRoutineSets) {
        newLog = exerciseLog.copyWith(sets: matchingSets.map((set) => set.copyWith(checked: false)).toList());
      } else {
        newLog = exerciseLog.copyWith(sets: matchingSets);
      }

      // Add the new exerciseLog to the merged list
      mergedLogs.add(newLog);
    }

    return mergedLogs;
  }

  void addExerciseLogs({required List<Exercise> exercises}) {
    final logsToAdd = exercises.map((exercise) => _createExerciseLog(exercise)).toList();
    _exerciseLogs = [..._exerciseLogs, ...logsToAdd];
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

  SetDto? _wherePastSetOrNull({required String setId, required List<SetDto> pastSets}) {
    return pastSets.firstWhereOrNull((pastSet) => pastSet.id == setId);
  }

  void addSet({required String exerciseLogId, required List<SetDto> pastSets}) {
    int exerciseLogIndex = _indexWhereExerciseLog(exerciseLogId: exerciseLogId);

    if (exerciseLogIndex != -1) {
      final currentSets = _sets[exerciseLogId] ?? [];

      int newIndex = currentSets.isNotEmpty ? currentSets.last.index + 1 : 1;
      SetDto newSet = SetDto(1, 0, 0, SetType.working, false);

      SetDto? nextSet = currentSets.lastOrNull;
      if (nextSet != null) {
        newSet = nextSet.copyWith(index: newIndex, checked: false);
      }

      SetDto? pastSet = _wherePastSetOrNull(setId: newSet.id, pastSets: pastSets);
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
    newMap[exerciseLogId] = updatedSets;//_reOrderSetTypes(currentSets: updatedSets);

    // Assign the new map to _sets to maintain immutability
    _sets = newMap;

    // Notify listeners about the change
    notifyListeners();
  }

  void _updateSetForExerciseLog(
      {required String exerciseLogId,
      required int index,
      required SetDto updatedSet,
      List<SetDto> pastSets = const [],
      bool shouldNotifyListeners = true,
      bool reorder = false}) {
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
    // if (reorder) {
    //   newMap[exerciseLogId] = _reOrderSetTypes(currentSets: updatedSets);
    // } else {
      newMap[exerciseLogId] = updatedSets;
   // }
    _sets = newMap;

    if (shouldNotifyListeners) {
      notifyListeners();
    }
  }

  List<SetDto> _reOrderSetTypes({required List<SetDto> currentSets}) {
    Map<SetType, int> setTypeCounts = {SetType.warmUp: 0, SetType.working: 0, SetType.failure: 0, SetType.drop: 0};
    return currentSets.mapIndexed((index, set) {
      final newIndex = setTypeCounts[set.type]! + 1;
      setTypeCounts[set.type] = setTypeCounts[set.type]! + 1;
      return set.copyWith(index: newIndex, checked: set.checked);
    }).toList();
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

  void updateDistance({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSetForExerciseLog(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  void updateSetType({required String exerciseLogId, required int index, required SetDto setDto, required List<SetDto> pastSets}) {
    _updateSetForExerciseLog(
        exerciseLogId: exerciseLogId, index: index, updatedSet: setDto, pastSets: pastSets, reorder: true);
  }

  void updateSetCheck({required String exerciseLogId, required int index, required SetDto setDto}) {
    _updateSetForExerciseLog(exerciseLogId: exerciseLogId, index: index, updatedSet: setDto);
  }

  void onClearProvider() {
    _exerciseLogs = [];
    _sets = <String, List<SetDto>>{};
  }

  /// Helper functions

  ExerciseLogDto _createExerciseLog(Exercise exercise, {String? notes}) {
    return ExerciseLogDto(const Uuid().v4(), "", "", exercise, notes ?? "", [], TemporalDateTime.now());
  }

  List<SetDto> completedSets() {
    return _sets.values.expand((set) => set).where((set) => set.checked).toList();
  }

  double totalWeight() {
    double totalWeight = 0.0;

    for (var exerciseLog in _exerciseLogs) {
      final exerciseType = ExerciseType.fromString(exerciseLog.exercise.type);

      for (var set in exerciseLog.sets) {
        if (set.checked) {
          double weightPerSet = 0.0;
          if (exerciseType == ExerciseType.weightAndReps || exerciseType == ExerciseType.weightedBodyWeight) {
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

  UnsavedChangesMessageDto? hasDifferentExerciseLogsLength(
      {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2}) {
    final int difference = exerciseLog2.length - exerciseLog1.length;

    if (difference > 0) {
      return UnsavedChangesMessageDto(
          message: "Added $difference exercise(s)", type: UnsavedChangesMessageType.exerciseLogLength);
    } else if (difference < 0) {
      return UnsavedChangesMessageDto(
          message: "Removed ${-difference} exercise(s)", type: UnsavedChangesMessageType.exerciseLogLength);
    }

    return null; // No change in length
  }

  UnsavedChangesMessageDto? hasDifferentSetsLength(
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
        ? UnsavedChangesMessageDto(message: message, type: UnsavedChangesMessageType.setsLength)
        : null;
  }

  UnsavedChangesMessageDto? hasSetTypeChange({
    required List<ExerciseLogDto> exerciseLog1,
    required List<ExerciseLogDto> exerciseLog2,
  }) {
    int changes = 0;

    for (ExerciseLogDto proc1 in exerciseLog1) {
      ExerciseLogDto? matchingProc2 = exerciseLog2.firstWhereOrNull((p) => p.exercise.id == proc1.exercise.id);

      if (matchingProc2 == null) continue;

      int minSetLength = min(proc1.sets.length, matchingProc2.sets.length);
      for (int i = 0; i < minSetLength; i++) {
        if (proc1.sets[i].type != matchingProc2.sets[i].type) {
          changes += 1;
        }
      }
    }

    return changes > 0
        ? UnsavedChangesMessageDto(message: "Changed $changes set type(s)", type: UnsavedChangesMessageType.setType)
        : null;
  }

  UnsavedChangesMessageDto? hasExercisesChanged({
    required List<ExerciseLogDto> exerciseLog1,
    required List<ExerciseLogDto> exerciseLog2,
  }) {
    Set<String> exerciseIds1 = exerciseLog1.map((p) => p.exercise.id).toSet();
    Set<String> exerciseIds2 = exerciseLog2.map((p) => p.exercise.id).toSet();

    int changes = exerciseIds1.difference(exerciseIds2).length;

    return changes > 0
        ? UnsavedChangesMessageDto(
            message: "Changed $changes exercise(s)", type: UnsavedChangesMessageType.exerciseLogChange)
        : null;
  }

  UnsavedChangesMessageDto? hasSuperSetIdChanged({
    required List<ExerciseLogDto> exerciseLog1,
    required List<ExerciseLogDto> exerciseLog2,
  }) {
    Set<String> superSetIds1 =
        exerciseLog1.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();
    Set<String> superSetIds2 =
        exerciseLog2.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();

    final changes = superSetIds2.difference(superSetIds1).length;

    return changes > 0
        ? UnsavedChangesMessageDto(message: "Changed $changes supersets(s)", type: UnsavedChangesMessageType.supersetId)
        : null;
  }

  UnsavedChangesMessageDto? hasSetValueChanged({
    required List<ExerciseLogDto> exerciseLog1,
    required List<ExerciseLogDto> exerciseLog2,
  }) {
    int changes = 0;

    for (ExerciseLogDto proc1 in exerciseLog1) {
      ExerciseLogDto? matchingProc2 = exerciseLog2.firstWhereOrNull((p) => p.exercise.id == proc1.exercise.id);

      if (matchingProc2 == null) continue;

      int minSetLength = min(proc1.sets.length, matchingProc2.sets.length);
      for (int i = 0; i < minSetLength; i++) {
        if ((proc1.sets[i].value1 != matchingProc2.sets[i].value1) ||
            (proc1.sets[i].value2 != matchingProc2.sets[i].value2)) {
          changes += 1;
        }
      }
    }

    return changes > 0
        ? UnsavedChangesMessageDto(message: "Changed $changes set value(s)", type: UnsavedChangesMessageType.setValue)
        : null;
  }

  void reset() {
    _exerciseLogs.clear();
    _sets.clear();
    notifyListeners();
  }
}
