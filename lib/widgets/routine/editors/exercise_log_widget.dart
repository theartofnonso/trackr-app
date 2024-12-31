import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/screens/AI/stt_logging.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/weight_and_reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/weights_and_reps_set_row.dart';

import '../../../colors.dart';
import '../../../dtos/graph/chart_point_dto.dart';
import '../../../dtos/set_dtos/reps_dto.dart';
import '../../../dtos/set_dtos/set_dto.dart';
import '../../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../../enums/chart_unit_enum.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/one_rep_max_calculator.dart';
import '../../chart/line_chart_widget.dart';
import '../../dividers/label_divider.dart';
import '../preview/set_headers/double_set_header.dart';
import '../preview/set_headers/single_set_header.dart';
import '../preview/sets_listview.dart';

class ExerciseLogWidget extends StatefulWidget {
  final RoutineEditorMode editorType;

  final ExerciseLogDto exerciseLogDto;
  final ExerciseLogDto? superSet;

  final bool isMinimised;

  /// ExerciseLogDto callbacks
  final VoidCallback onRemoveLog;
  final VoidCallback onReplaceLog;
  final VoidCallback onSuperSet;
  final void Function(String superSetId) onRemoveSuperSet;
  final VoidCallback onResize;
  final void Function(SetDto setDto) onTapWeightEditor;
  final void Function(SetDto setDto) onTapRepsEditor;

  const ExerciseLogWidget(
      {super.key,
      this.editorType = RoutineEditorMode.edit,
      required this.exerciseLogDto,
      this.superSet,
      required this.onSuperSet,
      required this.onRemoveSuperSet,
      required this.onRemoveLog,
      required this.onReplaceLog,
      required this.onResize,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor,
      required this.isMinimised});

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget> {
  List<(TextEditingController, TextEditingController)> _weightAndRepsControllers = [];
  List<TextEditingController> _repsControllers = [];
  List<DateTime> _durationControllers = [];

  bool _showPreviousSets = false;

  void _show1RMRecommendations() {
    final pastExerciseLogs = Provider.of<ExerciseAndRoutineController>(context, listen: false)
            .exerciseLogsByExerciseId[widget.exerciseLogDto.id] ??
        [];
    final completedPastExerciseLogs = loggedExercises(exerciseLogs: pastExerciseLogs);
    if (completedPastExerciseLogs.isNotEmpty) {
      final previousLog = completedPastExerciseLogs.last;
      final heaviestSetWeight = heaviestWeightInSetForExerciseLog(exerciseLog: previousLog);
      final oneRepMax = average1RM(weight: (heaviestSetWeight).weight, reps: (heaviestSetWeight).reps);
      displayBottomSheet(
          context: context,
          child: _OneRepMaxSlider(exercise: widget.exerciseLogDto.exercise.name, oneRepMax: oneRepMax));
    } else {
      showBottomSheetWithNoAction(
          context: context,
          title: widget.exerciseLogDto.exercise.name,
          description: "Keep logging to see recommendations.");
    }
  }

  void _showRepRangeSelector({required int min, required int max}) {
    displayBottomSheet(
        context: context,
        child: _RepRangeSlider(
            exercise: widget.exerciseLogDto.exercise.name,
            min: min,
            max: max,
            onSelectRange: _updateExerciseLogRepRange));
  }

  void _updateExerciseLogNotes({required String value}) {
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateExerciseLogNotes(exerciseLogId: widget.exerciseLogDto.id, value: value);
  }

  void _updateExerciseLogRepRange(RangeValues values) {
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateExerciseLogRepRange(exerciseLogId: widget.exerciseLogDto.id, values: values);
  }

  void _loadControllers({required List<SetDto> sets}) {
    _clearControllers();

    if (withDurationOnly(type: widget.exerciseLogDto.exercise.type)) {
      _loadDurationControllers(sets: sets);
    }
    if (withWeightsOnly(type: widget.exerciseLogDto.exercise.type)) {
      _loadWeightAndRepsControllers(sets: sets);
    }
    if (withRepsOnly(type: widget.exerciseLogDto.exercise.type)) {
      _loadRepsControllers(sets: sets);
    }
  }

  void _clearControllers() {
    if (withDurationOnly(type: widget.exerciseLogDto.exercise.type)) {
      _durationControllers = [];
    }
    if (withWeightsOnly(type: widget.exerciseLogDto.exercise.type)) {
      _weightAndRepsControllers = [];
    }
    if (withRepsOnly(type: widget.exerciseLogDto.exercise.type)) {
      _repsControllers = [];
    }
  }

  void _disposeControllers() {
    if (withDurationOnly(type: widget.exerciseLogDto.exercise.type)) {
      // Duration is not have any controller to dispose
    }
    if (withWeightsOnly(type: widget.exerciseLogDto.exercise.type)) {
      for (final controllerPair in _weightAndRepsControllers) {
        controllerPair.$1.dispose();
        controllerPair.$2.dispose();
      }
    }
    if (withRepsOnly(type: widget.exerciseLogDto.exercise.type)) {
      for (final controller in _repsControllers) {
        controller.dispose();
      }
    }
  }

  void _addSet() {
    final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exercise: widget.exerciseLogDto.exercise);
    Provider.of<ExerciseLogController>(context, listen: false)
        .addSet(exerciseLogId: widget.exerciseLogDto.id, pastSets: pastSets);

    _loadControllers(sets: widget.exerciseLogDto.sets);
  }

  void _removeSet({required int index}) {
    Provider.of<ExerciseLogController>(context, listen: false)
        .removeSetForExerciseLog(exerciseLogId: widget.exerciseLogDto.id, index: index);

    _loadControllers(sets: widget.exerciseLogDto.sets);
  }

  void _updateWeight({required int index, required double weight, required SetDto setDto}) {
    final updatedSet = (setDto as WeightAndRepsSetDto).copyWith(weight: weight);
    widget.onTapWeightEditor(updatedSet);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateWeight(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet);
  }

  void _updateReps({required int index, required int reps, required SetDto setDto}) {
    final updatedSet =
        setDto is WeightAndRepsSetDto ? setDto.copyWith(reps: reps) : (setDto as RepsSetDto).copyWith(reps: reps);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateReps(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet);
  }

  void _checkAndUpdateDuration(
      {required int index, required Duration duration, required SetDto setDto, required bool checked}) {
    if (setDto.checked) {
      final duration = (setDto as DurationSetDto).duration;
      final startTime = DateTime.now().subtract(duration);
      _durationControllers[index] = startTime;
      _updateSetCheck(index: index, setDto: setDto);
    } else {
      final updatedSet = (setDto as DurationSetDto).copyWith(duration: duration, checked: checked);
      Provider.of<ExerciseLogController>(context, listen: false)
          .updateDuration(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet, notify: checked);

      _loadControllers(sets: widget.exerciseLogDto.sets);

      if (checked) {
        displayBottomSheet(
            context: context,
            child: _RPERatingSlider(
              rpeRating: setDto.rpeRating.toDouble(),
              onSelectRating: (int rpeRating) {
                final updatedSetWithRpeRating = updatedSet.copyWith(rpeRating: rpeRating);
                Provider.of<ExerciseLogController>(context, listen: false).updateRpeRating(
                    exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSetWithRpeRating);
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
        .updateDuration(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet, notify: true);

    _loadControllers(sets: widget.exerciseLogDto.sets);
  }

  void _updateSetCheck({required int index, required SetDto setDto}) {
    final checked = !setDto.checked;
    final updatedSet = setDto.copyWith(checked: checked);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateSetCheck(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet);

    _loadControllers(sets: widget.exerciseLogDto.sets);

    if (checked) {
      displayBottomSheet(
          context: context,
          child: _RPERatingSlider(
            rpeRating: setDto.rpeRating.toDouble(),
            onSelectRating: (int rpeRating) {
              final updatedSetWithRpeRating = updatedSet.copyWith(rpeRating: rpeRating);
              Provider.of<ExerciseLogController>(context, listen: false).updateRpeRating(
                  exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSetWithRpeRating);
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
    _weightAndRepsControllers.addAll(controllers);
  }

  void _loadRepsControllers({required List<SetDto> sets}) {
    List<TextEditingController> controllers = [];
    for (final set in sets) {
      final repsController = TextEditingController(text: (set as RepsSetDto).reps.toString());
      _repsControllers.add((repsController));
    }
    _repsControllers.addAll(controllers);
  }

  void _loadDurationControllers({required List<SetDto> sets}) {
    List<DateTime> controllers = [];
    for (final set in sets) {
      final duration = (set as DurationSetDto).duration;
      final startTime = DateTime.now().subtract(duration);
      controllers.add(startTime);
    }
    _durationControllers.addAll(controllers);
  }

  void _onTapWeightEditor({required SetDto setDto}) {
    widget.onTapWeightEditor(setDto);
  }

  void _onTapRepsEditor({required SetDto setDto}) {
    widget.onTapRepsEditor(setDto);
  }

  void _togglePreviousSets() {
    setState(() {
      _showPreviousSets = !_showPreviousSets;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadControllers(sets: widget.exerciseLogDto.sets);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _stt() async {
    final sets =
        await navigateWithSlideTransition(context: context, child: STTLoggingScreen(exerciseLog: widget.exerciseLogDto))
            as List<SetDto>?;
    if (sets != null) {
      if (mounted) {
        _loadControllers(sets: sets);

        Provider.of<ExerciseLogController>(context, listen: false)
            .overwriteSets(exerciseLogId: widget.exerciseLogDto.id, sets: sets);
      }
    }
  }

  final Map<int, Color> _intensityToColor = {
    1: vibrantGreen, // Bright green - very light
    2: Color(0xFF66FF66), // Light green
    3: Color(0xFF99FF99), // Soft green
    4: Color(0xFFFFFF66), // Yellow-green transition
    5: Color(0xFFFFFF33), // Yellow - moderate intensity
    6: Color(0xFFFFCC33), // Amber - challenging intensity
    7: Color(0xFFFF9933), // Orange - very hard
    8: Color(0xFFFF6633), // Deep orange - near maximal
    9: Color(0xFFFF3333), // Bright red - maximal effort
    10: Color(0xFFFF0000), // Red - absolute limit
  };

  Color _getIntensityColor({required int intensity}) {
    if (_intensityToColor.containsKey(intensity)) {
      return _intensityToColor[intensity]!;
    } else {
      throw ArgumentError("Invalid intensity level: $intensity");
    }
  }

  /// Analyzes a list of RPE ratings and returns a descriptive summary.
  String _getRpeTrendSummary({required List<int> ratings}) {
    bool isHigh(int rpe) => rpe >= 6;
    bool isLow(int rpe) => rpe <= 5;

    if (ratings.isEmpty) {
      return "No ratings provided.";
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
      return "You are pushing harder or might be fatigued.";
    }

    // If it doesn’t fit neatly into the above categories, just return a generic message
    // (e.g., in case of mixed RPEs but not strictly first-is-high-last-is-low).
    return switch (widget.exerciseLogDto.exercise.type) {
      ExerciseType.weights =>
        "You might be experimenting with different weights or rep ranges. Try maintaining a gradual progression",
      ExerciseType.bodyWeight =>
        "You might be experimenting with different rep ranges. Try maintaining a gradual progression",
      ExerciseType.duration =>
        "You might be experimenting with different durations. Try maintaining a gradual progression",
    };
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseLog = widget.exerciseLogDto;

    final currentSets = exerciseLog.sets;

    final superSetExerciseDto = widget.superSet;

    final exerciseType = exerciseLog.exercise.type;

    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exercise: widget.exerciseLogDto.exercise);

    final sets = _showPreviousSets ? previousSets : currentSets;

    final repRange = getRepRange(exerciseLog: exerciseLog);

    final minReps = repRange.$1;

    final maxReps = repRange.$2;

    final rpeRatings = sets.mapIndexed((index, set) => set.rpeRating).toList();
    List<ChartPointDto> chartPoints = rpeRatings.mapIndexed((index, rating) => ChartPointDto(index, rating)).toList();
    List<String> setIndexes = sets.mapIndexed((index, set) => "Set ${index + 1}").toList();
    List<Color> colors = rpeRatings.mapIndexed((index, rating) => _getIntensityColor(intensity: rating)).toList();

    final rpeTrendSummary = _getRpeTrendSummary(ratings: rpeRatings);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, // Set the background color
        borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
      ),
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
                      builder: (context) => ExerciseHomeScreen(exercise: widget.exerciseLogDto.exercise)));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.exerciseLogDto.exercise.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
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
              MenuAnchor(
                  builder: (BuildContext context, MenuController controller, Widget? child) {
                    return IconButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          FocusScope.of(context).unfocus();
                          controller.open();
                        }
                      },
                      icon: const Icon(Icons.more_horiz_rounded),
                      tooltip: 'Show menu',
                    );
                  },
                  menuChildren: [
                    MenuItemButton(
                      onPressed: widget.onReplaceLog,
                      child: Text(
                        "Replace",
                        style: GoogleFonts.ubuntu(),
                      ),
                    ),
                    widget.exerciseLogDto.superSetId.isNotEmpty
                        ? MenuItemButton(
                            onPressed: () => widget.onRemoveSuperSet(widget.exerciseLogDto.superSetId),
                            child: Text("Remove Super-set", style: GoogleFonts.ubuntu(color: Colors.red)),
                          )
                        : MenuItemButton(
                            onPressed: widget.onSuperSet,
                            child: Text("Super-set", style: GoogleFonts.ubuntu()),
                          ),
                    MenuItemButton(
                      onPressed: widget.onRemoveLog,
                      child: Text(
                        "Remove",
                        style: GoogleFonts.ubuntu(color: Colors.red),
                      ),
                    ),
                  ])
            ],
          ),
          TextField(
            controller: TextEditingController(text: widget.exerciseLogDto.notes),
            cursorColor: isDarkMode ? Colors.white : Colors.black,
            onChanged: (value) => _updateExerciseLogNotes(value: value),
            decoration: InputDecoration(
              hintText: "Enter notes",
            ),
            maxLines: null,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
          ),
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
                      firstLabel: weightLabel().toUpperCase(),
                      secondLabel: 'REPS',
                    ),
                  ExerciseType.bodyWeight => const RepsSetHeader(),
                  ExerciseType.duration => const DurationSetHeader()
                },
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
                ),
              ExerciseType.bodyWeight => _RepsSetListView(
                  sets: sets.map((set) => set as RepsSetDto).toList(),
                  updateSetCheck: _updateSetCheck,
                  removeSet: _removeSet,
                  updateReps: _updateReps,
                  controllers: _repsControllers,
                  onTapWeightEditor: _onTapWeightEditor,
                  onTapRepsEditor: _onTapRepsEditor,
                ),
              ExerciseType.duration => _DurationSetListView(
                  sets: sets.map((set) => set as DurationSetDto).toList(),
                  updateSetCheck: _updateSetCheck,
                  removeSet: _removeSet,
                  controllers: _durationControllers,
                  onTapWeightEditor: _onTapWeightEditor,
                  onTapRepsEditor: _onTapRepsEditor,
                  checkAndUpdateDuration: _checkAndUpdateDuration,
                  updateDuration: _updateDuration,
                ),
            },
          if (_showPreviousSets) SetsListview(type: exerciseType, sets: sets),
          if (sets.isNotEmpty)
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
                      interval: 1,
                      colors: colors.length >= 2 ? colors : []),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(rpeTrendSummary,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.8,
                          color: isDarkMode ? Colors.white70 : Colors.black)),
                ),
              ],
            ),
          const SizedBox(height: 2),
          if (withDurationOnly(type: exerciseType) && sets.isEmpty)
            Center(
              child: Text("Tap + to add a timer", style: Theme.of(context).textTheme.bodySmall),
            ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (exerciseType != ExerciseType.duration)
              OpacityButtonWidget(
                  onPressed: () => _showRepRangeSelector(min: minReps, max: maxReps),
                  label: "target reps: $minReps - $maxReps",
                  buttonColor: vibrantGreen),
            const Spacer(),
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
              onPressed: widget.onResize,
              icon: const Icon(Icons.close_fullscreen_rounded),
              tooltip: 'Maximise card',
            ),
            const SizedBox(
              width: 6,
            ),
            IconButton(
              onPressed: _addSet,
              icon: const FaIcon(FontAwesomeIcons.plus, size: 18),
              tooltip: 'Add new set',
            ),
          ])
        ],
      ),
    );
  }
}

class _WeightAndRepsSetListView extends StatelessWidget {
  final List<WeightAndRepsSetDto> sets;
  final List<(TextEditingController, TextEditingController)> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index, required int reps, required SetDto setDto}) updateReps;
  final void Function({required int index, required double weight, required SetDto setDto}) updateWeight;
  final void Function({required SetDto setDto}) onTapWeightEditor;
  final void Function({required SetDto setDto}) onTapRepsEditor;

  const _WeightAndRepsSetListView(
      {required this.sets,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.updateReps,
      required this.updateWeight,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return WeightsAndRepsSetRow(
        setDto: setDto,
        onCheck: () => updateSetCheck(index: index, setDto: setDto),
        onRemoved: () => removeSet(index: index),
        onChangedReps: (int value) => updateReps(index: index, reps: value, setDto: setDto),
        onChangedWeight: (double value) => updateWeight(index: index, weight: value, setDto: setDto),
        onTapWeightEditor: () => onTapWeightEditor(setDto: setDto),
        onTapRepsEditor: () => onTapRepsEditor(setDto: setDto),
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
  final List<RepsSetDto> sets;
  final List<TextEditingController> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index, required int reps, required SetDto setDto}) updateReps;
  final void Function({required SetDto setDto}) onTapWeightEditor;
  final void Function({required SetDto setDto}) onTapRepsEditor;

  const _RepsSetListView(
      {required this.sets,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.updateReps,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return RepsSetRow(
        setDto: setDto,
        onCheck: () => updateSetCheck(index: index, setDto: setDto),
        onRemoved: () => removeSet(index: index),
        onChangedReps: (int value) => updateReps(index: index, reps: value, setDto: setDto),
        onTapRepsEditor: () => onTapRepsEditor(setDto: setDto),
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
  final List<DurationSetDto> sets;
  final List<DateTime> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index, required Duration duration, required SetDto setDto, required bool checked})
      checkAndUpdateDuration;
  final void Function({required int index, required Duration duration, required SetDto setDto}) updateDuration;
  final void Function({required SetDto setDto}) onTapWeightEditor;
  final void Function({required SetDto setDto}) onTapRepsEditor;

  const _DurationSetListView(
      {required this.sets,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.checkAndUpdateDuration,
      required this.updateDuration,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return DurationSetRow(
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
    Map<int, int> _repToPercentage = {
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

    return _repToPercentage[reps] ?? 1;
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

    return _repToPercentage[absoluteRating] ?? "Extremely light — mostly warm-up weight";
  }

  @override
  void initState() {
    super.initState();
    _rpeRating = widget.rpeRating ?? 5;
  }
}

Map<int, String> _repToPercentage = {
  1: "Extremely light — mostly warm-up weight",
  2: "Very light — can easily perform many more reps",
  3: "Light — still feels comfortable",
  4: "Moderate — some effort required but manageable",
  5: "Challenging — you're working, yet not near failure",
  6: "Hard — beginning to feel significant strain",
  7: "Very hard — only a few reps left in the tank",
  8: "Near max — pushing close to muscular failure",
  9: "Maximal — maybe 1 rep left, if at all",
  10: "All-out — absolute limit, no reps left in reserve",
};
