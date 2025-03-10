import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/progressive_overload_utils.dart';
import 'package:tracker_app/utils/sets_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/information_containers/information_container_lite.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/weight_and_reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/weights_and_reps_set_row.dart';

import '../../../colors.dart';
import '../../../controllers/routine_user_controller.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../dtos/set_dtos/reps_dto.dart';
import '../../../dtos/set_dtos/set_dto.dart';
import '../../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../../enums/chart_unit_enum.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../enums/training_goal_enums.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/one_rep_max_calculator.dart';
import '../../chart/line_chart_widget.dart';
import '../../dividers/label_divider.dart';
import '../../empty_states/no_list_empty_state.dart';
import '../../weight_plate_calculator.dart';
import '../preview/set_headers/double_set_header.dart';
import '../preview/set_headers/single_set_header.dart';
import '../preview/sets_listview.dart';

class ExerciseLogWidget extends StatefulWidget {
  final RoutineEditorMode editorType;

  final String exerciseLogId;
  final ExerciseLogDto? superSet;

  const ExerciseLogWidget(
      {super.key, this.editorType = RoutineEditorMode.edit, required this.exerciseLogId, this.superSet});

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget> {
  late ExerciseLogDto _exerciseLog;

  List<(TextEditingController, TextEditingController)> _weightAndRepsControllers = [];
  List<TextEditingController> _repsControllers = [];
  List<DateTime> _durationControllers = [];

  bool _showPreviousSets = false;

  SetDto? _selectedSetDto;

  void _show1RMRecommendations() {
    final pastExerciseLogs =
        Provider.of<ExerciseAndRoutineController>(context, listen: false).exerciseLogsByExerciseId[_exerciseLog.id] ??
            [];
    final completedPastExerciseLogs = loggedExercises(exerciseLogs: pastExerciseLogs);
    if (completedPastExerciseLogs.isNotEmpty) {
      final previousLog = completedPastExerciseLogs.last;
      final heaviestSetWeight = heaviestWeightInSetForExerciseLog(exerciseLog: previousLog);
      final oneRepMax = average1RM(weight: (heaviestSetWeight).weight, reps: (heaviestSetWeight).reps);
      displayBottomSheet(
          context: context, child: _OneRepMaxSlider(exercise: _exerciseLog.exercise.name, oneRepMax: oneRepMax));
    } else {
      showBottomSheetWithNoAction(
          context: context, title: _exerciseLog.exercise.name, description: "Keep logging to see recommendations.");
    }
  }

  void _updateExerciseLogNotes({required String value}) {
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateExerciseLogNotes(exerciseLogId: _exerciseLog.id, value: value);
  }

  void _loadControllers() {
    _clearControllers();

    final exerciseLog = Provider.of<ExerciseLogController>(context, listen: false)
        .whereExerciseLog(exerciseId: _exerciseLog.exercise.id);

    final sets = exerciseLog.sets;

    if (withDurationOnly(type: exerciseLog.exercise.type)) {
      _loadDurationControllers(sets: sets);
    }
    if (withWeightsOnly(type: exerciseLog.exercise.type)) {
      _loadWeightAndRepsControllers(sets: sets);
    }
    if (withRepsOnly(type: exerciseLog.exercise.type)) {
      _loadRepsControllers(sets: sets);
    }
  }

  void _clearControllers() {
    if (withDurationOnly(type: _exerciseLog.exercise.type)) {
      _durationControllers = [];
    }
    if (withWeightsOnly(type: _exerciseLog.exercise.type)) {
      _weightAndRepsControllers = [];
    }
    if (withRepsOnly(type: _exerciseLog.exercise.type)) {
      _repsControllers = [];
    }
  }

  void _disposeControllers() {
    if (withDurationOnly(type: _exerciseLog.exercise.type)) {
      // Duration does not have any controller to dispose
    }
    if (withWeightsOnly(type: _exerciseLog.exercise.type)) {
      for (final controllerPair in _weightAndRepsControllers) {
        controllerPair.$1.dispose();
        controllerPair.$2.dispose();
      }
    }
    if (withRepsOnly(type: _exerciseLog.exercise.type)) {
      for (final controller in _repsControllers) {
        controller.dispose();
      }
    }
  }

  void _addSet() {
    final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exercise: _exerciseLog.exercise);
    Provider.of<ExerciseLogController>(context, listen: false)
        .addSet(exerciseLogId: _exerciseLog.id, pastSets: pastSets);
    _loadControllers();
  }

  void _removeSet({required int index}) {
    Provider.of<ExerciseLogController>(context, listen: false)
        .removeSetForExerciseLog(exerciseLogId: _exerciseLog.id, index: index);
    _loadControllers();
  }

  void _updateWeight({required int index, required double weight, required SetDto setDto}) {
    final updatedSet = (setDto as WeightAndRepsSetDto).copyWith(weight: weight);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateWeight(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSet);
  }

  void _updateReps({required int index, required int reps, required SetDto setDto}) {
    final updatedSet =
        setDto is WeightAndRepsSetDto ? setDto.copyWith(reps: reps) : (setDto as RepsSetDto).copyWith(reps: reps);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateReps(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSet);
  }

  void _checkAndUpdateDuration(
      {required int index, required Duration duration, required SetDto setDto, required bool checked}) {
    if (setDto.isEmpty()) return;

    if (setDto.checked) {
      final duration = (setDto as DurationSetDto).duration;
      final startTime = DateTime.now().subtract(duration);
      _durationControllers[index] = startTime;
      _updateSetCheck(index: index, setDto: setDto);
    } else {
      final updatedSet = (setDto as DurationSetDto).copyWith(duration: duration, checked: checked);
      Provider.of<ExerciseLogController>(context, listen: false)
          .updateDuration(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSet, notify: checked);

      _loadControllers();

      if (checked) {
        displayBottomSheet(
            context: context,
            child: _RPERatingSlider(
              rpeRating: setDto.rpeRating.toDouble(),
              onSelectRating: (int rpeRating) {
                final updatedSetWithRpeRating = updatedSet.copyWith(rpeRating: rpeRating);
                Provider.of<ExerciseLogController>(context, listen: false)
                    .updateRpeRating(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSetWithRpeRating);
              },
            ));
      }
    }
  }

  void _updateDuration({required int index, required Duration duration, required SetDto setDto}) {
    SetDto updatedSet = setDto;
    if (setDto.checked) {
      updatedSet = (setDto as DurationSetDto).copyWith(duration: duration);
    } else {
      updatedSet = (setDto as DurationSetDto).copyWith(duration: duration, checked: true);
    }

    Provider.of<ExerciseLogController>(context, listen: false)
        .updateDuration(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSet, notify: true);

    _loadControllers();
  }

  void _updateSetCheck({required int index, required SetDto setDto}) {
    if (setDto.isEmpty()) return;

    if (setDto.isEmpty()) return;

    final checked = !setDto.checked;
    final updatedSet = setDto.copyWith(checked: checked);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateSetCheck(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSet);

    _loadControllers();

    if (checked) {
      displayBottomSheet(
          context: context,
          child: _RPERatingSlider(
            rpeRating: setDto.rpeRating.toDouble(),
            onSelectRating: (int rpeRating) {
              final updatedSetWithRpeRating = updatedSet.copyWith(rpeRating: rpeRating);
              Provider.of<ExerciseLogController>(context, listen: false)
                  .updateRpeRating(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSetWithRpeRating);
            },
          ));
    }
  }

  void _loadWeightAndRepsControllers({required List<SetDto> sets}) {
    List<(TextEditingController, TextEditingController)> controllers = [];
    for (final set in sets) {
      final weightController = TextEditingController(text: (set as WeightAndRepsSetDto).weight.toString());
      final repsController = TextEditingController(text: set.reps.toString());
      controllers.add((weightController, repsController));
    }
    setState(() {
      _weightAndRepsControllers = controllers;
    });
  }

  void _loadRepsControllers({required List<SetDto> sets}) {
    List<TextEditingController> controllers = [];
    for (final set in sets) {
      final repsController = TextEditingController(text: (set as RepsSetDto).reps.toString());
      controllers.add(repsController);
    }
    setState(() {
      _repsControllers = controllers;
    });
  }

  void _loadDurationControllers({required List<SetDto> sets}) {
    List<DateTime> controllers = [];
    for (final set in sets) {
      final duration = (set as DurationSetDto).duration;
      final startTime = DateTime.now().subtract(duration);
      controllers.add(startTime);
    }
    setState(() {
      _durationControllers = controllers;
    });
  }

  void _togglePreviousSets() {
    setState(() {
      _showPreviousSets = !_showPreviousSets;
    });
  }

  @override
  void initState() {
    super.initState();
    _exerciseLog =
        Provider.of<ExerciseLogController>(context, listen: false).whereExerciseLog(exerciseId: widget.exerciseLogId);
    _loadControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  Color _getIntensityColor({required int intensity}) {
    if (rpeIntensityToColor.containsKey(intensity)) {
      return rpeIntensityToColor[intensity]!;
    } else {
      throw ArgumentError("Invalid intensity level: $intensity");
    }
  }

  /// Analyzes a list of RPE ratings and returns a descriptive summary.
  String _getRpeTrendSummary({required List<int> ratings}) {
    bool isHigh(int rpe) => rpe >= 6;
    bool isLow(int rpe) => rpe <= 5;

    if (ratings.isEmpty) {
      return "No ratings provided";
    }
    if (ratings.length == 1) {
      // If there's only one data point, just describe that point.
      return "Keep pushing to see more insights";
    }

    // Determine if all ratings are high, all are low, or mixed.
    final allHigh = ratings.every(isHigh);
    final allLow = ratings.every(isLow);

    // Identify the first and last RPE
    final firstRpe = ratings.first;
    final lastRpe = ratings.last;

    // If all ratings are in the high range:
    if (allHigh) {
      return "High intensity - You're pushing hard";
    }

    // If all ratings are in the low range:
    if (allLow) {
      return "Low intensity - Your training feels manageable";
    }

    // If they’re not all high or all low, determine if it went high-to-low or low-to-high
    final firstIsHigh = isHigh(firstRpe);
    final lastIsHigh = isHigh(lastRpe);

    if (firstIsHigh && !lastIsHigh) {
      // High to low range
      return "Your intensity is dropping - You're pacing through sets";
    } else if (!firstIsHigh && lastIsHigh) {
      // Low to high range
      return "You are pushing harder or might be fatigued";
    }

    // If it doesn’t fit neatly into the above categories, just return a generic message
    // (e.g., in case of mixed RPEs but not strictly first-is-high-last-is-low).
    return switch (_exerciseLog.exercise.type) {
      ExerciseType.weights =>
        "You might be experimenting with different weights or rep ranges. Try maintaining a gradual progression",
      ExerciseType.bodyWeight =>
        "You might be experimenting with different rep ranges. Try maintaining a gradual progression",
      ExerciseType.duration =>
        "You might be experimenting with different durations. Try maintaining a gradual progression",
    };
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus(); // Dismisses the keyboard
  }

  void _showWeightCalculator() {
    displayBottomSheet(
        context: context,
        child: WeightPlateCalculator(target: (_selectedSetDto as WeightAndRepsSetDto?)?.weight ?? 0),
        padding: EdgeInsets.zero);
  }

  void _onTapWeightEditor({required SetDto setDto}) {
    setState(() {
      _selectedSetDto = setDto;
    });
  }

  void _onTapRepsEditor() {
    setState(() {
      _selectedSetDto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    final exerciseLog =
        Provider.of<ExerciseLogController>(context, listen: true).whereExerciseLog(exerciseId: widget.exerciseLogId);

    final currentSets = exerciseLog.sets;

    final superSetExerciseDto = widget.superSet;

    final exerciseType = exerciseLog.exercise.type;

    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exercise: exerciseLog.exercise);

    final sets = _showPreviousSets ? previousSets : currentSets;

    String progressionSummary = "";
    Color progressionColor = vibrantBlue;
    TrainingProgression trainingProgression = TrainingProgression.maintain;

    final trainingGoal =
        Provider.of<RoutineUserController>(context, listen: false).user?.trainingGoal ?? TrainingGoal.hypertrophy;

    final workingSets = switch (exerciseType) {
      ExerciseType.weights => markHighestWeightSets(sets),
      ExerciseType.bodyWeight => markHighestRepsSets(sets),
      ExerciseType.duration => markHighestDurationSets(sets),
    }
        .where((set) => set.isWorkingSet)
        .toList();

    if (withReps(type: exerciseType)) {
      final trainingData = workingSets.map((set) {
        if (exerciseType == ExerciseType.weights) {
          return TrainingData(reps: (set as WeightAndRepsSetDto).reps, rpe: set.rpeRating);
        }
        return TrainingData(reps: (set as RepsSetDto).reps, rpe: set.rpeRating);
      }).toList();

      trainingProgression = getTrainingProgression(trainingData, trainingGoal.minReps, trainingGoal.maxReps);
    }

    final workingSet = switch (exerciseType) {
      ExerciseType.weights => getHeaviestVolume(workingSets),
      ExerciseType.bodyWeight => getHighestReps(workingSets),
      ExerciseType.duration => getLongestDuration(workingSets),
    };

    final weightsOrRepsLabel = withWeightsOnly(type: exerciseType) ? "weight" : "reps";

    progressionSummary = switch (trainingProgression) {
      TrainingProgression.increase =>
        ", time to take it up a notch, increase the $weightsOrRepsLabel for ${workingSet?.summary()}.",
      TrainingProgression.decrease =>
        ", dial it back a bit, reduce the $weightsOrRepsLabel for ${workingSet?.summary()} for now.",
      TrainingProgression.maintain =>
        ", right on track, stick with your current $weightsOrRepsLabel for ${workingSet?.summary()}."
    };

    progressionColor = switch (trainingProgression) {
      TrainingProgression.increase => vibrantGreen,
      TrainingProgression.decrease => Colors.deepOrange,
      TrainingProgression.maintain => vibrantBlue
    };

    final isEmptySets = hasEmptyValues(sets: sets, exerciseType: exerciseType);

    if (isEmptySets) {
      progressionSummary = ".";
      progressionColor = vibrantBlue;
    }

    final rpeRatings = sets.mapIndexed((index, set) => set.rpeRating).toList();
    List<ChartPointDto> chartPoints = rpeRatings.mapIndexed((index, rating) => ChartPointDto(index, rating)).toList();
    List<String> setIndexes = sets.mapIndexed((index, set) => "Set ${index + 1}").toList();
    List<Color> rpeColors = rpeRatings.mapIndexed((index, rating) => _getIntensityColor(intensity: rating)).toList();

    final rpeTrendSummary = _getRpeTrendSummary(ratings: rpeRatings);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
          onPressed: context.pop,
        ),
        title: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ExerciseHomeScreen(exercise: exerciseLog.exercise)));
            },
            child: Text(exerciseLog.exercise.name)),
        actions: [
          IconButton(
            onPressed: _togglePreviousSets,
            icon: const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 16),
            tooltip: 'Exercise Log History',
          ),
          if (withWeightsOnly(type: exerciseType))
            IconButton(
              onPressed: _show1RMRecommendations,
              icon: const FaIcon(FontAwesomeIcons.solidLightbulb, size: 16),
              tooltip: 'Weights and Reps Recommendations',
            ),
          IconButton(
            onPressed: _addSet,
            icon: const FaIcon(FontAwesomeIcons.plus, size: 18),
            tooltip: 'Add new set',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isKeyboardOpen
          ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: UniqueKey(),
                    onPressed: _dismissKeyboard,
                    enableFeedback: true,
                    child: FaIcon(Icons.keyboard_hide_rounded),
                  ),
                  if (_selectedSetDto != null)
                    FloatingActionButton(
                      heroTag: UniqueKey(),
                      onPressed: _showWeightCalculator,
                      enableFeedback: true,
                      child: Image.asset(
                        'icons/dumbbells.png',
                        fit: BoxFit.contain,
                        color: isDarkMode ? Colors.white : Colors.white,
                        height: 24, // Adjust the height as needed
                      ),
                    )
                ],
              ),
            )
          : null,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          bottom: false,
          minimum: EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ExerciseHomeScreen(exercise: exerciseLog.exercise)));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (superSetExerciseDto != null)
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.link,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(superSetExerciseDto.exercise.name, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                        ],
                      ),
                    )),
                  ],
                ),
                TextField(
                  controller: TextEditingController(text: exerciseLog.notes),
                  cursorColor: isDarkMode ? Colors.white : Colors.black,
                  onChanged: (value) => _updateExerciseLogNotes(value: value),
                  decoration: InputDecoration(
                    hintText: "Enter notes",
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 2),
                _showPreviousSets
                    ? switch (exerciseType) {
                        ExerciseType.weights => DoubleSetHeader(
                            firstLabel: "PREVIOUS ${weightLabel().toUpperCase()}".toUpperCase(),
                            secondLabel: 'PREVIOUS REPS'.toUpperCase(),
                          ),
                        ExerciseType.bodyWeight => SingleSetHeader(label: 'PREVIOUS REPS'.toUpperCase()),
                        ExerciseType.duration => SingleSetHeader(label: 'PREVIOUS TIME'.toUpperCase())
                      }
                    : switch (exerciseType) {
                        ExerciseType.weights => WeightAndRepsSetHeader(
                            editorType: widget.editorType,
                            firstLabel: weightLabel().toUpperCase(),
                            secondLabel: 'REPS',
                          ),
                        ExerciseType.bodyWeight => RepsSetHeader(
                            editorType: widget.editorType,
                          ),
                        ExerciseType.duration => DurationSetHeader(
                            editorType: widget.editorType,
                          )
                      },
                if (sets.isEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      NoListEmptyState(
                          showIcon: false, message: "Tap the + button to start adding sets to your exercise"),
                    ],
                  ),
                if (sets.isNotEmpty && !_showPreviousSets)
                  switch (exerciseType) {
                    ExerciseType.weights => _WeightAndRepsSetListView(
                        sets: sets.map((set) => set as WeightAndRepsSetDto).toList(),
                        updateSetCheck: _updateSetCheck,
                        removeSet: _removeSet,
                        updateReps: _updateReps,
                        updateWeight: _updateWeight,
                        controllers: _weightAndRepsControllers,
                        onTapWeightEditor: _onTapWeightEditor,
                        onTapRepsEditor: _onTapRepsEditor,
                        editorType: widget.editorType,
                      ),
                    ExerciseType.bodyWeight => _RepsSetListView(
                        sets: sets.map((set) => set as RepsSetDto).toList(),
                        updateSetCheck: _updateSetCheck,
                        removeSet: _removeSet,
                        updateReps: _updateReps,
                        controllers: _repsControllers,
                        onTapWeightEditor: _onTapWeightEditor,
                        onTapRepsEditor: _onTapRepsEditor,
                        editorType: widget.editorType,
                      ),
                    ExerciseType.duration => _DurationSetListView(
                        sets: sets.map((set) => set as DurationSetDto).toList(),
                        updateSetCheck: _updateSetCheck,
                        removeSet: _removeSet,
                        controllers: _durationControllers,
                        checkAndUpdateDuration: _checkAndUpdateDuration,
                        updateDuration: _updateDuration,
                        editorType: widget.editorType,
                      ),
                  },
                if (_showPreviousSets) SetsListview(type: exerciseType, sets: sets),
                if (sets.isNotEmpty && widget.editorType == RoutineEditorMode.log)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 6),
                        child: LineChartWidget(
                            chartPoints: chartPoints,
                            periods: setIndexes,
                            unit: ChartUnit.number,
                            aspectRation: 3,
                            leftReservedSize: 20,
                            interval: 1,
                            colors: rpeColors),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                            "RPE (Rate of Perceived Exertion). A self-reported score (1 to 10) indicating how hard a set felt.",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.8,
                                color: isDarkMode ? Colors.white70 : Colors.black)),
                      ),
                      const SizedBox(height: 10),
                      InformationContainerLite(
                        content: "$rpeTrendSummary$progressionSummary",
                        color: progressionColor,
                        icon: FaIcon(
                          FontAwesomeIcons.boltLightning,
                          size: 18,
                        ),
                      ),
                      if (workingSet != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            InformationContainerLite(
                                richText: RichText(
                                  text: TextSpan(
                                    text: workingSet.summary(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                                    children: [
                                      TextSpan(
                                        text: " ",
                                      ),
                                      TextSpan(
                                        text: "is your most challenging set, driving you toward your training goals.",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontWeight: FontWeight.w700, color: Colors.white70),
                                      )
                                    ],
                                  ),
                                ),
                                content: "",
                                color: Colors.grey.shade400,
                                icon: Container(
                                    width: 18,
                                    height: 18,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? vibrantGreen.withValues(alpha: 0.1) : vibrantGreen,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.w,
                                        color: isDarkMode ? vibrantGreen : Colors.black,
                                        size: 8,
                                      ),
                                    ))),
                          ],
                        ),
                    ],
                  ),
                const SizedBox(height: 2),
                if (withDurationOnly(type: exerciseType) && sets.isEmpty)
                  Center(
                    child: Text("Tap + to add a timer", style: Theme.of(context).textTheme.bodySmall),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeightAndRepsSetListView extends StatelessWidget {
  final RoutineEditorMode editorType;
  final List<WeightAndRepsSetDto> sets;
  final List<(TextEditingController, TextEditingController)> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index, required int reps, required SetDto setDto}) updateReps;
  final void Function({required int index, required double weight, required SetDto setDto}) updateWeight;
  final void Function({required SetDto setDto}) onTapWeightEditor;
  final void Function() onTapRepsEditor;

  const _WeightAndRepsSetListView(
      {required this.sets,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.updateReps,
      required this.updateWeight,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor,
      required this.editorType});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return WeightsAndRepsSetRow(
        editorType: editorType,
        setDto: setDto,
        onCheck: () => updateSetCheck(index: index, setDto: setDto),
        onRemoved: () => removeSet(index: index),
        onChangedReps: (int value) => updateReps(index: index, reps: value, setDto: setDto),
        onChangedWeight: (double value) => updateWeight(index: index, weight: value, setDto: setDto),
        onTapWeightEditor: () => onTapWeightEditor(setDto: setDto),
        onTapRepsEditor: () => onTapRepsEditor(),
        controllers: controllers[index],
      );
    }).toList();

    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: children.length);
  }
}

class _RepsSetListView extends StatelessWidget {
  final RoutineEditorMode editorType;
  final List<RepsSetDto> sets;
  final List<TextEditingController> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index, required int reps, required SetDto setDto}) updateReps;
  final void Function({required SetDto setDto}) onTapWeightEditor;
  final void Function() onTapRepsEditor;

  const _RepsSetListView(
      {required this.sets,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.updateReps,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor,
      required this.editorType});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return RepsSetRow(
        editorType: editorType,
        setDto: setDto,
        onCheck: () => updateSetCheck(index: index, setDto: setDto),
        onRemoved: () => removeSet(index: index),
        onChangedReps: (int value) => updateReps(index: index, reps: value, setDto: setDto),
        onTapRepsEditor: () => onTapRepsEditor(),
        controller: controllers[index],
      );
    }).toList();

    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: children.length);
  }
}

class _DurationSetListView extends StatelessWidget {
  final RoutineEditorMode editorType;
  final List<DurationSetDto> sets;
  final List<DateTime> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index, required Duration duration, required SetDto setDto, required bool checked})
      checkAndUpdateDuration;
  final void Function({required int index, required Duration duration, required SetDto setDto}) updateDuration;

  const _DurationSetListView(
      {required this.sets,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.checkAndUpdateDuration,
      required this.updateDuration,
      required this.editorType});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return DurationSetRow(
        editorType: editorType,
        setDto: setDto,
        onCheck: () => updateSetCheck(index: index, setDto: setDto),
        onRemoved: () => removeSet(index: index),
        onCheckAndUpdateDuration: (Duration duration, {bool? checked}) =>
            checkAndUpdateDuration(index: index, duration: duration, setDto: setDto, checked: checked ?? false),
        startTime: controllers.isNotEmpty ? controllers[index] : DateTime.now(),
        onupdateDuration: (Duration duration) => updateDuration(index: index, duration: duration, setDto: setDto),
      );
    }).toList();

    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: children.length);
  }
}

class _OneRepMaxSlider extends StatefulWidget {
  final String exercise;
  final double oneRepMax;

  const _OneRepMaxSlider({required this.exercise, required this.oneRepMax});

  @override
  State<_OneRepMaxSlider> createState() => _OneRepMaxSliderState();
}

class _OneRepMaxSliderState extends State<_OneRepMaxSlider> {
  double _weight = 0.0;
  double _reps = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.exercise, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            text: "Based on your recent progress, consider:",
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: "\n",
              ),
              TextSpan(
                text: "$_weight${weightLabel()}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: " ",
              ),
              TextSpan(
                text: "for",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              TextSpan(text: " "),
              TextSpan(
                text: "${_reps.toInt()} ${pluralize(word: "rep", count: _reps.toInt())}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              )
            ],
          ),
        ),
        Slider(value: _reps, onChanged: onChanged, min: 1, max: 20, divisions: 19, thumbColor: vibrantGreen),
      ],
    );
  }

  void onChanged(double value) {
    HapticFeedback.heavyImpact();
    final weight = _weightForPercentage(reps: value.toInt());
    setState(() {
      _weight = weightWithConversion(value: weight).roundToDouble();
      _reps = value;
    });
  }

  int _percentageForReps(int reps) {
    // Define a map of reps to percentages
    Map<int, int> repToPercentage = {
      1: 100,
      2: 97,
      3: 94,
      4: 92,
      5: 89,
      6: 86,
      7: 83,
      8: 81,
      9: 78,
      10: 75,
      11: 73,
      12: 71,
      13: 70,
      14: 68,
      15: 67,
      16: 65,
      17: 64,
      18: 62,
      19: 61,
      20: 60,
    };

    return repToPercentage[reps] ?? 1;
  }

  double _weightForPercentage({required int reps}) {
    return (widget.oneRepMax * (_percentageForReps(reps) / 100)).roundToDouble();
  }

  @override
  void initState() {
    super.initState();
    _weight = _weightForPercentage(reps: 10);
  }
}

class _RepRangeSlider extends StatefulWidget {
  final String exercise;
  final int min;
  final int max;
  final void Function(RangeValues values) onSelectRange;

  const _RepRangeSlider({required this.exercise, required this.min, required this.max, required this.onSelectRange});

  @override
  State<_RepRangeSlider> createState() => _RepRangeSliderState();
}

class _RepRangeSliderState extends State<_RepRangeSlider> {
  int _min = 0;
  int _max = 0;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelDivider(
          label: "Select a rep range".toUpperCase(),
          labelColor: isDarkMode ? Colors.white : Colors.black,
          dividerColor: Colors.transparent,
          fontSize: 14,
        ),
        const SizedBox(height: 8),
        Text(
            "Setting rep ranges for each exercise helps you target specific fitness goals: low reps build strength, moderate reps grow muscle, and high reps improve endurance.",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
        const SizedBox(height: 8),
        Text(
            "Work towards the top of your rep range. If you’re consistently hitting it, increase the weight. If you’re stuck at the bottom, lower the weight.",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
        const SizedBox(height: 12),
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$_min ${pluralize(word: "rep", count: _min)}",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            FaIcon(
              FontAwesomeIcons.arrowRight,
              size: 20,
            ),
            Text("$_max ${pluralize(word: "rep", count: _max)}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))
          ],
        ),
        const SizedBox(height: 10),
        RangeSlider(
          values: RangeValues(_min.toDouble(), _max.toDouble()),
          onChanged: onChanged,
          min: 1,
          max: 20,
          activeColor: vibrantGreen,
          divisions: 19,
        ),
        const SizedBox(height: 10),
        SizedBox(
            width: double.infinity,
            height: 45,
            child: OpacityButtonWidget(label: "Select range", buttonColor: vibrantGreen, onPressed: onSelectRepRange))
      ],
    );
  }

  void onChanged(RangeValues values) {
    HapticFeedback.heavyImpact();
    setState(() {
      _min = values.start.toInt();
      _max = values.end.toInt();
    });
  }

  void onSelectRepRange() {
    Navigator.of(context).pop();
    widget.onSelectRange(RangeValues(_min.toDouble(), _max.toDouble()));
  }

  @override
  void initState() {
    super.initState();
    _min = widget.min;
    _max = widget.max;
  }
}

class _RPERatingSlider extends StatefulWidget {
  final double? rpeRating;
  final void Function(int rpeRating) onSelectRating;

  const _RPERatingSlider({this.rpeRating = 5, required this.onSelectRating});

  @override
  State<_RPERatingSlider> createState() => _RPERatingSliderState();
}

class _RPERatingSliderState extends State<_RPERatingSlider> {
  double _rpeRating = 1;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Rate this set on a scale of 1 - 10, 1 being barely any effort and 10 being max effort",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
        const SizedBox(height: 12),
        Text(
          _ratingDescription(_rpeRating),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Slider(value: _rpeRating, onChanged: onChanged, min: 1, max: 10, divisions: 9, thumbColor: vibrantGreen),
        const SizedBox(height: 10),
        SizedBox(
            width: double.infinity,
            height: 45,
            child: OpacityButtonWidget(
                label: "save rating".toUpperCase(), buttonColor: vibrantGreen, onPressed: onSelectRepRange)),
      ],
    );
  }

  void onChanged(double value) {
    HapticFeedback.heavyImpact();

    setState(() {
      _rpeRating = value;
    });
  }

  void onSelectRepRange() {
    Navigator.of(context).pop();
    final absoluteRating = _rpeRating.floor();
    widget.onSelectRating(absoluteRating);
  }

  String _ratingDescription(double rating) {
    final absoluteRating = rating.floor();

    return _repToPercentage[absoluteRating] ?? "😅 Moderate (challenging but manageable)";
  }

  @override
  void initState() {
    super.initState();
    _rpeRating = widget.rpeRating ?? 5;
  }
}

Map<int, String> _repToPercentage = {
  1: "😌 Barely any effort (warm-up weight)",
  2: "🙂 Very light (can do many more reps)",
  3: "😊 Light (feels comfortable)",
  4: "😅 Moderate (challenging but manageable)",
  5: "😮‍💨 Tough (working hard, not near failure)",
  6: "🔥 Hard (around 3 reps left in the tank)",
  7: "😣 Very hard (about 2 reps left)",
  8: "🥵 Near max (1–2 reps left)",
  9: "🤯 Maximal (maybe 1 rep left)",
  10: "💀 Absolute limit (no reps left)",
};
