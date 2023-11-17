import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
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

      procedures[procedureIndex] = _createProcedure(exercise);

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
    return workingSets.length >= index ? workingSets.last : null;
  }

  void addSetForProcedure({required String procedureId, required List<SetDto> pastSets}) {
    int procedureIndex = _indexWhereProcedure(procedureId: procedureId);

    if (procedureIndex != -1) {
      final currentSets = _sets[procedureId] ?? [];

      final pastSet = _wherePastSet(index: currentSets.isEmpty ? currentSets.length : currentSets.length + 1, type: SetType.working, pastSets: pastSets);
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

    print(_sets);

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

  void updateSetType({required String procedureId, required int setIndex, required SetDto setDto, required List<SetDto> pastSets}) {
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

  ProcedureDto _createProcedure(Exercise exercise) {
    return ProcedureDto(const Uuid().v4(), "", exercise, "", []);
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
}
