import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/routine_editors_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/buttons/opacity_circle_button_widget.dart';
import 'package:tracker_app/widgets/label_divider.dart';
import 'package:tracker_app/widgets/routine/editors/exercise_log_widget_lite.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../controllers/routine_template_controller.dart';
import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/app_analytics.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/empty_states/exercise_log_empty_state.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/timers/routine_timer.dart';

class RoutineLogEditorScreen extends StatefulWidget {
  static const routeName = '/routine-log-editor';

  final RoutineLogDto log;
  final RoutineEditorMode mode;

  const RoutineLogEditorScreen({super.key, required this.log, required this.mode});

  @override
  State<RoutineLogEditorScreen> createState() => _RoutineLogEditorScreenState();
}

class _RoutineLogEditorScreenState extends State<RoutineLogEditorScreen> with WidgetsBindingObserver {
  late Function _onDisposeCallback;

  final _minimisedExerciseLogCards = <String>[];

  void _selectExercisesInLibrary() async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          controller.addExerciseLogs(exercises: selectedExercises);
          _cacheLog();
        });
  }

  void _selectSubstituteExercisesInLibrary({required ExerciseLogDto primaryExerciseLog}) async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((exercise) => exercise.exercise).toList();
    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          controller.addAlternates(primaryExerciseId: primaryExerciseLog.id, exercises: selectedExercises);
          _showSubstituteExercisePicker(primaryExerciseLog: primaryExerciseLog);
          _cacheLog();
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
          _cacheLog();
        },
        selectExercisesInLibrary: () {
          _closeDialog();
          _selectExercisesInLibrary();
        });
  }

  void _showSubstituteExercisePicker({required ExerciseLogDto primaryExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    showSubstituteExercisePicker(
        context: context,
        primaryExerciseLog: primaryExerciseLog,
        otherExercises: primaryExerciseLog.substituteExercises,
        onSelected: (secondaryExercise) {
          _closeDialog();
          final foundExerciseLog = controller.exerciseLogs
              .firstWhereOrNull((exerciseLog) => exerciseLog.exercise.id == secondaryExercise.id);
          if (foundExerciseLog == null) {
            controller.replaceExerciseLog(oldExerciseId: primaryExerciseLog.id, newExercise: secondaryExercise);
            _cacheLog();
          } else {
            showSnackbar(
                context: context,
                icon: const FaIcon(FontAwesomeIcons.circleInfo),
                message: "${foundExerciseLog.exercise.name} has already been added");
          }
        },
        onRemoved: (ExerciseDto secondaryExercise) {
          controller.removeAlternates(
              primaryExerciseId: primaryExerciseLog.id, secondaryExerciseId: secondaryExercise.id);
          _cacheLog();
        },
        selectExercisesInLibrary: () {
          _closeDialog();
          _selectSubstituteExercisesInLibrary(primaryExerciseLog: primaryExerciseLog);
        });
  }

  void _showReplaceExercisePicker({required ExerciseLogDto oldExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          controller.replaceExerciseLog(oldExerciseId: oldExerciseLog.id, newExercise: selectedExercises.first);
          _cacheLog();
        });
  }

  RoutineLogDto _routineLog() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets();

    final routineLog = widget.log.copyWith(exerciseLogs: exerciseLogs);

    return routineLog;
  }

  Future<void> _doCreateRoutineLog() async {
    final routineLog = _routineLog();

    final routineLogToBeUpdated = routineLog.copyWith(endTime: DateTime.now());

    final updatedRoutineLog =
        await Provider.of<RoutineLogController>(context, listen: false).saveLog(logDto: routineLogToBeUpdated);

    workoutSessionLogged();

    if (updatedRoutineLog != null) {
      if (updatedRoutineLog.templateId.isNotEmpty) {
        await _updateRoutineTemplate(log: updatedRoutineLog);
      }
    }
    _navigateBack(routineLog: updatedRoutineLog);
  }

  Future<void> _doUpdateRoutineLog() async {
    final routineLog = _routineLog();

    await Provider.of<RoutineLogController>(context, listen: false).updateLog(log: routineLog);

    _updateRoutineTemplate(log: routineLog);

    if (routineLog.templateId.isNotEmpty) {
      await _updateRoutineTemplate(log: routineLog);
    }
    _navigateBack(routineLog: routineLog);
  }

  bool _isRoutinePartiallyComplete() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets();
    return exerciseLogs.any((log) => log.sets.any((set) => set.checked));
  }

  void _discardLog() {
    showBottomSheetWithMultiActions(
        context: context,
        title: "Discard workout?",
        description: "Do you want to discard this workout",
        leftAction: _closeDialog,
        rightAction: () {
          _closeDialog();
          _navigateBack();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Discard',
        isRightActionDestructive: true);
  }

  void _saveLog() {
    final isRoutinePartiallyComplete = _isRoutinePartiallyComplete();
    if (isRoutinePartiallyComplete) {
      showBottomSheetWithMultiActions(
          context: context,
          title: 'Running Session',
          description: "Do you want to end workout?",
          leftAction: context.pop,
          rightAction: () {
            _closeDialog();
            _doCreateRoutineLog();
          },
          leftActionLabel: 'Cancel',
          rightActionLabel: 'End',
          rightActionColor: vibrantGreen);
    } else {
      showBottomSheetWithNoAction(context: context, description: "Complete some sets!", title: 'Running Session');
    }
  }

  void _updateLog() {
    final isRoutinePartiallyComplete = _isRoutinePartiallyComplete();
    if (isRoutinePartiallyComplete) {
      _doUpdateRoutineLog();
    } else {
      showBottomSheetWithNoAction(context: context, description: "Complete some sets!", title: 'Update Workout');
    }
  }

  Future<void> _updateRoutineTemplate({required RoutineLogDto log}) async {
    final template =
        Provider.of<RoutineTemplateController>(context, listen: false).templateWhere(id: widget.log.templateId);
    if (template != null) {
      await _doUpdateTemplate(log: log, templateToUpdate: template);
    }
  }

  void _cacheLog() {
    if (widget.mode == RoutineEditorMode.log) {
      final routineLog = _routineLog();
      final updatedRoutineLog = routineLog.copyWith(endTime: DateTime.now());
      Provider.of<RoutineLogController>(context, listen: false).cacheLog(logDto: updatedRoutineLog);
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _reOrderExerciseLogs({required List<ExerciseLogDto> exerciseLogs}) async {
    final orderedList = await reOrderExerciseLogs(context: context, exerciseLogs: exerciseLogs);
    if (mounted) {
      if (orderedList != null) {
        Provider.of<ExerciseLogController>(context, listen: false).reOrderExerciseLogs(reOrderedList: orderedList);
        _cacheLog();
      }
    }
  }

  void _cleanUpSession() {
    SharedPrefs().remove(key: SharedPrefs().cachedRoutineLogKey);
    if (Platform.isIOS) {
      FlutterLocalNotificationsPlugin().cancel(999);
    }
  }

  void _navigateBack({RoutineLogDto? routineLog}) async {
    if (widget.mode == RoutineEditorMode.log) {
      _cleanUpSession();
    }
    context.pop(routineLog);
  }

  Future<void> _doUpdateTemplate({required RoutineLogDto log, required RoutineTemplateDto templateToUpdate}) async {
    final exerciseLogs = log.exerciseLogs.map((exerciseLog) {
      final newSets = exerciseLog.sets.map((set) => set.copyWith(checked: false)).toList();
      return exerciseLog.copyWith(sets: newSets);
    }).toList();
    final updatedTemplate = templateToUpdate.copyWith(exerciseTemplates: exerciseLogs);
    await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: updatedTemplate);
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
    final routineLogEditorController = Provider.of<RoutineLogController>(context, listen: true);

    if (routineLogEditorController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: routineLogEditorController.errorMessage);
      });
    }

    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = context.select((ExerciseLogController controller) => controller.exerciseLogs);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return PopScope(
        canPop: false,
        child: Scaffold(
            backgroundColor: sapphireDark,
            appBar: AppBar(
              backgroundColor: sapphireDark80,
              leading: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                  onPressed: _discardLog),
              title: Text(
                widget.log.name,
                style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(
                    key: const Key('select_exercises_in_library_btn'),
                    onPressed: _selectExercisesInLibrary,
                    icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white)),
                if (exerciseLogs.length > 1)
                  IconButton(
                      onPressed: () => _reOrderExerciseLogs(exerciseLogs: exerciseLogs),
                      icon: const FaIcon(FontAwesomeIcons.barsStaggered, color: Colors.white))
              ],
            ),
            floatingActionButton: isKeyboardOpen
                ? FloatingActionButton.extended(
                    heroTag: UniqueKey(),
                    onPressed: _showWeightCalculator,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    label:
                        Text("Calculator", style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600)),
                  )
                : FloatingActionButton.extended(
                    heroTag: UniqueKey(),
                    onPressed: widget.mode == RoutineEditorMode.log ? _saveLog : _updateLog,
                    backgroundColor: vibrantGreen.withOpacity(0.1),
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    label: Text("Finish workout",
                        style: GoogleFonts.ubuntu(color: vibrantGreen, fontWeight: FontWeight.w600)),
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
              child: Stack(children: [
                SafeArea(
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
                          if (widget.mode == RoutineEditorMode.log)
                            Column(children: [
                              Consumer<ExerciseLogController>(
                                  builder: (BuildContext context, ExerciseLogController provider, Widget? child) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: _RoutineLogOverview(
                                    exercisesSummary:
                                        "${provider.completedExerciseLog().length}/${provider.exerciseLogs.length}",
                                    setsSummary:
                                        "${provider.completedSets().length}/${provider.exerciseLogs.expand((exerciseLog) => exerciseLog.sets).length}",
                                    timer: RoutineTimer(
                                      startTime: widget.log.startTime,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 20),
                            ]),
                          if (exerciseLogs.isNotEmpty)
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 250),
                                child: Column(children: [
                                  ...exerciseLogs.map((exerciseLog) {
                                    final log = exerciseLog;
                                    final exerciseId = log.id;

                                    final isExerciseMinimised = _minimisedExerciseLogCards.contains(exerciseId);

                                    return Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: isExerciseMinimised
                                            ? ExerciseLogLiteWidget(
                                                key: ValueKey(exerciseId),
                                                exerciseLogDto: log,
                                                superSet: whereOtherExerciseInSuperSet(
                                                    firstExercise: log, exercises: exerciseLogs),
                                                onMaximise: () =>
                                                    _handleResizedExerciseLogCard(exerciseIdToResize: exerciseId),
                                              )
                                            : ExerciseLogWidget(
                                                key: ValueKey(exerciseId),
                                                exerciseLogDto: log,
                                                editorType: RoutineEditorMode.log,
                                                superSet: whereOtherExerciseInSuperSet(
                                                    firstExercise: log, exercises: exerciseLogs),
                                                onRemoveSuperSet: (String superSetId) {
                                                  exerciseLogController.removeSuperSet(superSetId: log.superSetId);
                                                  _cacheLog();
                                                },
                                                onRemoveLog: () {
                                                  exerciseLogController.removeExerciseLog(logId: exerciseId);
                                                  _cacheLog();
                                                },
                                                onSuperSet: () => _showSuperSetExercisePicker(firstExerciseLog: log),
                                                onCache: _cacheLog,
                                                onReplaceLog: () => _showReplaceExercisePicker(oldExerciseLog: log),
                                                onResize: () =>
                                                    _handleResizedExerciseLogCard(exerciseIdToResize: exerciseId),
                                                isMinimised: _isMinimised(exerciseId),
                                                onAlternate: () =>
                                                    _showSubstituteExercisePicker(primaryExerciseLog: log),
                                              ));
                                  })
                                ]),
                              ),
                            ),
                          if (exerciseLogs.isEmpty)
                            const ExerciseLogEmptyState(
                                mode: RoutineEditorMode.log,
                                message: "Tap the + button to start adding exercises to your log"),
                        ],
                      ),
                    ),
                  ),
                )
              ]),
            )));
  }

  void _showWeightCalculator() {
    displayBottomSheet(context: context, child: WeightCalculator(), padding: EdgeInsets.zero);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeProcedureData();

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cacheLog();
    });
  }

  void _initializeProcedureData() {
    final exerciseLogs = widget.log.exerciseLogs;
    final updatedExerciseLogs = exerciseLogs.map((exerciseLog) {
      final previousSets = Provider.of<RoutineLogController>(context, listen: false)
          .whereSetsForExercise(exercise: exerciseLog.exercise);
      if (previousSets.isNotEmpty) {
        final hasCurrentSets = exerciseLog.sets.isNotEmpty;
        final unCheckedSets = previousSets
            .take(exerciseLog.sets.length)
            .mapIndexed((index, set) => set.copyWith(checked: hasCurrentSets ? exerciseLog.sets[index].checked : false))
            .toList();
        return exerciseLog.copyWith(sets: unCheckedSets);
      }
      return exerciseLog;
    }).toList();
    Provider.of<ExerciseLogController>(context, listen: false)
        .loadExerciseLogs(exerciseLogs: updatedExerciseLogs, mode: widget.mode);
    _minimiseOrMaximiseCards();
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
    WidgetsBinding.instance.removeObserver(this);
    _onDisposeCallback();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Platform.isIOS) {
        FlutterLocalNotificationsPlugin().cancel(999);
      }
    }

    if (state == AppLifecycleState.paused) {
      if (Platform.isIOS) {
        FlutterLocalNotificationsPlugin().periodicallyShow(
            999,
            "${widget.log.name} is still running",
            "Tap to continue training",
            RepeatInterval.hourly,
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                presentAlert: false,
                presentBadge: false,
                presentSound: false,
                presentBanner: false,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exact);
      }
    }
  }
}

class _RoutineLogOverview extends StatelessWidget {
  final String exercisesSummary;
  final String setsSummary;
  final Widget timer;

  const _RoutineLogOverview({required this.exercisesSummary, required this.setsSummary, required this.timer});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(5), // rounded border
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Table(
          border: TableBorder(verticalInside: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(children: [
              Text("EXERCISES",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)),
              Text("SETS",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)),
              Text("DURATION",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600))
            ]),
            const TableRow(children: [SizedBox(height: 4), SizedBox(height: 4), SizedBox(height: 4)]),
            TableRow(children: [
              Text(exercisesSummary,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600)),
              Text(setsSummary,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600)),
              Center(child: timer)
            ])
          ],
        ));
  }
}

class WeightCalculator extends StatefulWidget {
  const WeightCalculator({super.key});

  @override
  State<WeightCalculator> createState() => _WeightCalculatorState();
}

class _WeightCalculatorState extends State<WeightCalculator> {
  final List<PlatesEnum> _selectedPlates = [];
  BarsEnum _selectedBar = BarsEnum.twenty;

  @override
  Widget build(BuildContext context) {
    final plates = PlatesEnum.values
        .map((plate) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: OpacityCircleButtonWidget(
                  padding: EdgeInsets.all(16),
                  onPressed: () => _onSelectPlate(newPlate: plate),
                  buttonColor: _getPlate(plate: plate) != null ? vibrantGreen : null,
                  label: "${weightWithConversion(value: plate.weight)}"),
            ))
        .toList();

    final bars = BarsEnum.values
        .map((bar) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: OpacityButtonWidget(
                  onPressed: () => _onSelectBar(newBar: bar),
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  buttonColor: _selectedBar == bar ? vibrantGreen : null,
                  label: "${weightWithConversion(value: bar.weight)}"),
            ))
        .toList();

    final weightSuggestions = _findClosestWeightCombination(targetWeight: 150);

    final plateSuggestions = weightSuggestions.map((weight) => PlatesEnum.fromDouble(weight));

    final weightEstimate = (weightSuggestions.sum.toInt() * 2) + _selectedBar.weight;
    print(_selectedBar.weight);
    final isExact = weightEstimate == 150;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("${weightWithConversion(value: 150)}${weightLabel()}".toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(
            height: 2,
          ),
          Text("Target Weight".toUpperCase(),
              textAlign: TextAlign.start,
              style: GoogleFonts.ubuntu(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(
            height: 18,
          ),
          _Bar(
            bar: _selectedBar,
            plates: plateSuggestions.sorted((a, b) => b.weight.compareTo(a.weight)),
          ),
          if (_selectedPlates.isNotEmpty && !isExact)
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 2),
              child: Text(
                  "Closest estimate is ${weightWithConversion(value: weightEstimate)}${weightLabel()}".toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.w700)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
            child: LabelDivider(
                label: "Available Weights (${weightLabel()})".toUpperCase(),
                labelColor: Colors.white70,
                dividerColor: sapphireLighter),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [SizedBox(width: 16), ...plates],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
            child: LabelDivider(
              label: "Available Bar (${weightLabel()})".toUpperCase(),
              labelColor: Colors.white70,
              dividerColor: sapphireLighter,
              leftToRight: false,
            ),
          ),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [SizedBox(width: 16), ...bars])),
        ],
      ),
    );
  }

  void _onSelectPlate({required PlatesEnum newPlate}) {
    final oldPlate = _selectedPlates.firstWhereOrNull((previousPlate) => previousPlate.weight == newPlate.weight);
    setState(() {
      if (oldPlate != null) {
        _selectedPlates.remove(oldPlate);
      } else {
        _selectedPlates.add(newPlate);
      }
    });
  }

  void _onSelectBar({required BarsEnum newBar}) {
    setState(() {
      _selectedBar = newBar;
    });
  }

  PlatesEnum? _getPlate({required PlatesEnum plate}) =>
      _selectedPlates.firstWhereOrNull((previousPlate) => previousPlate.weight == plate.weight);

  List<double> _findClosestWeightCombination({required double targetWeight}) {
    // Calculate the weight needed for one side
    double halfTargetWeight = (targetWeight - _selectedBar.weight) / 2;

    // Sort weights in descending order for better efficiency
    _selectedPlates.sort((a, b) => b.weight.compareTo(a.weight));

    List<double> bestCombination = [];
    double bestSum = 0;

    // Recursive function to find the best combination
    void findCombination(List<double> currentCombination, double currentSum, int index) {
      if (currentSum > halfTargetWeight) return;

      if (currentSum > bestSum) {
        bestSum = currentSum;
        bestCombination = List.from(currentCombination);
      }

      for (int i = index; i < _selectedPlates.length; i++) {
        currentCombination.add(_selectedPlates[i].weight);
        findCombination(currentCombination, currentSum + _selectedPlates[i].weight, i);
        currentCombination.removeLast();
      }
    }

    findCombination([], 0, 0);

    return bestCombination;
  }
}

class _Bar extends StatelessWidget {
  final BarsEnum bar;
  final List<PlatesEnum> plates;

  const _Bar({required this.bar, required this.plates});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        Container(
            width: 100,
            height: 20,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white24,
                  Colors.white70,
                ],
              ),
            ),
            child: Center(
              child: Text("${weightWithConversion(value: bar.weight)}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold)),
            )),
        Container(
            width: 15,
            height: 40,
            decoration: const BoxDecoration(
              color: sapphireDark60,
            )),
        ...plates.map((plate) => _Plate(plate: plate)),
        Container(
            width: 10,
            height: 20,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white24,
                  Colors.white70,
                ],
              ),
            ))
      ]),
    );
  }
}

class _Plate extends StatelessWidget {
  final PlatesEnum plate;

  const _Plate({
    required this.plate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: plate.width,
      height: plate.height,
      margin: EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sapphireDark60, sapphireDark80, sapphireDark],
        ),
      ),
      child: Center(
        child: Text("${weightWithConversion(value: plate.weight)}",
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

enum PlatesEnum {
  twentyFive(weight: 25, height: 100, width: 38),
  twenty(weight: 20, height: 90, width: 36),
  fifteen(weight: 15, height: 80, width: 38),
  ten(weight: 10, height: 70, width: 38),
  five(weight: 5, height: 60, width: 38),
  twoFive(weight: 2.5, height: 50, width: 38),
  oneTwoFive(weight: 1.25, height: 40, width: 38),
  zeroFive(weight: 0.5, height: 30, width: 38);

  final double weight;
  final double height;
  final double width;

  const PlatesEnum({required this.weight, required this.height, required this.width});

  static PlatesEnum fromDouble(double weight) {
    return PlatesEnum.values.firstWhere((value) => value.weight == weight);
  }
}

enum BarsEnum {
  twenty(weight: 20),
  fifteen(weight: 15),
  ten(weight: 10),
  five(weight: 5),
  sevenFive(weight: 7.5),
  zero(weight: 0.0);

  final double weight;

  const BarsEnum({required this.weight});
}
