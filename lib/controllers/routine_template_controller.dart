import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../dtos/exercise_dto.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../enums/routine_template_library_workout_enum.dart';
import '../repositories/amplify_template_repository.dart';
import '../screens/template/library/routine_library.dart';

class RoutineTemplateController extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';

  late AmplifyTemplateRepository _amplifyTemplateRepository;

  RoutineTemplateController(AmplifyTemplateRepository amplifyTemplateRepository) {
    _amplifyTemplateRepository = amplifyTemplateRepository;
  }

  UnmodifiableListView<Map<RoutineTemplateLibraryWorkoutEnum, List<RoutineLibrary>>> get defaultTemplates =>
      _amplifyTemplateRepository.defaultTemplates;

  UnmodifiableListView<RoutineTemplateDto> get templates => _amplifyTemplateRepository.templates;

  void loadTemplatesFromAssets({required List<ExerciseDto> exercises}) async {
    if (_amplifyTemplateRepository.defaultTemplates.isEmpty) {
      await _amplifyTemplateRepository.loadTemplatesFromAssets(exercises: exercises);
      notifyListeners();
    }
  }

  void fetchTemplates() async {
    isLoading = true;
    try {
      await _amplifyTemplateRepository.fetchTemplates();
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<RoutineTemplateDto?> saveTemplate({required RoutineTemplateDto templateDto}) async {
    RoutineTemplateDto? savedTemplate;
    isLoading = true;
    try {
      savedTemplate = await _amplifyTemplateRepository.saveTemplate(templateDto: templateDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
    return savedTemplate;
  }

  Future<void> updateTemplate({required RoutineTemplateDto template}) async {
    isLoading = true;
    try {
      await _amplifyTemplateRepository.updateTemplate(template: template);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> updateTemplateSetsOnly({required String templateId, required List<ExerciseLogDto> newExercises}) async {
    isLoading = true;
    try {
      await _amplifyTemplateRepository.updateTemplateSetsOnly(templateId: templateId, newExercises: newExercises);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  Future<void> removeTemplate({required RoutineTemplateDto template}) async {
    isLoading = true;
    try {
      await _amplifyTemplateRepository.removeTemplate(template: template);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      isLoading = false;
      errorMessage = "";
      notifyListeners();
    }
  }

  RoutineTemplateDto? templateWhere({required String id}) {
    return _amplifyTemplateRepository.templateWhere(id: id);
  }

  void clear() {
    _amplifyTemplateRepository.clear();
    notifyListeners();
  }
}
