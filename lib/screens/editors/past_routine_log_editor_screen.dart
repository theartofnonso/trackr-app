import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/utils/dialog_utils.dart';

import '../../colors.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/routine_editors_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/routine/editors/exercise_log_widget_lite.dart';
import '../../widgets/weight_plate_calculator.dart';

class PastRoutineLogEditorScreen extends StatefulWidget {
  static const routeName = '/past-routine-log-editor';

  final RoutineLogDto log;

  const PastRoutineLogEditorScreen({super.key, required this.log});

  @override
  State<PastRoutineLogEditorScreen> createState() => _PastRoutineLogEditorScreenState();
}

class _PastRoutineLogEditorScreenState extends State<PastRoutineLogEditorScreen> {
  late TextEditingController _templateNameController;
  late TextEditingController _templateNotesController;

  late Function _onDisposeCallback;

  final _minimisedExerciseLogCards = <String>[];

  SetDto? _selectedSetDto;

  void _selectExercisesInLibrary() async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((exercise) => exercise.exercise).toList();

    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          final onlyExercise = selectedExercises.first;
          final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
              .whereSetsForExercise(exercise: onlyExercise);
          controller.addExerciseLog(exercise: onlyExercise, pastSets: pastSets);
        });
  }

  void _showSuperSetExercisePicker({required ExerciseLogDto firstExerciseLog}) {
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
              firstExerciseLogId: firstExerciseLog.id, secondExerciseLogId: secondExerciseLog.id, superSetId: id);
        },
        selectExercisesInLibrary: () {
          _closeDialog();
          _selectExercisesInLibrary();
        });
  }

  void _showReplaceExercisePicker({required ExerciseLogDto oldExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((exercise) => exercise.exercise).toList();

    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
              .whereSetsForExercise(exercise: selectedExercises.first);
          controller.replaceExerciseLog(oldExerciseId: oldExerciseLog.id, newExercise: selectedExercises.first, pastSets: pastSets);
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

  bool _isRoutinePartiallyComplete() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets(mode: RoutineEditorMode.log);

    final hasAnyCompletedSet =  exerciseLogs.any((log) => log.sets.any((set) => set.isNotEmpty() && set.checked));

    if (!hasAnyCompletedSet) {
      _showSnackbar("Workout must have completed set(s)");
    }

    return hasAnyCompletedSet;
  }

  void _createLog() async {
    if (!_validateRoutineTemplateInputs()) return;

    if(!_isRoutinePartiallyComplete()) return;

    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets(mode: RoutineEditorMode.edit).map((exerciseLog) {
      final checkedSets = exerciseLog.sets.map((set) => set.copyWith(checked: true)).toList();
      return exerciseLog.copyWith(sets: checkedSets);
    }).toList();

    final routineName =
        _templateNameController.text.trim().isNotEmpty ? _templateNameController.text.trim() : widget.log.name;
    final routineNotes =
        _templateNotesController.text.trim().isNotEmpty ? _templateNotesController.text.trim() : widget.log.notes;

    final updatedLog = widget.log.copyWith(name: routineName, notes: routineNotes, exerciseLogs: exerciseLogs);

    if (widget.log.id.isEmpty) {
      final datetime = TemporalDateTime.withOffset(updatedLog.startTime, Duration.zero);

      final createdLog = await Provider.of<ExerciseAndRoutineController>(context, listen: false)
          .saveLog(logDto: updatedLog, datetime: datetime);
      _navigateBack(log: createdLog);
    } else {
      await Provider.of<ExerciseAndRoutineController>(context, listen: false).updateLog(log: updatedLog);
    }
  }

  void _checkForUnsavedChanges() {
    final exerciseProvider = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLog1 = widget.log.exerciseLogs;
    final exerciseLog2 = exerciseProvider.mergeExerciseLogsAndSets(mode: RoutineEditorMode.edit);
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
    context.pop();
  }

  void _navigateBack({RoutineLogDto? log}) {
    Navigator.of(context).pop(log);
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

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _selectExercisesInLibrary, icon: const FaIcon(FontAwesomeIcons.solidSquarePlus, color: Colors.white)),
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
              : null,
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
              bottom: false,
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
                                fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.8), fontSize: 14),
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
                      if (exerciseLogs.isNotEmpty)
                        Expanded(
                            child: SingleChildScrollView(
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: const EdgeInsets.only(bottom: 250),
                                child: Column(children: [
                                  ...exerciseLogs.map((exerciseLog) {
                                    final isExerciseMinimised = _minimisedExerciseLogCards.contains(exerciseLog.id);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: isExerciseMinimised
                                          ? ExerciseLogLiteWidget(
                                              key: ValueKey(exerciseLog.id),
                                              exerciseLogDto: exerciseLog,
                                              superSet: whereOtherExerciseInSuperSet(
                                                  firstExercise: exerciseLog, exercises: exerciseLogs),
                                              onMaximise: () =>
                                                  _handleResizedExerciseLogCard(exerciseIdToResize: exerciseLog.id),
                                            )
                                          : ExerciseLogWidget(
                                              key: ValueKey(exerciseLog.id),
                                              exerciseLogDto: exerciseLog,
                                              editorType: RoutineEditorMode.edit,
                                              superSet: whereOtherExerciseInSuperSet(
                                                  firstExercise: exerciseLog, exercises: exerciseLogs),
                                              onRemoveSuperSet: (String superSetId) => exerciseLogController
                                                  .removeSuperSet(superSetId: exerciseLog.superSetId),
                                              onRemoveLog: () =>
                                                  exerciseLogController.removeExerciseLog(logId: exerciseLog.id),
                                              onReplaceLog: () =>
                                                  _showReplaceExercisePicker(oldExerciseLog: exerciseLog),
                                              onSuperSet: () =>
                                                  _showSuperSetExercisePicker(firstExerciseLog: exerciseLog),
                                              onResize: () =>
                                                  _handleResizedExerciseLogCard(exerciseIdToResize: exerciseLog.id),
                                              isMinimised: _isMinimised(exerciseLog.id),
                                              onTapWeightEditor: (SetDto setDto) {
                                                setState(() {
                                                  _selectedSetDto = setDto;
                                                });
                                              },
                                              onTapRepsEditor: (SetDto setDto) {
                                                setState(() {
                                                  _selectedSetDto = null;
                                                });
                                              },
                                            ),
                                    );
                                  }),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                      width: double.infinity,
                                      child: OpacityButtonWidget(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          buttonColor: vibrantGreen,
                                          label: "Log Past Session",
                                          onPressed: _createLog))
                                ]))
                        ),
                      if (exerciseLogs.isEmpty)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: const NoListEmptyState(
                                message: "Tap the + button to start adding exercises to your past workout session"),
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
        child: WeightPlateCalculator(target: (_selectedSetDto as WeightAndRepsSetDto?)?.weight ?? 0),
        padding: EdgeInsets.zero);
  }

  @override
  void initState() {
    super.initState();

    _initializeProcedureData();
    _initializeTextControllers();

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;
  }

  void _initializeProcedureData() {
    final exercises = widget.log.exerciseLogs;
    if (exercises.isNotEmpty) {
      final updatedExerciseLogs = exercises.map((exerciseLog) {
        final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
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
      _minimiseOrMaximiseCards();
    }
  }

  void _initializeTextControllers() {
    final log = widget.log;
    _templateNameController = TextEditingController(text: log.name);
    _templateNotesController = TextEditingController(text: log.notes);
  }

  void _minimiseOrMaximiseCards() {
    Provider.of<ExerciseLogController>(context, listen: false).exerciseLogs.forEach((exerciseLog) {
      final completedSets = exerciseLog.sets.where((set) => set.checked).length;
      final isExerciseCompleted = completedSets == exerciseLog.sets.length;
      if (isExerciseCompleted) {
        setState(() {
          _minimisedExerciseLogCards.add(exerciseLog.id);
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
