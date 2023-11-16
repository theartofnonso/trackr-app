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
    final procedureIndex = _indexWhereProcedure(exerciseId: procedureId);
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
    final procedureIndex = _indexWhereProcedure(exerciseId: procedureId);

    // Check if the procedure was found
    if (procedureIndex != -1) {
      final procedureToBeReplaced = _procedures[procedureIndex];

      // If the procedure is part of a super set, remove it from the super set
      if (procedureToBeReplaced.superSetId.isNotEmpty) {
        _removeSuperSet(superSetId: procedureToBeReplaced.superSetId);
      }

      _procedures[procedureIndex] = ProcedureDto(exercise: exercise);

      notifyListeners();
    }
  }

  void updateProcedureNotes({required String procedureId, required String value}) {
    // Find the index of the procedure with the given exercise ID.
    final procedureIndex = _indexWhereProcedure(exerciseId: procedureId);

    // Check if a valid procedure is found.
    if (procedureIndex != -1) {
      final procedure = _procedures[procedureIndex];

      // Check if the new value is different from the old one.
      if (procedure.notes != value) {
        // Update the procedure with the new notes.
        _procedures[procedureIndex] = procedure.copyWith(notes: value);
      }
    }
  }

  void superSetProcedures({required String firstExerciseId, required String secondExerciseId}) {
    final id = "superset_id_${firstExerciseId}_$secondExerciseId";

    final firstProcedureIndex = _indexWhereProcedure(exerciseId: firstExerciseId);
    final secondProcedureIndex = _indexWhereProcedure(exerciseId: secondExerciseId);

    if (firstProcedureIndex != -1 && secondProcedureIndex != -1) {
      List<ProcedureDto> updatedProcedures = List<ProcedureDto>.from(_procedures);

      updatedProcedures[firstProcedureIndex] = updatedProcedures[firstProcedureIndex].copyWith(superSetId: id);
      updatedProcedures[secondProcedureIndex] = updatedProcedures[secondProcedureIndex].copyWith(superSetId: id);

      _procedures = updatedProcedures;

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

  void _updateProcedureSet<T extends SetDto>(
      {required String procedureId, required int setIndex, required T Function(T set) updateFunction}) {
    final procedureIndex = _indexWhereProcedure(exerciseId: procedureId);
    if (procedureIndex != -1) {
      final procedure = _procedures[procedureIndex];
      if (setIndex != -1 && setIndex < procedure.sets.length && procedure.sets[setIndex] is T) {
        List<SetDto> updatedSets = List<SetDto>.from(procedure.sets);
        updatedSets[setIndex] = updateFunction(updatedSets[setIndex] as T);
        _procedures[procedureIndex] = procedure.copyWith(sets: updatedSets);
      }
    }
  }

  void updateWeight({required String procedureId, required int setIndex, required double value}) {
    _updateProcedureSet<SetDto>(
      procedureId: procedureId,
      setIndex: setIndex,
      updateFunction: (set) => set.copyWith(value1: value),
    );
  }

  void updateReps({required String procedureId, required int setIndex, required num value}) {
    _updateProcedureSet<SetDto>(
      procedureId: procedureId,
      setIndex: setIndex,
      updateFunction: (set) => set.copyWith(value2: value),
    );
  }

  void updateDuration({required String procedureId, required int setIndex, required Duration duration}) {
    _updateProcedureSet<SetDto>(
        procedureId: procedureId,
        setIndex: setIndex,
        updateFunction: (set) => set.copyWith(value1: duration.inMilliseconds));
  }

  void updateDistance({required String procedureId, required int setIndex, required double distance}) {
    _updateProcedureSet<SetDto>(
      procedureId: procedureId,
      setIndex: setIndex,
      updateFunction: (set) => set.copyWith(value2: distance),
    );
  }

  void updateSetType({required String procedureId, required int setIndex, required SetType type}) {
    _updateProcedureSet<SetDto>(
        procedureId: procedureId, setIndex: setIndex, updateFunction: (set) => set.copyWith(type: type));
  }

  void checkSet({required String exerciseId, required int setIndex}) {
    _updateProcedureSet<SetDto>(
        procedureId: exerciseId,
        setIndex: setIndex,
        updateFunction: (set) => set.copyWith(checked: set.isNotEmpty() ? !set.checked : false));
  }

  void clearProcedures() {
    _procedures.clear();
  }

  SetDto setWhereProcedure({required String exerciseId, required setIndex}) {
    final sets = _procedures
        .where((procedure) => procedure.exercise.id == exerciseId)
        .expand((procedure) => procedure.sets)
        .toList();
    if (sets.isNotEmpty) {
      if (setIndex <= sets.length) {
        return sets[setIndex];
      }
    }
    return SetDto(0, 0, SetType.working, false);
  }

  int setTypeIndexWhereProcedure({required String exerciseId, required SetType setType, required int setIndex}) {

    Map<SetType, int> setTypeCounts = {SetType.warmUp: 0, SetType.working: 0, SetType.failure: 0, SetType.drop: 0};

    final sets = _procedures.firstWhere((procedure) => procedure.exercise.id == exerciseId).sets;

    for (int index = 0; index < sets.length; index++) {
      final set = sets[index];
      setTypeCounts[set.type] = setTypeCounts[set.type]! + 1;
    }

    return setTypeCounts[setType]!;

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
    // Create a copy of the procedures list to modify
    List<ProcedureDto> updatedProcedures = List<ProcedureDto>.from(_procedures);

    // Iterate over the copy to modify the necessary procedures
    for (int i = 0; i < updatedProcedures.length; i++) {
      if (updatedProcedures[i].superSetId == superSetId) {
        updatedProcedures[i] = updatedProcedures[i].copyWith(superSetId: "");
      }
    }
    _procedures = updatedProcedures;
  }

  int _indexWhereProcedure({required String exerciseId}) {
    return _procedures.indexWhere((procedure) => procedure.exercise.id == exerciseId);
  }
}
