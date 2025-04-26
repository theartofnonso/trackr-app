import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:tracker_app/widgets/icons/custom_icon.dart';
import 'package:tracker_app/widgets/information_containers/information_container_lite.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/weight_and_reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/weights_and_reps_set_row.dart';

import '../../../colors.dart';
import '../../../dtos/set_dtos/reps_dto.dart';
import '../../../dtos/set_dtos/set_dto.dart';
import '../../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/one_rep_max_calculator.dart';
import '../../depth_stack.dart';
import '../../empty_states/no_list_empty_state.dart';
import '../../weight_plate_calculator.dart';
import '../preview/set_headers/double_set_header.dart';
import '../preview/set_headers/single_set_header.dart';
import '../preview/sets_listview.dart';

class _ErrorMessage {
  final int index;
  final String message;

  _ErrorMessage({required this.index, required this.message});
}

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

  List<_ErrorMessage> _errorMessages = [];

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

    _errorMessages = [];
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
        .whereRecentSetsForExercise(exercise: _exerciseLog.exercise);
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
    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .wherePrevSetsForExercise(exercise: _exerciseLog.exercise);

    final previousWeights = previousSets.map((set) => (set as WeightAndRepsSetDto).weight).toList();

    final isOutSideOfRange = isOutsideReasonableRange(previousWeights, weight);
    if (isOutSideOfRange) {
      final message = _getWeightErrorMessage(weight: weight);
      _errorMessages.add(_ErrorMessage(index: index, message: message));
    } else {
      _errorMessages.removeWhere((errorToBeRemoved) => errorToBeRemoved.index == index);
    }

    _checkWeightRange(weight: weight, index: index);

    final updatedSet = (setDto as WeightAndRepsSetDto).copyWith(weight: weight);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateWeight(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSet);
  }

  void _updateReps({required int index, required int reps, required SetDto setDto}) {
    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .wherePrevSetsForExercise(exercise: _exerciseLog.exercise);

    final previousReps = previousSets
        .map((set) => switch (_exerciseLog.exercise.type) {
              ExerciseType.weights => (set as WeightAndRepsSetDto).reps,
              ExerciseType.bodyWeight => (set as RepsSetDto).reps,
              ExerciseType.duration => throw UnimplementedError(),
            })
        .toList();

    final isOutSideOfRange = isOutsideReasonableRange(previousReps, reps);
    if (isOutSideOfRange) {
      final message = _repsErrorMessage(reps: reps);
      _errorMessages.add(_ErrorMessage(index: index, message: message));
    } else {
      _errorMessages.removeWhere((errorToBeRemoved) => errorToBeRemoved.index == index);
    }

    _checkRepsRange(reps: reps, index: index);

    final updatedSet =
        setDto is WeightAndRepsSetDto ? setDto.copyWith(reps: reps) : (setDto as RepsSetDto).copyWith(reps: reps);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateReps(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSet);
  }

  void _updateDuration(
      {required int index, required Duration duration, required SetDto setDto, required bool shouldCheck}) {
    SetDto updatedSet = (setDto as DurationSetDto).copyWith(duration: duration, checked: shouldCheck);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateDuration(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSet, notify: true);
  }

  void _updateSetCheck({required int index, required SetDto setDto}) {
    if (setDto.isEmpty()) {
      showSnackbar(context: context, message: "Mind taking a look at the set values and confirming they’re correct?");
      return;
    }

    final checked = !setDto.checked;
    final updatedSet = setDto.copyWith(checked: checked);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateSetCheck(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSet);

    _loadControllers();

    final maxReps = switch (setDto.type) {
      ExerciseType.weights => (setDto as WeightAndRepsSetDto).reps,
      ExerciseType.bodyWeight => (setDto as RepsSetDto).reps,
      ExerciseType.duration => 0,
    };

    if (checked) {
      displayBottomSheet(
          context: context,
          child: _RPERatingSlider(
            maxReps: maxReps,
            rpeRating: setDto.rpeRating.toDouble(),
            onSelectRating: (int rpeRating) {
              final updatedSetWithRpeRating = updatedSet.copyWith(rpeRating: rpeRating);
              Provider.of<ExerciseLogController>(context, listen: false)
                  .updateRpeRating(exerciseLogId: _exerciseLog.id, index: index, setDto: updatedSetWithRpeRating);
            },
          ));
    }
  }

  void _checkWeightRange({required double weight, required int index}) {
    if (isDefaultWeightUnit()) {
      if (weight < 0.5 || weight > 500) {
        final message = 'Weight must be between 0.5 and 500 kg.';
        _errorMessages.add(_ErrorMessage(index: index, message: message));
      }
    } else {
      if (weight < 1 || weight > 1100) {
        final message = 'Weight must be between 1 and 1100 lbs.';
        _errorMessages.add(_ErrorMessage(index: index, message: message));
      }
    }
  }

  void _checkRepsRange({required int reps, required int index}) {
    if (reps <= 0) {
      final message = 'You need to complete at least 1 repetition.';
      _errorMessages.add(_ErrorMessage(index: index, message: message));
    }
  }

  void _loadWeightAndRepsControllers({required List<SetDto> sets}) {
    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .wherePrevSetsForExercise(exercise: _exerciseLog.exercise);

    final previousWeights = previousSets.map((set) => (set as WeightAndRepsSetDto).weight).toList();

    List<(TextEditingController, TextEditingController)> controllers = [];
    for (final (index, set) in sets.indexed) {
      final weight = (set as WeightAndRepsSetDto).weight;
      final reps = set.reps;

      final isOutSideOfRange = isOutsideReasonableRange(previousWeights, weight);
      if (isOutSideOfRange) {
        final message = _getWeightErrorMessage(weight: weight);
        _errorMessages.add(_ErrorMessage(index: index, message: message));
      } else {
        _errorMessages.removeWhere((errorToBeRemoved) => errorToBeRemoved.index == index);
      }

      _checkWeightRange(weight: weight, index: index);

      _checkRepsRange(reps: reps, index: index);

      final weightController = TextEditingController(text: (set).weight.toString());
      final repsController = TextEditingController(text: set.reps.toString());
      controllers.add((weightController, repsController));
    }
    setState(() {
      _weightAndRepsControllers = controllers;
    });
  }

  void _loadRepsControllers({required List<SetDto> sets}) {
    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .wherePrevSetsForExercise(exercise: _exerciseLog.exercise);

    final previousReps = previousSets
        .map((set) => switch (_exerciseLog.exercise.type) {
              ExerciseType.weights => (set as WeightAndRepsSetDto).reps,
              ExerciseType.bodyWeight => (set as RepsSetDto).reps,
              ExerciseType.duration => throw UnimplementedError(),
            })
        .toList();

    List<TextEditingController> controllers = [];
    for (final (index, set) in sets.indexed) {
      final reps = switch (_exerciseLog.exercise.type) {
        ExerciseType.weights => (set as WeightAndRepsSetDto).reps,
        ExerciseType.bodyWeight => (set as RepsSetDto).reps,
        ExerciseType.duration => throw UnimplementedError(),
      };
      final isOutSideOfRange = isOutsideReasonableRange(previousReps, reps);
      if (isOutSideOfRange) {
        final message = _repsErrorMessage(reps: reps);
        _errorMessages.add(_ErrorMessage(index: index, message: message));
      } else {
        _errorMessages.removeWhere((errorToBeRemoved) => errorToBeRemoved.index == index);
      }

      _checkRepsRange(reps: reps, index: index);

      final repsController = TextEditingController(text: (set as RepsSetDto).reps.toString());
      controllers.add(repsController);
    }
    setState(() {
      _repsControllers = controllers;
    });
  }

  String _repsErrorMessage({required int reps}) =>
      "Hmm, $reps ${pluralize(word: "rep", count: reps)} looks a bit off your usual range. Mind checking the value just to be sure?.";

  String _getWeightErrorMessage({required double weight}) =>
      "Hmm, $weight${weightUnit()} looks a bit off your usual range. Mind checking the value just to be sure?.";

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

    final recentSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereRecentSetsForExercise(exercise: exerciseLog.exercise);

    final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .wherePrevSetsForExercise(exercise: exerciseLog.exercise);

    final exerciseType = exerciseLog.exercise.type;

    final sets = _showPreviousSets ? recentSets : currentSets;

    String progressionSummary = "";
    String rpeTrendSummary = "";
    Color progressionColor = isDarkMode ? Colors.white70 : Colors.black54;
    TrainingProgression? trainingProgression;
    RepRange? typicalRepRange;

    /// Get working sets
    final workingSets = switch (exerciseType) {
      ExerciseType.weights => markHighestWeightSets(sets),
      ExerciseType.bodyWeight => markHighestRepsSets(sets),
      ExerciseType.duration => markHighestDurationSets(sets),
    }
        .where((set) => set.isWorkingSet)
        .toList();

    bool isAllSameWeight = false;

    if (exerciseType == ExerciseType.weights) {
      final weights = workingSets.map((set) => (set as WeightAndRepsSetDto).weight).toList();
      isAllSameWeight = allNumbersAreSame(numbers: weights);
    }

    /// Determine working set for weight
    final workingSet = switch (exerciseType) {
      ExerciseType.weights => isAllSameWeight ? getHeaviestVolume(workingSets) : getHighestWeight(workingSets),
      ExerciseType.bodyWeight => getHighestReps(workingSets),
      ExerciseType.duration => getLongestDuration(workingSets),
    };

    if (withWeightsOnly(type: exerciseType)) {
      /// Determine typical rep range using historic training data
      final sets = [...currentSets, ...previousSets];
      final reps = switch (exerciseType) {
        ExerciseType.weights => markHighestWeightSets(sets),
        ExerciseType.bodyWeight => markHighestRepsSets(sets),
        ExerciseType.duration => markHighestDurationSets(sets),
      }
          .map((set) {
        return switch (exerciseType) {
          ExerciseType.weights => (set as WeightAndRepsSetDto).reps,
          ExerciseType.bodyWeight => (set as RepsSetDto).reps,
          ExerciseType.duration => 0,
        };
      }).toList();

      typicalRepRange = determineTypicalRepRange(reps: reps);

      /// Determine progression for working sets where [ExerciseType] is [ExerciseType.weights]
      final trainingData = workingSets.map((set) {
        return TrainingData(reps: (set as WeightAndRepsSetDto).reps, weight: set.weight, rpe: set.rpeRating);
      }).toList();

      trainingProgression = getTrainingProgression(
          data: trainingData, targetMinReps: typicalRepRange.minReps, targetMaxReps: typicalRepRange.maxReps);
    }

    final weightsRepsDurationLabel = switch (exerciseType) {
      ExerciseType.weights => "weight",
      ExerciseType.bodyWeight => "reps",
      ExerciseType.duration => "duration",
    };

    /// Generate weight or reps progression summary
    if (previousSets.isNotEmpty) {
      progressionSummary = switch (trainingProgression) {
        TrainingProgression.increase =>
          ", time to take it up a notch, consider increasing the $weightsRepsDurationLabel of ${workingSet?.summary()}.",
        TrainingProgression.decrease =>
          ", dial it back a bit, consider reducing the $weightsRepsDurationLabel of ${workingSet?.summary()} for now.",
        TrainingProgression.maintain =>
          ", right on track, stick with your current $weightsRepsDurationLabel of ${workingSet?.summary()}.",
        null => "",
      };
    }

    /// Generate weight or reps progression color
    if (previousSets.isNotEmpty) {
      progressionColor = switch (trainingProgression) {
        TrainingProgression.increase => vibrantGreen,
        TrainingProgression.decrease => Colors.deepOrange,
        TrainingProgression.maintain => vibrantBlue,
        null => Colors.transparent,
      };
    }

    final isEmptySets = hasEmptyValues(sets: sets, exerciseType: exerciseType);

    if (isEmptySets) {
      progressionSummary = ".";
      progressionColor = vibrantBlue;
    }

    final rpeRatings = sets.mapIndexed((index, set) => set.rpeRating).toList();

    if (previousSets.isNotEmpty) {
      rpeTrendSummary = _getRpeTrendSummary(ratings: rpeRatings);
    }

    String? noRepRangeMessage;

    if (typicalRepRange?.maxReps == 0) {
      noRepRangeMessage = "Log more sets to determine your rep range.";
    } else {
      if (typicalRepRange?.minReps == typicalRepRange?.maxReps) {
        noRepRangeMessage =
            "${typicalRepRange?.minReps} is your max reps. if you comfortably hit ${typicalRepRange?.maxReps}, increase the weight; if you struggle to reach ${typicalRepRange?.maxReps}, reduce it; otherwise, maintain. Tap for more info.";
      }
    }

    final errorWidgets = _errorMessages
        .mapIndexed((index, error) => InformationContainerLite(
            content: error.message,
            color: Colors.yellow,
            useOpacity: false,
            onTap: () {
              setState(() {
                _errorMessages.removeWhere((errorToBeRemoved) => errorToBeRemoved.index == error.index);
              });
            }))
        .toList();

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
            icon: const FaIcon(FontAwesomeIcons.solidSquarePlus, size: 22),
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
        padding: const EdgeInsets.only(top: 20),
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          bottom: false,
          minimum: EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 50),
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                _showPreviousSets
                    ? switch (exerciseType) {
                        ExerciseType.weights => DoubleSetHeader(
                            firstLabel: "PREVIOUS ${weightUnit().toUpperCase()}".toUpperCase(),
                            secondLabel: 'PREVIOUS REPS'.toUpperCase(),
                          ),
                        ExerciseType.bodyWeight => SingleSetHeader(label: 'PREVIOUS REPS'.toUpperCase()),
                        ExerciseType.duration => SingleSetHeader(label: 'PREVIOUS TIME'.toUpperCase())
                      }
                    : switch (exerciseType) {
                        ExerciseType.weights => WeightAndRepsSetHeader(
                            editorType: widget.editorType,
                            firstLabel: weightUnit().toUpperCase(),
                            secondLabel: 'REPS',
                          ),
                        ExerciseType.bodyWeight => RepsSetHeader(
                            editorType: widget.editorType,
                          ),
                        ExerciseType.duration => DurationSetHeader(
                            editorType: widget.editorType,
                          )
                      },
                if (sets.isEmpty && !_showPreviousSets)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      NoListEmptyState(
                          showIcon: false, message: "Tap the + button to start adding sets to your exercise"),
                    ],
                  ),
                !_showPreviousSets
                    ? switch (exerciseType) {
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
                            onTapRepsEditor: _onTapRepsEditor,
                            editorType: widget.editorType,
                          ),
                        ExerciseType.duration => _DurationSetListView(
                            sets: sets.map((set) => set as DurationSetDto).toList(),
                            updateSetCheck: _updateSetCheck,
                            removeSet: _removeSet,
                            updateDuration: _updateDuration,
                            controllers: _durationControllers,
                            editorType: widget.editorType,
                          ),
                      }
                    : SetsListview(type: exerciseType, sets: sets),
                if (_errorMessages.isNotEmpty && _errorMessages.length > 1) DepthStack(children: errorWidgets),
                if (_errorMessages.isNotEmpty && _errorMessages.length == 1) errorWidgets.first,
                if (sets.isNotEmpty && widget.editorType == RoutineEditorMode.log && !isEmptySets)
                  StaggeredGrid.count(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, children: [
                    if (withReps(type: exerciseType) &&
                        trainingProgression != null &&
                        rpeTrendSummary.isNotEmpty &&
                        progressionSummary.isNotEmpty)
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: isDarkMode ? progressionColor.withValues(alpha: 0.1) : progressionColor,
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("$rpeTrendSummary$progressionSummary",
                                    style: GoogleFonts.ubuntu(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomIcon(FontAwesomeIcons.boltLightning, color: progressionColor),
                                  ],
                                ),
                              ]),
                        ),
                      ),

                    /// Only show for exercises that measure Weights, Reps and Duration
                    if (workingSet != null)
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: GestureDetector(
                          onTap: () => showBottomSheetWithNoAction(
                              context: context,
                              title: "Working Sets",
                              description:
                                  "Working sets are the primary, challenging sets performed after any warm-up sets. They provide the main training stimulus needed for muscle growth, strength gains, or endurance improvements."),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                              RichText(
                                text: TextSpan(
                                  text: workingSet.summary(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w700, fontSize: 14, height: 1.5),
                                  children: [
                                    TextSpan(
                                      text: " ",
                                    ),
                                    TextSpan(
                                      text:
                                          "is your most challenging set, driving you toward your training goals. Tap for more info.",
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          height: 1.5,
                                          color: isDarkMode ? Colors.white70 : Colors.black54),
                                    )
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomIcon(FontAwesomeIcons.w, color: vibrantGreen),
                                ],
                              ),
                            ]),
                          ),
                        ),
                      ),

                    /// Only show for exercises that measure Reps
                    if (typicalRepRange != null && withReps(type: exerciseType))
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: GestureDetector(
                          onTap: () => showBottomSheetWithNoAction(
                              context: context,
                              title: "Rep Range",
                              description:
                                  "Rep ranges acts as a guideline for adjusting weights. If you consistently hit the high end of your range with good form, it’s a signal to increase the load. Conversely, if you struggle to reach the low end, reduce the weight slightly until you can complete the set effectively."),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                              noRepRangeMessage != null
                                  ? Text(noRepRangeMessage,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontWeight: FontWeight.w700, height: 1.5))
                                  : RichText(
                                      text: TextSpan(
                                        text: "${typicalRepRange.minReps} - ${typicalRepRange.maxReps}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontWeight: FontWeight.w700, height: 1.5),
                                        children: [
                                          TextSpan(
                                            text: " ",
                                          ),
                                          TextSpan(
                                            text:
                                                "is your typical rep range. if you comfortably hit ${typicalRepRange.maxReps}, increase the weight; if you struggle to reach ${typicalRepRange.minReps}, reduce it; otherwise, maintain. Tap for more info.",
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                                height: 1.5),
                                          )
                                        ],
                                      ),
                                    ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomIcon(FontAwesomeIcons.r, color: vibrantGreen),
                                ],
                              ),
                            ]),
                          ),
                        ),
                      ),
                  ]),
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

    return Column(spacing: 8, children: children);
  }
}

class _RepsSetListView extends StatelessWidget {
  final RoutineEditorMode editorType;
  final List<RepsSetDto> sets;
  final List<TextEditingController> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index, required int reps, required SetDto setDto}) updateReps;
  final void Function() onTapRepsEditor;

  const _RepsSetListView(
      {required this.sets,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.updateReps,
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

    return Column(spacing: 8, children: children);
  }
}

class _DurationSetListView extends StatelessWidget {
  final RoutineEditorMode editorType;
  final List<DurationSetDto> sets;
  final List<DateTime> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function(
      {required int index,
      required Duration duration,
      required SetDto setDto,
      required bool shouldCheck}) updateDuration;

  const _DurationSetListView(
      {required this.sets,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
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
        startTime: controllers.isNotEmpty ? controllers[index] : DateTime.now(),
        onUpdateDuration: (Duration duration, bool shouldCheck) =>
            updateDuration(index: index, setDto: setDto, duration: duration, shouldCheck: shouldCheck),
      );
    }).toList();

    return Column(spacing: 8, children: children);
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
                text: "$_weight${weightUnit()}",
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

class _RPERatingSlider extends StatefulWidget {
  final double? rpeRating;
  final void Function(int rpeRating) onSelectRating;
  final int maxReps;

  const _RPERatingSlider({this.rpeRating = 5, required this.onSelectRating, required this.maxReps});

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
        Text("How hard was it to complete those ${widget.maxReps} reps?",
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

    return _repToRPE[absoluteRating] ?? "😅 Moderate (challenging but manageable)";
  }

  @override
  void initState() {
    super.initState();
    _rpeRating = widget.rpeRating ?? 5;
  }
}

Map<int, String> _repToRPE = {
  1: "😌 Effortless — pure warm-up",
  2: "🙂 Very easy — lots left in the tank",
  3: "😊 Easy — could do more",
  4: "😅 Comfortable — moving well",
  5: "😮‍💨 Moderate — starting to work",
  6: "🔥 Challenging — working hard",
  7: "😣 Hard — pushing myself",
  8: "🥵 Very hard — pushing myself harder",
  9: "🤯 Near max — serious effort",
  10: "💀 All out — absolute limit",
};