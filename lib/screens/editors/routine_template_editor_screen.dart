import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/weight_and_reps_set_dto.dart';
import 'package:tracker_app/utils/dialog_utils.dart';

import '../../colors.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/sets_dtos/set_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/routine_editors_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/routine/editors/exercise_log_widget_lite.dart';
import '../../widgets/weight_plate_calculator.dart';
import '../empty_state_screens/no_list_empty_state.dart';

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

  final _minimisedExerciseLogCards = <String>[];

  SetDTO? _selectedSetDto;

  void _selectExercisesInLibrary() async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((exercise) => exercise.exerciseVariant).toList();

    showExercisesInLibrary(
        context: context,
        exercisesToExclude: excludeExercises.map((exercise) => exercise.name).toList(),
        onSelected: (List<ExerciseDTO> selectedExercises) {
          final variants = selectedExercises.map((exercise) => exercise.defaultVariant()).toList();
          controller.addExerciseLogs(exercisesVariants: variants);
        });
  }

  void _showSuperSetExercisePicker({required ExerciseLogDTO firstExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final otherExercises = whereOtherExerciseLogsExcept(exerciseLog: firstExerciseLog, others: controller.exerciseLogs);
    showSuperSetExercisePicker(
        context: context,
        firstExerciseLog: firstExerciseLog,
        otherExerciseLogs: otherExercises,
        onSelected: (secondExerciseLog) {
          _closeDialog();
          final id = superSetId(firstExerciseLog: firstExerciseLog, secondExerciseLog: secondExerciseLog);
          controller.superSetExerciseLogs(
              firstExerciseName: firstExerciseLog.exerciseVariant.name,
              secondExerciseName: secondExerciseLog.exerciseVariant.name,
              superSetId: id);
        },
        selectExercisesInLibrary: () {
          _closeDialog();
          _selectExercisesInLibrary();
        });
  }

  void _showReplaceExercisePicker({required ExerciseLogDTO oldExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((exercise) => exercise.exerciseVariant).toList();

    showExercisesInLibrary(
        context: context,
        exercisesToExclude: excludeExercises.map((exercise) => exercise.name).toList(),
        onSelected: (List<ExerciseDTO> selectedExercises) {
          controller.replaceExerciseLog(
              oldExerciseId: oldExerciseLog.exerciseVariant.name,
              newExerciseVariant: selectedExercises.first.defaultVariant());
        });
  }

  bool _validateRoutineTemplateInputs() {
    final exerciseProviders = Provider.of<ExerciseLogController>(context, listen: false);
    final exercises = exerciseProviders.exerciseLogs;

    if (_templateNameController.text.isEmpty) {
      _showSnackbar('Please provide a name for this workout');
      return false;
    }
    if (exercises.isEmpty) {
      _showSnackbar("Workout must have exercise(s)");
      return false;
    }
    return true;
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const FaIcon(FontAwesomeIcons.circleInfo), message: message);
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
        owner: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

    await Provider.of<ExerciseAndRoutineController>(context, listen: false).saveTemplate(templateDto: template);
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
            final updatedTemplate = _getUpdatedRoutineTemplate(template: template);
            _doUpdateRoutineTemplate(updatedTemplate: updatedTemplate);
            _navigateBack(template: updatedTemplate);
          },
          leftActionLabel: 'Cancel',
          rightActionLabel: 'Update',
          isRightActionDestructive: true,
          title: "Update workout");
    }
  }

  RoutineTemplateDto _getUpdatedRoutineTemplate(
      {required RoutineTemplateDto template, List<ExerciseLogDTO>? updatedExerciseLogs}) {
    final exerciseProvider = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = updatedExerciseLogs ?? exerciseProvider.mergeExerciseLogsAndSets();

    return template.copyWith(
        name: _templateNameController.text.trim(),
        notes: _templateNotesController.text.trim(),
        exerciseTemplates: exerciseLogs,
        updatedAt: DateTime.now());
  }

  void _doUpdateRoutineTemplate({required RoutineTemplateDto updatedTemplate}) async {
    final templateProvider = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final updatedRoutineTemplate = _getUpdatedRoutineTemplate(template: updatedTemplate);

    await templateProvider.updateTemplate(template: updatedRoutineTemplate);
  }

  void _checkForUnsavedChanges() {
    final exerciseProvider = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLog1 = widget.template?.exerciseTemplates ?? [];
    final exerciseLog2 = exerciseProvider.mergeExerciseLogsAndSets();
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

  void _reOrderExerciseLogs({required List<ExerciseLogDTO> exerciseLogs}) async {
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

  void _navigateBack({RoutineTemplateDto? template}) {
    context.pop(template);
  }

  /// Handle collapsed ExerciseLogWidget
  void _handleResizedExerciseLogCard({required String exerciseIdToResize}) {
    setState(() {
      final foundExercise =
          _minimisedExerciseLogCards.firstWhereOrNull((exerciseId) => exerciseId == exerciseIdToResize);
      if (foundExercise != null) {
        _minimisedExerciseLogCards.remove(exerciseIdToResize);
      } else {
        _minimisedExerciseLogCards.add(exerciseIdToResize);
      }
    });
  }

  bool _isMinimised(String id) {
    return _minimisedExerciseLogCards.firstWhereOrNull((exerciseId) => exerciseId == id) != null;
  }

  void _updateExerciseLog(ExerciseLogDTO exerciseLog) async {
    Provider.of<ExerciseLogController>(context, listen: false).updateExerciseLog(newExerciseLog: exerciseLog);
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template;

    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    final routineTemplateController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    if (routineTemplateController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
          floatingActionButton: isKeyboardOpen && _selectedSetDto != null
              ? FloatingActionButton.extended(
                  heroTag: UniqueKey(),
                  onPressed: _showWeightCalculator,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  enableFeedback: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  icon: Image.asset(
                    'icons/dumbbells.png',
                    fit: BoxFit.contain,
                    color: Colors.white,
                    height: 24, // Adjust the height as needed
                  ),
                  label:
                      Text("Calculator", style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600)),
                )
              : FloatingActionButton(
                  heroTag: "routine_template_editor_scree_fab",
                  onPressed: template != null ? _updateRoutineTemplate : _createRoutineTemplate,
                  backgroundColor: sapphireDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  child: const FaIcon(FontAwesomeIcons.solidSquareCheck, color: Colors.white, size: 28),
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
                                hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14)),
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            style: GoogleFonts.ubuntu(
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
                                hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14)),
                            maxLines: null,
                            cursorColor: Colors.white,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      exerciseLogs.isNotEmpty
                          ? Expanded(
                              child: ListView.separated(
                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                  padding: const EdgeInsets.only(bottom: 250),
                                  itemBuilder: (BuildContext context, int index) {
                                    final exerciseLog = exerciseLogs[index];
                                    final exerciseName = exerciseLog.exerciseVariant.name;
                                    final isExerciseMinimised = _minimisedExerciseLogCards.contains(exerciseName);
                                    return isExerciseMinimised
                                        ? ExerciseLogLiteWidget(
                                            key: ValueKey(exerciseName),
                                            exerciseLogDto: exerciseLog,
                                            superSet: whereOtherExerciseInSuperSet(
                                                firstExercise: exerciseLog, exercises: exerciseLogs),
                                            onMaximise: () =>
                                                _handleResizedExerciseLogCard(exerciseIdToResize: exerciseName),
                                          )
                                        : ExerciseLogWidget(
                                            key: ValueKey(exerciseName),
                                            exerciseLogDto: exerciseLog,
                                            editorType: RoutineEditorMode.edit,
                                            superSet: whereOtherExerciseInSuperSet(
                                                firstExercise: exerciseLog, exercises: exerciseLogs),
                                            onRemoveSuperSet: (String superSetId) => exerciseLogController
                                                .removeSuperSet(superSetId: exerciseLog.superSetId),
                                            onRemoveLog: () =>
                                                exerciseLogController.removeExerciseLog(logId: exerciseName),
                                            onReplaceLog: () => _showReplaceExercisePicker(oldExerciseLog: exerciseLog),
                                            onSuperSet: () =>
                                                _showSuperSetExercisePicker(firstExerciseLog: exerciseLog),
                                            onResize: () =>
                                                _handleResizedExerciseLogCard(exerciseIdToResize: exerciseName),
                                            isMinimised: _isMinimised(exerciseName),
                                            onTapWeightEditor: (SetDTO setDto) {
                                              setState(() {
                                                _selectedSetDto = setDto;
                                              });
                                            },
                                            onTapRepsEditor: (SetDTO setDto) {
                                              setState(() {
                                                _selectedSetDto = null;
                                              });
                                            },
                                            onUpdate: _updateExerciseLog,
                                          );
                                  },
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemCount: exerciseLogs.length))
                          : Expanded(
                            child: const NoListEmptyState(
                                icon: FaIcon(
                                  FontAwesomeIcons.solidLightbulb,
                                  color: Colors.white12,
                                  size: 48,
                                ),
                                message: "Tap the + button to start adding exercises to your workout.",
                              ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void _showWeightCalculator() {
    displayBottomSheet(
        context: context,
        child: WeightPlateCalculator(target: (_selectedSetDto as WeightAndRepsSetDTO?)?.weight ?? 0),
        padding: EdgeInsets.zero);
  }

  @override
  void initState() {
    super.initState();

    _initializeWorkoutTemplateData();
    _initializeTextControllers();

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;
  }

  void _initializeWorkoutTemplateData() {
    final exercises = widget.template?.exerciseTemplates;
    if (exercises != null && exercises.isNotEmpty) {
      final updatedExerciseLogs = exercises.map((exerciseLog) {
        final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
            .whereSetsForExercise(exerciseVariant: exerciseLog.exerciseVariant);
        if (previousSets.isNotEmpty) {
          final unCheckedSets =
              previousSets.take(exerciseLog.sets.length).map((set) => set.copyWith(checked: false)).toList();
          return exerciseLog.copyWith(sets: unCheckedSets);
        }
        return exerciseLog;
      }).toList();
      Provider.of<ExerciseLogController>(context, listen: false)
          .loadExerciseLogs(exerciseLogs: updatedExerciseLogs, mode: RoutineEditorMode.edit);
      _minimiseOrMaximiseCards();
    }
  }

  void _initializeTextControllers() {
    final template = widget.template;
    _templateNameController = TextEditingController(text: template?.name);
    _templateNotesController = TextEditingController(text: template?.notes);
  }

  void _minimiseOrMaximiseCards() {
    Provider.of<ExerciseLogController>(context, listen: false).exerciseLogs.forEach((exerciseLog) {
      final completedSets = exerciseLog.sets.where((set) => set.checked).length;
      final isExerciseCompleted = completedSets == exerciseLog.sets.length;
      if (isExerciseCompleted) {
        setState(() {
          _minimisedExerciseLogCards.add(exerciseLog.exerciseVariant.name);
        });
      }
    });
  }

  @override
  void dispose() {
    _onDisposeCallback();
    _templateNameController.dispose();
    _templateNotesController.dispose();
    super.dispose();
  }
}
