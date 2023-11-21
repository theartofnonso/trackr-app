import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/unsaved_changes_messages_dto.dart';
import 'package:uuid/uuid.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../models/Exercise.dart';

class ProceduresProvider extends ChangeNotifier {
  List<ProcedureDto> _procedures = [];
  Map<String, List<SetDto>> _sets = <String, List<SetDto>>{};

  UnmodifiableListView<ProcedureDto> get procedures => UnmodifiableListView(_procedures);

  UnmodifiableMapView<String, List<SetDto>> get sets => UnmodifiableMapView(_sets);

  void refreshProcedures({required List<ProcedureDto> procedures}) {
    _procedures = procedures;
    notifyListeners();
  }

  void loadProcedures({required List<String> procedures}) {
    _procedures = procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
    _loadSets();
  }

  void _loadSets() {
    for (var procedure in _procedures) {
      _sets[procedure.id] = procedure.sets;
    }
  }

  List<ProcedureDto> mergeSetsIntoProcedures() {
    // Create a new list to hold the merged procedures
    List<ProcedureDto> mergedProcedures = [];

    for (var procedure in procedures) {
      // Find the matching sets based on exerciseId and add them to the new procedure
      List<SetDto> matchingSets = sets[procedure.id] ?? [];

      // Create a new instance of ProcedureDto with existing data
      ProcedureDto newProcedure = procedure.copyWith(sets: matchingSets);

      // Add the new procedure to the merged list
      mergedProcedures.add(newProcedure);
    }

    return mergedProcedures;
  }

  void addProcedures({required List<Exercise> exercises}) {
    final proceduresToAdd = exercises.map((exercise) => _createProcedure(exercise)).toList();
    _procedures = [..._procedures, ...proceduresToAdd];

    notifyListeners();
  }

  void removeProcedure({required String procedureId}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    if (procedureIndex != -1) {
      final procedureToBeRemoved = _procedures[procedureIndex];

      if (procedureToBeRemoved.superSetId.isNotEmpty) {
        _removeSuperSet(superSetId: procedureToBeRemoved.superSetId);
      }

      final procedures = List.from(_procedures);

      procedures.removeAt(procedureIndex);

      _procedures = [...procedures];

      _removeAllSetsForProcedure(procedureId: procedureId);

      notifyListeners();
    }
  }

  void _removeAllSetsForProcedure({required String procedureId}) {
    // Check if the key exists in the map
    if (!_sets.containsKey(procedureId)) {
      // Handle the case where the key does not exist
      // e.g., log an error or throw an exception
      return;
    }

    // Creating a new map by copying the original map
    Map<String, List<SetDto>> newMap = Map<String, List<SetDto>>.from(_sets);

    // Remove the key-value pair from the new map
    newMap.remove(procedureId);

    // Assign the new map to _sets to maintain immutability
    _sets = newMap;
  }

  void replaceProcedure({required String procedureId, required Exercise exercise}) async {
    // Get the index of the procedure to be replaced
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);

    // Check if the procedure was found
    if (procedureIndex != -1) {
      final procedureToBeReplaced = _procedures[procedureIndex];

      // If the procedure is part of a super set, remove it from the super set
      if (procedureToBeReplaced.superSetId.isNotEmpty) {
        _removeSuperSet(superSetId: procedureToBeReplaced.superSetId);
      }

      final procedures = List.from(_procedures);

      procedures[procedureIndex] = _createProcedure(exercise, notes: procedureToBeReplaced.notes);

      _procedures = [...procedures];

      notifyListeners();
    }
  }

  void updateProcedureNotes({required String procedureId, required String value}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    _procedures[procedureIndex] = procedure.copyWith(notes: value);
  }

  void superSetProcedures(
      {required String firstProcedureId, required String secondProcedureId, required String superSetId}) {
    final firstProcedureIndex = _indexWhereProcedure(procedureId: firstProcedureId);
    final secondProcedureIndex = _indexWhereProcedure(procedureId: secondProcedureId);

    if (firstProcedureIndex != -1 && secondProcedureIndex != -1) {
      List<ProcedureDto> updatedProcedures = List<ProcedureDto>.from(_procedures);

      updatedProcedures[firstProcedureIndex] = updatedProcedures[firstProcedureIndex].copyWith(superSetId: superSetId);
      updatedProcedures[secondProcedureIndex] =
          updatedProcedures[secondProcedureIndex].copyWith(superSetId: superSetId);

      _procedures = [...updatedProcedures];

      notifyListeners();
    }
  }

  void removeProcedureSuperSet({required String superSetId}) {
    _removeSuperSet(superSetId: superSetId);
    notifyListeners();
  }

  SetDto? _wherePastSet({required int index, required SetType type, required List<SetDto> pastSets}) {
    final workingSets = pastSets.where((set) => set.type == type).toList();
    return workingSets.length >= index ? workingSets.lastOrNull : null;
  }

  void addSetForProcedure({required String procedureId, required List<SetDto> pastSets}) {
    int procedureIndex = _indexWhereProcedure(procedureId: procedureId);

    if (procedureIndex != -1) {
      final currentSets = _sets[procedureId] ?? [];

      final pastSet = _wherePastSet(
          index: currentSets.isEmpty ? currentSets.length : currentSets.length + 1,
          type: SetType.working,
          pastSets: pastSets);
      SetDto newSet = _createSet(currentSets, pastSet);

      // Clone the old sets for the exerciseId, or create a new list if none exist
      List<SetDto> updatedSets = _sets[procedureId] != null ? List<SetDto>.from(_sets[procedureId]!) : [];

      // Add the new set to the cloned list
      updatedSets.add(newSet);

      // Create a new map by copying all key-value pairs from the original map
      Map<String, List<SetDto>> newMap = Map<String, List<SetDto>>.from(_sets);

      // Update the new map with the modified list of sets
      newMap[procedureId] = updatedSets;

      // Assign the new map to _sets to maintain immutability
      _sets = newMap;

      // Notify listeners about the change
      notifyListeners();
    }
  }

  void removeSetForProcedure({required String procedureId, required int setIndex}) {
    // Check if the exercise ID exists in the map
    if (!_sets.containsKey(procedureId)) {
      // Handle the case where the exercise ID does not exist
      // e.g., log an error or throw an exception
      return;
    }

    // Clone the old sets for the exercise ID
    List<SetDto> updatedSets = List<SetDto>.from(_sets[procedureId]!);

    // Check if the setIndex is valid
    if (setIndex < 0 || setIndex >= updatedSets.length) {
      // Handle the invalid index
      // e.g., log an error or throw an exception
      return;
    }

    // Remove the set at the specified index
    updatedSets.removeAt(setIndex);

    // Create a new map by copying all key-value pairs from the original map
    Map<String, List<SetDto>> newMap = Map<String, List<SetDto>>.from(_sets);

    // Update the new map with the modified list of sets
    newMap[procedureId] = updatedSets;

    // Assign the new map to _sets to maintain immutability
    _sets = newMap;

    // Notify listeners about the change
    notifyListeners();
  }

  void _updateSetForProcedure({required String procedureId, required int setIndex, required SetDto updatedSet}) {
    // Check if the exercise ID exists in the map and if the setIndex is valid
    if (!_sets.containsKey(procedureId) || setIndex < 0 || setIndex >= (_sets[procedureId]?.length ?? 0)) {
      // Handle the case where the exercise ID does not exist or index is invalid
      // e.g., log an error or throw an exception
      return;
    }

    // Clone the old sets for the exercise ID
    List<SetDto> updatedSets = List<SetDto>.from(_sets[procedureId]!);

    // Replace the set at the specified index with the updated set
    updatedSets[setIndex] = updatedSet;

    // Create a new map by copying all key-value pairs from the original map
    Map<String, List<SetDto>> newMap = Map<String, List<SetDto>>.from(_sets);

    // Update the new map with the modified list of sets
    newMap[procedureId] = updatedSets;

    // Assign the new map to _sets to maintain immutability
    _sets = newMap;

    // Notify listeners about the change
    notifyListeners();
  }

  void updateWeight({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto);
  }

  void updateReps({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto);
  }

  void updateDuration({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto);
  }

  void updateDistance({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto);
  }

  void updateSetType(
      {required String procedureId, required int setIndex, required SetDto setDto, required List<SetDto> pastSets}) {
    final pastSet = _wherePastSet(index: sets.length, type: setDto.type, pastSets: pastSets) ?? setDto;
    final updateSet = pastSet.copyWith(type: setDto.type, checked: setDto.checked);
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: updateSet);
  }

  void updateSetCheck({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto);
  }

  void onClearProvider() {
    _procedures = [];
    _sets = <String, List<SetDto>>{};
  }

  /// Helper functions

  SetDto _createSet(List<SetDto> sets, SetDto? pastSet) {
    final previousSet = pastSet ?? sets.lastOrNull;
    return SetDto(previousSet?.value1 ?? 0, previousSet?.value2 ?? 0, SetType.working, false);
  }

  ProcedureDto _createProcedure(Exercise exercise, {String? notes}) {
    return ProcedureDto(const Uuid().v4(), "", exercise, notes ?? "", []);
  }

  List<SetDto> completedSets() {
    return _sets.values.expand((set) => set).where((set) => set.checked).toList();
  }

  double totalWeight() {
    double totalWeight = 0.0;

    for (var procedure in _procedures) {
      final exerciseType = ExerciseType.fromString(procedure.exercise.type);

      for (var set in procedure.sets) {
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
    List<ProcedureDto> updatedProcedures = [];

    // Iterate over the original procedures list
    for (ProcedureDto procedure in _procedures) {
      if (procedure.superSetId == superSetId) {
        // Create a new ProcedureDto with an updated superSetId
        updatedProcedures.add(procedure.copyWith(superSetId: ""));
      } else {
        // Add the original ProcedureDto to the new list
        updatedProcedures.add(procedure);
      }
    }

    // Update the _procedures with the new list
    _procedures = updatedProcedures;
  }

  int _indexWhereProcedure({required String procedureId}) {
    return _procedures.indexWhere((procedure) => procedure.id == procedureId);
  }

  UnsavedChangesMessageDto? hasDifferentProceduresLength(
      {required List<ProcedureDto> procedures1, required List<ProcedureDto> procedures2}) {
    final int difference = procedures2.length - procedures1.length;

    if (difference > 0) {
      return UnsavedChangesMessageDto(message: "Added $difference exercise(s)");
    } else if (difference < 0) {
      return UnsavedChangesMessageDto(message: "Removed ${-difference} exercise(s)");
    }

    return null; // No change in length
  }

  UnsavedChangesMessageDto? hasDifferentSetsLength(
      {required List<ProcedureDto> procedures1, required List<ProcedureDto> procedures2}) {
    int addedSetsCount = 0;
    int removedSetsCount = 0;

    for (ProcedureDto proc1 in procedures1) {
      ProcedureDto? matchingProc2 = procedures2.firstWhereOrNull((p) => p.exercise.id == proc1.exercise.id);

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

    return message.isNotEmpty ? UnsavedChangesMessageDto(message: message) : null;
  }

  UnsavedChangesMessageDto? hasSetTypeChange({
    required List<ProcedureDto> procedures1,
    required List<ProcedureDto> procedures2,
  }) {
    int changes = 0;

    for (ProcedureDto proc1 in procedures1) {
      ProcedureDto? matchingProc2 = procedures2.firstWhereOrNull((p) => p.exercise.id == proc1.exercise.id);

      if (matchingProc2 == null) continue;

      int minSetLength = min(proc1.sets.length, matchingProc2.sets.length);
      for (int i = 0; i < minSetLength; i++) {
        if (proc1.sets[i].type != matchingProc2.sets[i].type) {
          changes += 1;
        }
      }
    }

    return changes > 0 ? UnsavedChangesMessageDto(message: "Changed $changes set type(s)") : null;
  }

  UnsavedChangesMessageDto? hasExercisesChanged({
    required List<ProcedureDto> procedures1,
    required List<ProcedureDto> procedures2,
  }) {
    Set<String> exerciseIds1 = procedures1.map((p) => p.exercise.id).toSet();
    Set<String> exerciseIds2 = procedures2.map((p) => p.exercise.id).toSet();

    

    int changes = exerciseIds2.difference(exerciseIds1).length;

    return changes > 0 ? UnsavedChangesMessageDto(message: "Changed $changes exercises(s)") : null;
  }

  UnsavedChangesMessageDto? hasSuperSetIdChanged({
    required List<ProcedureDto> procedures1,
    required List<ProcedureDto> procedures2,
  }) {
    Set<String> superSetIds1 = procedures1.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();
    Set<String> superSetIds2 = procedures2.map((p) => p.superSetId).where((superSetId) => superSetId.isNotEmpty).toSet();

    final changes = superSetIds2.difference(superSetIds1).length;

    return changes > 0 ? UnsavedChangesMessageDto(message: "Changed $changes supersets(s)") : null;
  }

  UnsavedChangesMessageDto? hasSetValueChanged({
    required List<ProcedureDto> procedures1,
    required List<ProcedureDto> procedures2,
  }) {
    int changes = 0;

    for (ProcedureDto proc1 in procedures1) {
      ProcedureDto? matchingProc2 = procedures2.firstWhereOrNull((p) => p.exercise.id == proc1.exercise.id);

      if (matchingProc2 == null) continue;

      int minSetLength = min(proc1.sets.length, matchingProc2.sets.length);
      for (int i = 0; i < minSetLength; i++) {
        if ((proc1.sets[i].value1 != matchingProc2.sets[i].value1) || (proc1.sets[i].value2 != matchingProc2.sets[i].value2)) {
          changes += 1;
        }
      }
    }

    return changes > 0 ? UnsavedChangesMessageDto(message: "Changed $changes set value(s)") : null;
  }

  void reset() {
    _procedures.clear();
    _sets.clear();
    notifyListeners();
  }
}
