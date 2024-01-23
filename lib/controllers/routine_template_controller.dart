import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import '../dtos/exercise_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../repositories/amplify_template_repository.dart';

class RoutineTemplateController extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';

  late AmplifyTemplateRepository _amplifyTemplateRepository;

  RoutineTemplateController(AmplifyTemplateRepository amplifyTemplateRepository) {
    _amplifyTemplateRepository = amplifyTemplateRepository;
  }

  UnmodifiableListView<RoutineTemplateDto> get templates => _amplifyTemplateRepository.templates;

  void fetchTemplates({List<RoutineTemplate>? templates}) async {
    isLoading = true;
    try {
      await _amplifyTemplateRepository.fetchTemplates(onSyncCompleted: () {
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

  Future<void> updateTemplateSetsOnly(
      {required String templateId, required List<ExerciseLogDto> newExercises}) async {
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
