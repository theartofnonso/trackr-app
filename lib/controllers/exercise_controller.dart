import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import '../repositories/amplify_exercise_repository.dart';

class ExerciseController with ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';

  late AmplifyExerciseRepository _amplifyExerciseRepository;

  ExerciseController(AmplifyExerciseRepository amplifyExerciseRepository) {
    _amplifyExerciseRepository = amplifyExerciseRepository;
  }

  UnmodifiableListView<ExerciseDto> get exercises => _amplifyExerciseRepository.exercises;

  Future<void> fetchExercises() async {
    isLoading = true;
    try {
      await _amplifyExerciseRepository.fetchExercises(onDone: () {
        notifyListeners();
      });
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> saveExercise({required ExerciseDto exerciseDto}) async {
    isLoading = true;
    try {
      await _amplifyExerciseRepository.saveExercise(exerciseDto: exerciseDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> updateExercise({required ExerciseDto exercise}) async {
    isLoading = true;
    try {
      await _amplifyExerciseRepository.updateExercise(exercise: exercise);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> removeExercise({required ExerciseDto exercise}) async {
    isLoading = true;
    try {
      await _amplifyExerciseRepository.removeExercise(exercise: exercise);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  ExerciseDto? whereExercise({required String exerciseId}) {
    return _amplifyExerciseRepository.whereExercise(exerciseId: exerciseId);
  }

  void clear() {
    _amplifyExerciseRepository.clear();
    notifyListeners();
  }
}
