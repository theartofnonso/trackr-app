import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/utils/dialog_utils.dart';

import '../../colors.dart';
import '../../controllers/routine_template_controller.dart';
import '../../dtos/routine_template_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/routine_editors_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/empty_states/exercise_log_empty_state.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';

class RoutineTemplateEditorScreen extends StatefulWidget {
  static const routeName = '/routine-template-editor';

  final RoutineTemplateDto? template;

  const RoutineTemplateEditorScreen({super.key, this.template});

  @override
  State<RoutineTemplateEditorScreen> createState() => _RoutineTemplateEditorScreenState();
}

class _RoutineTemplateEditorScreenState extends State<RoutineTemplateEditorScreen> {
  late TextEditingController _templateNameController;
  late TextEditingController _templateNotesController;

  late Function _onDisposeCallback;

  void _selectExercisesInLibrary() async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final preSelectedExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        exclude: preSelectedExercises,
        multiSelect: true,
        onSelected: (List<ExerciseDto> selectedExercises) {
          controller.addExerciseLogs(exercises: selectedExercises);
        });
  }

  void _showSuperSetExercisePicker({required ExerciseLogDto firstExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final exercises = whereOtherExerciseLogsExcept(exerciseLog: firstExerciseLog, others: controller.exerciseLogs);
    showSuperSetExercisePicker(
        context: context,
        firstExerciseLog: firstExerciseLog,
        exerciseLogs: exercises,
        onSelected: (secondExerciseLog) {
          _closeDialog();
          final id = superSetId(firstExerciseLog: firstExerciseLog, secondExerciseLog: secondExerciseLog);
          controller.superSetExerciseLogs(
              firstExerciseLogId: firstExerciseLog.id, secondExerciseLogId: secondExerciseLog.id, superSetId: id);
        },
        selectExercisesInLibrary: () {
          _closeDialog();
          _selectExercisesInLibrary();
        });
  }

  void _showReplaceExercisePicker({required ExerciseLogDto oldExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final preSelectedExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        exclude: preSelectedExercises,
        multiSelect: false,
        filter: oldExerciseLog.exercise.type,
        onSelected: (List<ExerciseDto> selectedExercises) {
          controller.replaceExerciseLog(oldExerciseId: oldExerciseLog.id, newExercise: selectedExercises.first);
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

  void _createRoutineTemplate() async {
    if (!_validateRoutineTemplateInputs()) return;

    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
    final exercises = exerciseLogController.mergeExerciseLogsAndSets();

    final template = RoutineTemplateDto(
        id: "",
        name: _templateNameController.text,
        exerciseTemplates: exercises,
        notes: _templateNotesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

    await Provider.of<RoutineTemplateController>(context, listen: false).saveTemplate(templateDto: template);
    _navigateBack();
  }

  void _updateRoutineTemplate() {
    if (!_validateRoutineTemplateInputs()) return;
    final template = widget.template;
    if (template != null) {
      showBottomSheetWithMultiActions(
          context: context,
          description: "Update workout?",
          leftAction: _closeDialog,
          rightAction: () {
            _closeDialog();
            _doUpdateRoutineTemplate(template: template);
            _navigateBack();
          },
          leftActionLabel: 'Cancel',
          rightActionLabel: 'Update',
          isRightActionDestructive: true,
          title: "Update workout");
    }
  }

  void _doUpdateRoutineTemplate(
      {required RoutineTemplateDto template, List<ExerciseLogDto>? updatedExerciseLogs}) async {
    final procedureProvider = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = updatedExerciseLogs ?? procedureProvider.mergeExerciseLogsAndSets();
    final templateProvider = Provider.of<RoutineTemplateController>(context, listen: false);

    final updatedRoutineTemplate = template.copyWith(
        name: _templateNameController.text.trim(),
        notes: _templateNotesController.text.trim(),
        exerciseTemplates: exerciseLogs,
        updatedAt: DateTime.now());

    await templateProvider.updateTemplate(template: updatedRoutineTemplate);
  }

  void _checkForUnsavedChanges() {
    final procedureProvider = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLog1 = widget.template?.exerciseTemplates ?? [];
    final exerciseLog2 = procedureProvider.mergeExerciseLogsAndSets();
    final unsavedChangesMessage = checkForChanges(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    if (unsavedChangesMessage.isNotEmpty) {
      showBottomSheetWithMultiActions(
          context: context,
          description: "You have unsaved changes",
          leftAction: _closeDialog,
          leftActionLabel: 'Cancel',
          rightAction: () {
            _closeDialog();
            _navigateBack();
          },
          rightActionLabel: 'Discard',
          isRightActionDestructive: true,
          title: "Discard changes");
    } else {
      _navigateBack();
    }
  }

  void _reOrderExerciseLogs({required List<ExerciseLogDto> exerciseLogs}) async {
    final orderedList = await reOrderExerciseLogs(context: context, exerciseLogs: exerciseLogs);
    if (!mounted) {
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

    final routineTemplateController = Provider.of<RoutineTemplateController>(context, listen: true);

    if (routineTemplateController.errorMessage.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showSnackbar(routineTemplateController.errorMessage);
      });
    }

    final exerciseLogs = context.select((ExerciseLogController provider) => provider.exerciseLogs);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: sapphireDark,
          appBar: AppBar(
            backgroundColor: sapphireDark80,
            leading: IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                onPressed: _checkForUnsavedChanges),
            actions: [
              IconButton(
                  onPressed: _selectExercisesInLibrary, icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white)),
              if (exerciseLogs.length > 1)
                IconButton(
                    onPressed: () => _reOrderExerciseLogs(exerciseLogs: exerciseLogs),
                    icon: const FaIcon(FontAwesomeIcons.barsStaggered, color: Colors.white)),
            ],
          ),
          floatingActionButton: isKeyboardOpen
              ? null
              : FloatingActionButton(
                  heroTag: "fab_select_exercise_log_screen",
                  onPressed: template != null ? _updateRoutineTemplate : _createRoutineTemplate,
                  backgroundColor: sapphireDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  child: const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 28),
                ),
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sapphireDark80,
                  sapphireDark,
                ],
              ),
            ),
            child: SafeArea(
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
                                    borderSide: const BorderSide(color: sapphireLighter)),
                                filled: true,
                                fillColor: sapphireDark,
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
                                    borderSide: const BorderSide(color: sapphireLighter)),
                                filled: true,
                                fillColor: sapphireDark,
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
                                        onReplaceLog: () => _showReplaceExercisePicker(oldExerciseLog: log),
                                        onSuperSet: () => _showSuperSetExercisePicker(firstExerciseLog: log));
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

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;
  }

  void _initializeProcedureData() {
    final exercises = widget.template?.exerciseTemplates;
    if (exercises != null && exercises.isNotEmpty) {
      final updatedExerciseLogs = exercises.map((exerciseLog) {
        final previousSets = Provider.of<RoutineLogController>(context, listen: false)
            .whereSetsForExercise(exercise: exerciseLog.exercise);
        if (previousSets.isNotEmpty) {
          final unCheckedSets =
              previousSets.take(exerciseLog.sets.length).map((set) => set.copyWith(checked: false)).toList();
          return exerciseLog.copyWith(sets: unCheckedSets);
        }
        return exerciseLog;
      }).toList();
      Provider.of<ExerciseLogController>(context, listen: false)
          .loadExerciseLogs(exerciseLogs: updatedExerciseLogs, mode: RoutineEditorMode.edit);
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
