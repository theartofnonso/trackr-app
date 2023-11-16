import 'dart:collection';

import 'package:flutter/material.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../models/Exercise.dart';

class ProceduresProvider extends ChangeNotifier {
  List<ProcedureDto> _procedures = [];

  UnmodifiableListView<ProcedureDto> get procedures => UnmodifiableListView(_procedures);

  void addProcedures({required List<Exercise> exercises}) {
    final proceduresToAdd = exercises.map((exercise) => ProcedureDto(exercise: exercise)).toList();
    _procedures.addAll(proceduresToAdd);

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

  void addSetForProcedure({required String exerciseId}) {
    int procedureIndex = _indexWhereProcedure(exerciseId: exerciseId);

    if (procedureIndex != -1) {
      final procedure = _procedures[procedureIndex];
      SetDto newSet = _createSet(procedure);

      List<SetDto> updatedSets = List<SetDto>.from(procedure.sets)..add(newSet);

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

        notifyListeners();
      }
    }
  }

  void _updateProcedureSet<T extends SetDto>(
      {required String exerciseId,
      required int setIndex,
      required T Function(T set) updateFunction,
      bool shouldNotifyListeners = false}) {
    final procedureIndex = _indexWhereProcedure(exerciseId: exerciseId);
    if (procedureIndex != -1) {
      final procedure = _procedures[procedureIndex];
      if (setIndex != -1 && setIndex < procedure.sets.length && procedure.sets[setIndex] is T) {
        List<SetDto> updatedSets = List<SetDto>.from(procedure.sets);
        updatedSets[setIndex] = updateFunction(updatedSets[setIndex] as T);
        _procedures[procedureIndex] = procedure.copyWith(sets: updatedSets);
        if (shouldNotifyListeners) {
          notifyListeners();
        }
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
      updateFunction: (set) => set.copyWith(value1: duration.inMilliseconds),
      shouldNotifyListeners: true,
    );
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
        exerciseId: exerciseId,
        setIndex: setIndex,
        updateFunction: (set) => set.copyWith(type: type),
        shouldNotifyListeners: true);
  }

  void checkSet({required String exerciseId, required int setIndex}) {
    _updateProcedureSet<SetDto>(
        exerciseId: exerciseId,
        setIndex: setIndex,
        updateFunction: (set) => set.copyWith(checked: !set.checked),
        shouldNotifyListeners: true);
  }

  void clearProcedures() {
    _procedures.clear();
  }

  /// Helper functions

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
