import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import '../../app_constants.dart';
import '../../dtos/routine_template_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../repositories/amplify_template_repository.dart';
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
    final provider = Provider.of<ExerciseLogController>(context, listen: false);
    final preSelectedExercises = provider.exerciseLogs.map((procedure) => procedure.exercise).toList();

    final exercises = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExerciseLibraryScreen(preSelectedExercises: preSelectedExercises)))
        as List<ExerciseDto>?;

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
            Provider.of<ExerciseLogController>(context, listen: false).superSetExerciseLogs(
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
    final procedureProviders = Provider.of<ExerciseLogController>(context, listen: false);
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

  void _handleRoutineTemplateError(String message) {
    if (mounted) {
      _showSnackbar(message);
    }
  }

  void _createRoutineTemplate() async {

    if (!_validateRoutineTemplateInputs()) return;
    _toggleLoadingState();
    try {

      final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
      final exercises = exerciseLogController.mergeSetsIntoExerciseLogs(includeEmptySets: true);

      final template = RoutineTemplateDto(
          id: "",
          name: _templateNameController.text,
          exercises: exercises,
          notes: _templateNotesController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());

      await Provider.of<AmplifyTemplateRepository>(context, listen: false).saveTemplate(templateDto: template);
      if (mounted) _navigateBack();
    } catch (_) {
      _handleRoutineTemplateError("Unable to create workout");
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
    final procedureProvider = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = updatedExerciseLogs ?? procedureProvider.mergeSetsIntoExerciseLogs(includeEmptySets: true);
    final templateProvider = Provider.of<AmplifyTemplateRepository>(context, listen: false);
    _toggleLoadingState();
    try {
      final updatedRoutineTemplate = template.copyWith(
          name: _templateNameController.text.trim(),
          notes: _templateNotesController.text.trim(),
          exercises: exerciseLogs,
          updatedAt: DateTime.now());
      await templateProvider.updateTemplate(template: updatedRoutineTemplate);
    } catch (e) {
      _handleRoutineTemplateError("Unable to update workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _checkForUnsavedChanges() {
    final procedureProvider = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLog1 = widget.template?.exercises ?? [];
    final exerciseLog2 = procedureProvider.mergeSetsIntoExerciseLogs(includeEmptySets: true);
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

  void _reOrderExerciseLogs({required List<ExerciseLogDto> exerciseLogs}) async {
    final orderedList = await reOrderExerciseLogs(context: context, exerciseLogs: exerciseLogs);
    if(!mounted) {
      return;
    }
    if (orderedList != null) {
      Provider.of<ExerciseLogController>(context, listen: false).reOrderExerciseLogs(reOrderedList: orderedList);
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

    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = context.select((ExerciseLogController provider) => provider.exerciseLogs);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: tealBlueDark,
          appBar: AppBar(
            leading: IconButton(icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28), onPressed: _checkForUnsavedChanges),
            actions: [
              CTextButton(
                  onPressed: template != null ? _updateRoutineTemplate : _createRoutineTemplate,
                  label: template != null ? "Update" : "Save",
                  buttonColor: Colors.transparent,
                  buttonBorderColor: Colors.transparent,
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
                  child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 28),
                ),
          body: SafeArea(
            minimum: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
            child: NotificationListener<UserScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.direction != ScrollDirection.idle) {
                  _dismissKeyboard();
                }
                return false;
              },
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
                              hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14)),
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.montserrat(
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
                              hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14)),
                          maxLines: null,
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: GoogleFonts.montserrat(
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
                                      exerciseLogController.removeSuperSet(superSetId: log.superSetId),
                                  onRemoveLog: () => exerciseLogController.removeExerciseLog(logId: logId),
                                  onReOrder: () => _reOrderExerciseLogs(exerciseLogs: exerciseLogs),
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
          )),
    );
  }

  @override
  void initState() {
    super.initState();

    _initializeProcedureData();
    _initializeTextControllers();

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;
  }

  void _initializeProcedureData() {
    final exercises = widget.template?.exercises;
    if (exercises != null && exercises.isNotEmpty) {
      /// Pass [RoutineEditorMode.log] to loadExercises() to prevent the [RoutineTemplateEditorScreen] loading any timers
      /// When in [RoutineEditorMode.log], timers only when run when a set is added
      /// Since this is a template, we don't want to run any timers (The functionality to run timers is only available when logging a workout)
      Provider.of<ExerciseLogController>(context, listen: false).loadExercises(logs: exercises, mode: RoutineEditorMode.log);
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
