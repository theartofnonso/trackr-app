import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

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
    final proceduresToAdd = exercises.map((exercise) => ProcedureDto(exercise: exercise)).toList();
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

      notifyListeners();
    }
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

      procedures[procedureIndex] = ProcedureDto(exercise: exercise);

      _procedures = [...procedures];

      notifyListeners();
    }
  }

  void updateProcedureNotes({required String procedureId, required String value}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);

    if (procedureIndex != -1) {
      print(procedureIndex);
      // Create a new instance of ProcedureDto with the updated name
      ProcedureDto updatedProcedure = _procedures[procedureIndex].copyWith(notes: value);

      // Create a new list of procedures and replace the old procedure with the updated one
      List<ProcedureDto> updatedProcedures = List<ProcedureDto>.from(_procedures)
        ..[procedureIndex] = updatedProcedure;

      // Assign the new list to _procedures to maintain immutability
      _procedures = updatedProcedures;
    }
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

  void addSetForProcedure({required String procedureId}) {
    int procedureIndex = _procedures.indexWhere((procedure) => procedure.id == procedureId);

    if (procedureIndex != -1) {
      final procedure = _procedures[procedureIndex];

      SetDto newSet = _createSet(procedure);

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

  void _updateSetForProcedure(
      {required String procedureId, required int setIndex, required SetDto updatedSet, bool notify = false}) {
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
    if (notify) {
      notifyListeners();
    }
  }

  void updateWeight({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto);
  }

  void updateReps({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto);
  }

  void updateDuration({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto, notify: true);
  }

  void updateDistance({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto);
  }

  void updateSetType({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto, notify: true);
  }

  void checkSet({required String procedureId, required int setIndex, required SetDto setDto}) {
    _updateSetForProcedure(procedureId: procedureId, setIndex: setIndex, updatedSet: setDto);
  }

  void clearProcedures() {
    _procedures.clear();
  }

  /// Helper functions

  List<SetDto> completedSets() {
    return _procedures.expand((procedure) => procedure.sets).where((set) => set.checked).toList();
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

  SetDto _createSet(ProcedureDto procedure) {
    final previousSet = procedure.sets.lastOrNull;
    return SetDto(previousSet?.value1 ?? 0, previousSet?.value2 ?? 0, SetType.working, false);
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
