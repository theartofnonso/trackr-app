import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../models/Exercise.dart';

class ProceduresProvider extends ChangeNotifier {
  List<ProcedureDto> _procedures = [];
  List<Map<ProcedureDto, List<SetDto>>> _sets = [];

  UnmodifiableListView<ProcedureDto> get procedures => UnmodifiableListView(_procedures);
  UnmodifiableListView<Map<ProcedureDto, List<SetDto>>> get sets => UnmodifiableListView(_sets);

  void refreshProcedures({required List<ProcedureDto> procedures}) {
    _procedures = procedures;
    notifyListeners();
  }

  void loadProcedures({required List<String> procedures}) {
    _procedures = procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  }

  void addProcedures({required List<Exercise> exercises}) {
    final proceduresToAdd = exercises.map((exercise) => ProcedureDto(exercise: exercise)).toList();
    _procedures = [..._procedures, ...proceduresToAdd];

    notifyListeners();
  }

  void removeProcedure({required String exerciseId}) {
    final procedureIndex = _indexWhereProcedure(exerciseId: exerciseId);
    if (procedureIndex != -1) {
      final procedureToBeRemoved = _procedures[procedureIndex];

      if (procedureToBeRemoved.superSetId.isNotEmpty) {
        _removeSuperSet(superSetId: procedureToBeRemoved.superSetId);
      }

      _procedures.removeAt(procedureIndex);

      notifyListeners();
    }
  }

  void replaceProcedure({required String exerciseId, required Exercise exercise}) async {
    // Get the index of the procedure to be replaced
    final procedureIndex = _indexWhereProcedure(exerciseId: exerciseId);

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

  void updateProcedureNotes({required String exerciseId, required String value}) {
    // Find the index of the procedure with the given exercise ID.
    final procedureIndex = _indexWhereProcedure(exerciseId: exerciseId);

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

  void addSetForProcedure({required String exerciseId, required SetDto set}) {
    int procedureIndex = _indexWhereProcedure(exerciseId: exerciseId);

    if (procedureIndex != -1) {
      final procedure = _procedures[procedureIndex];
     // SetDto newSet = _createSet(procedure);

      List<SetDto> updatedSets = List<SetDto>.from(procedure.sets)..add(set);

      _procedures[procedureIndex] = procedure.copyWith(sets: updatedSets);

      notifyListeners();
    }
  }

  void removeSetForProcedure({required String exerciseId, required int setIndex}) {
    int procedureIndex = _indexWhereProcedure(exerciseId: exerciseId);

    if (procedureIndex != -1 && setIndex >= 0) {
      final procedure = _procedures[procedureIndex];

      if (setIndex < procedure.sets.length) {
        List<SetDto> updatedSets = List<SetDto>.from(procedure.sets)..removeAt(setIndex);

        _procedures[procedureIndex] = procedure.copyWith(sets: updatedSets);

        //notifyListeners();
      }
    }
  }

  void _updateProcedureSet<T extends SetDto>(
      {required String exerciseId, required int setIndex, required T Function(T set) updateFunction}) {
    final procedureIndex = _indexWhereProcedure(exerciseId: exerciseId);
    if (procedureIndex != -1) {
      final procedure = _procedures[procedureIndex];
      if (setIndex != -1 && setIndex < procedure.sets.length && procedure.sets[setIndex] is T) {
        List<SetDto> updatedSets = List<SetDto>.from(procedure.sets);
        updatedSets[setIndex] = updateFunction(updatedSets[setIndex] as T);
        _procedures[procedureIndex] = procedure.copyWith(sets: updatedSets);
      }
    }
  }

  void updateWeight({required String exerciseId, required int setIndex, required double value}) {
    _updateProcedureSet<SetDto>(
      exerciseId: exerciseId,
      setIndex: setIndex,
      updateFunction: (set) => set.copyWith(value1: value),
    );
  }

  void updateReps({required String exerciseId, required int setIndex, required num value}) {
    _updateProcedureSet<SetDto>(
      exerciseId: exerciseId,
      setIndex: setIndex,
      updateFunction: (set) => set.copyWith(value2: value),
    );
  }

  void updateDuration({required String exerciseId, required int setIndex, required Duration duration}) {
    _updateProcedureSet<SetDto>(
        exerciseId: exerciseId,
        setIndex: setIndex,
        updateFunction: (set) => set.copyWith(value1: duration.inMilliseconds));
  }

  void updateDistance({required String exerciseId, required int setIndex, required double distance}) {
    _updateProcedureSet<SetDto>(
      exerciseId: exerciseId,
      setIndex: setIndex,
      updateFunction: (set) => set.copyWith(value2: distance),
    );
  }

  void updateSetType({required String exerciseId, required int setIndex, required SetType type}) {
    _updateProcedureSet<SetDto>(
        exerciseId: exerciseId, setIndex: setIndex, updateFunction: (set) => set.copyWith(type: type));
  }

  void checkSet({required String exerciseId, required int setIndex}) {
    _updateProcedureSet<SetDto>(
        exerciseId: exerciseId,
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
