import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/exercise_log_provider.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import '../../app_constants.dart';
import '../../dtos/routine_template_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../providers/routine_template_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/empty_states/exercise_log_empty_state.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/routine/editors/exercise_picker.dart';
import '../exercise/exercise_library_screen.dart';
import 'helper_utils.dart';

class RoutineTemplateEditorScreen extends StatefulWidget {
  final RoutineTemplateDto? template;

  const RoutineTemplateEditorScreen({super.key, this.template});

  @override
  State<RoutineTemplateEditorScreen> createState() => _RoutineTemplateEditorScreenState();
}

class _RoutineTemplateEditorScreenState extends State<RoutineTemplateEditorScreen> {
  late TextEditingController _templateNameController;
  late TextEditingController _templateNotesController;

  bool _loading = false;
  String _loadingLabel = "";

  late Function _onDisposeCallback;

  void _selectExercisesInLibrary() async {
    final provider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final preSelectedExercises = provider.exerciseLogs.map((procedure) => procedure.exercise).toList();

    final exercises = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExerciseLibraryScreen(preSelectedExercises: preSelectedExercises)))
        as List<Exercise>?;

    if (exercises != null && exercises.isNotEmpty) {
      if (context.mounted) {
        provider.addExerciseLogs(exercises: exercises);
      }
    }
  }

  void _showExercisePicker({required ExerciseLogDto firstExerciseLog}) {
    final exercises = whereOtherExerciseLogsExcept(context: context, firstProcedure: firstExerciseLog);
    displayBottomSheet(
        context: context,
        child: ExercisePicker(
          selectedExercise: firstExerciseLog,
          exercises: exercises,
          onSelect: (ExerciseLogDto secondExercise) {
            _closeDialog();
            final id = "superset_id_${firstExerciseLog.exercise.id}_${secondExercise.exercise.id}";
            Provider.of<ExerciseLogProvider>(context, listen: false).superSetExerciseLogs(
                firstExerciseLogId: firstExerciseLog.id, secondExerciseLogId: secondExercise.id, superSetId: id);
          },
          onSelectExercisesInLibrary: () {
            _closeDialog();
            _selectExercisesInLibrary();
          },
        ));
  }

  void _toggleLoadingState() {
    final template = widget.template;
    setState(() {
      _loading = !_loading;
      _loadingLabel = template != null ? "Updating" : "Creating";
    });
  }

  bool _validateRoutineTemplateInputs() {
    final procedureProviders = Provider.of<ExerciseLogProvider>(context, listen: false);
    final procedures = procedureProviders.exerciseLogs;

    if (_templateNameController.text.isEmpty) {
      _showSnackbar('Please provide a name for this workout');
      return false;
    }
    if (procedures.isEmpty) {
      _showSnackbar("Workout must have exercise(s)");
      return false;
    }
    return true;
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: message);
  }

  void _handleRoutineTemplateCreationError(String message) {
    if (mounted) {
      _showSnackbar(message);
    }
  }

  void _createRoutineTemplate() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user == null) {
      return;
    }

    if (!_validateRoutineTemplateInputs()) return;
    _toggleLoadingState();
    try {

      final exerciseLogsProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
      final exercises = exerciseLogsProvider.mergeSetsIntoExerciseLogs();

      final template = RoutineTemplateDto(
          id: "",
          name: _templateNameController.text,
          exercises: exercises,
          notes: _templateNotesController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());

      await Provider.of<RoutineTemplateProvider>(context, listen: false).saveTemplate(user: user, templateDto: template);
      if (mounted) _navigateBack();
    } catch (e) {
      _handleRoutineTemplateCreationError("Unable to create workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _updateRoutineTemplate() {
    if (!_validateRoutineTemplateInputs()) return;
    final template = widget.template;
    if (template != null) {
      showAlertDialogWithMultiActions(
          context: context,
          message: "Update workout?",
          leftAction: _closeDialog,
          rightAction: () {
            _closeDialog();
            _doUpdateRoutineTemplate(template: template);
            _navigateBack();
          },
          leftActionLabel: 'Cancel',
          rightActionLabel: 'Update',
          isRightActionDestructive: true);
    }
  }

  void _doUpdateRoutineTemplate(
      {required RoutineTemplateDto template, List<ExerciseLogDto>? updatedExerciseLogs}) async {
    final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLogs = updatedExerciseLogs ?? procedureProvider.mergeSetsIntoExerciseLogs();
    final templateProvider = Provider.of<RoutineTemplateProvider>(context, listen: false);
    _toggleLoadingState();
    try {
      final updatedRoutineTemplate = template.copyWith(
          name: _templateNameController.text.trim(),
          notes: _templateNotesController.text.trim(),
          exercises: exerciseLogs,
          updatedAt: DateTime.now());
      await templateProvider.updateTemplate(template: updatedRoutineTemplate);
    } catch (e) {
      _handleRoutineTemplateCreationError("Unable to update workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _checkForUnsavedChanges() {
    final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLog1 = widget.template?.exercises ?? [];
    final exerciseLog2 = procedureProvider.mergeSetsIntoExerciseLogs();
    final unsavedChangesMessage =
        checkForChanges(context: context, exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    if (unsavedChangesMessage.isNotEmpty) {
      showAlertDialogWithMultiActions(
          context: context,
          message: "You have unsaved changes",
          leftAction: _closeDialog,
          leftActionLabel: 'Cancel',
          rightAction: () {
            _closeDialog();
            _navigateBack();
          },
          rightActionLabel: 'Discard',
          isRightActionDestructive: true);
    } else {
      _navigateBack();
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template;

    final exerciseLogs = context.select((ExerciseLogProvider provider) => provider.exerciseLogs);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: tealBlueDark,
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back_outlined), onPressed: _checkForUnsavedChanges),
            actions: [
              CTextButton(
                  onPressed: template != null ? _updateRoutineTemplate : _createRoutineTemplate,
                  label: template != null ? "Update" : "Save",
                  buttonColor: Colors.transparent,
                  loading: _loading,
                  loadingLabel: _loadingLabel)
            ],
          ),
          floatingActionButton: isKeyboardOpen
              ? null
              : FloatingActionButton(
                  heroTag: "fab_select_exercise_log_screen",
                  onPressed: _selectExercisesInLibrary,
                  backgroundColor: tealBlueLighter,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  child: const Icon(Icons.add, size: 28),
                ),
          body: SafeArea(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.direction != ScrollDirection.idle) {
                  _dismissKeyboard();
                }
                return false;
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
                child: GestureDetector(
                  onTap: _dismissKeyboard,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          TextField(
                            controller: _templateNameController,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(color: tealBlueLighter)),
                                filled: true,
                                fillColor: tealBlueLighter,
                                hintText: "New workout",
                                hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _templateNotesController,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(color: tealBlueLighter)),
                                filled: true,
                                fillColor: tealBlueLighter,
                                hintText: "Notes",
                                hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
                            maxLines: null,
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      exerciseLogs.isNotEmpty
                          ? Expanded(
                              child: ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 250),
                                  itemBuilder: (BuildContext context, int index) {
                                    final log = exerciseLogs[index];
                                    final logId = log.id;
                                    return ExerciseLogWidget(
                                        key: ValueKey(logId),
                                        exerciseLogDto: log,
                                        editorType: RoutineEditorMode.edit,
                                        superSet:
                                            whereOtherExerciseInSuperSet(firstExercise: log, exercises: exerciseLogs),
                                        onRemoveSuperSet: (String superSetId) =>
                                            removeExerciseFromSuperSet(context: context, superSetId: log.superSetId),
                                        onRemoveLog: () => removeExercise(context: context, exerciseId: logId),
                                        onReOrder: () => reOrderExercises(context: context),
                                        onSuperSet: () => _showExercisePicker(firstExerciseLog: log));
                                  },
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemCount: exerciseLogs.length))
                          : const ExerciseLogEmptyState(
                              mode: RoutineEditorMode.edit,
                              message: "Tap the + button to start adding exercises to your workout"),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  @override
  void initState() {
    super.initState();

    _initializeProcedureData();
    _initializeTextControllers();

    _onDisposeCallback = Provider.of<ExerciseLogProvider>(context, listen: false).onClearProvider;
  }

  void _initializeProcedureData() {
    final exercises = widget.template?.exercises;
    if (exercises != null && exercises.isNotEmpty) {
      Provider.of<ExerciseLogProvider>(context, listen: false).loadExercises(logs: exercises);
    }
  }

  void _initializeTextControllers() {
    final template = widget.template;
    _templateNameController = TextEditingController(text: template?.name);
    _templateNotesController = TextEditingController(text: template?.notes);
  }

  @override
  void dispose() {
    _onDisposeCallback();
    _templateNameController.dispose();
    _templateNotesController.dispose();
    super.dispose();
  }
}
