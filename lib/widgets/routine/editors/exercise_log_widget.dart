import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/weight_reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/weights_set_row.dart';

import '../../../colors.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../screens/exercise/history/home_screen.dart';
import '../../../utils/one_rep_max_calculator.dart';
import '../../../utils/general_utils.dart';

const _logModeTimerMessage = "Tap + to add a timer";
const _editModeTimerMessage = "Timer will be available in log mode";

class ExerciseLogWidget extends StatefulWidget {
  final RoutineEditorMode editorType;

  final ExerciseLogDto exerciseLogDto;
  final ExerciseLogDto? superSet;

  /// ExerciseLogDto callbacks
  final VoidCallback onRemoveLog;
  final VoidCallback onReplaceLog;
  final VoidCallback onSuperSet;
  final void Function(String superSetId) onRemoveSuperSet;
  final VoidCallback? onCache;

  const ExerciseLogWidget(
      {super.key,
      this.editorType = RoutineEditorMode.edit,
      required this.exerciseLogDto,
      this.superSet,
      required this.onSuperSet,
      required this.onRemoveSuperSet,
      required this.onRemoveLog,
      this.onCache, required this.onReplaceLog});

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget> {
  final List<(TextEditingController, TextEditingController)> _controllers = [];
  final List<DateTime> _durationControllers = [];

  /// [MenuItemButton]
  List<Widget> _menuActionButtons() {
    return [
      widget.exerciseLogDto.superSetId.isNotEmpty
          ? MenuItemButton(
              onPressed: () => widget.onRemoveSuperSet(widget.exerciseLogDto.superSetId),
              child: Text("Remove Super-set", style: GoogleFonts.montserrat(color: Colors.red)),
            )
          : MenuItemButton(
              onPressed: widget.onSuperSet,
              child: Text("Super-set", style: GoogleFonts.montserrat()),
            ),
      MenuItemButton(
        onPressed: widget.onReplaceLog,
        child: Text(
          "Replace",
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
      ),
      MenuItemButton(
        onPressed: widget.onRemoveLog,
        child: Text(
          "Remove",
          style: GoogleFonts.montserrat(color: Colors.red),
        ),
      ),
    ];
  }

  void _show1RMRecommendations() {
    final pastExerciseLogs =
        Provider.of<RoutineLogController>(context, listen: false).exerciseLogsById[widget.exerciseLogDto.id] ?? [];
    final completedPastExerciseLogs = exerciseLogsWithCheckedSets(exerciseLogs: pastExerciseLogs);
    if (completedPastExerciseLogs.isNotEmpty) {
      final previousLog = completedPastExerciseLogs.last;
      final heaviestSetWeight = heaviestSetWeightForExerciseLog(exerciseLog: previousLog);
      final oneRepMax = average1RM(weight: heaviestSetWeight.weightValue(), reps: heaviestSetWeight.repsValue());
      displayBottomSheet(
          context: context,
          child: _OneRepMaxSlider(exercise: widget.exerciseLogDto.exercise.name, oneRepMax: oneRepMax));
    } else {
      showBottomSheetWithNoAction(context: context, title: widget.exerciseLogDto.exercise.name, description: "Keep logging to see recommendations.");
    }
  }

  void _updateProcedureNotes({required String value}) {
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateExerciseLogNotes(exerciseLogId: widget.exerciseLogDto.id, value: value);
    _cacheLog();
  }

  void _addSet() {
    if (withDurationOnly(type: widget.exerciseLogDto.exercise.type)) {
      _durationControllers.add(DateTime.now());
    } else {
      _controllers.add((TextEditingController(), TextEditingController()));
    }
    final pastSets = Provider.of<RoutineLogController>(context, listen: false)
        .whereSetsForExercise(exercise: widget.exerciseLogDto.exercise);
    Provider.of<ExerciseLogController>(context, listen: false)
        .addSet(exerciseLogId: widget.exerciseLogDto.id, pastSets: pastSets);
    _cacheLog();
  }

  void _removeSet({required int index}) {
    if (withDurationOnly(type: widget.exerciseLogDto.exercise.type)) {
      _durationControllers.removeAt(index);
    } else {
      _controllers.removeAt(index);
    }

    Provider.of<ExerciseLogController>(context, listen: false)
        .removeSetForExerciseLog(exerciseLogId: widget.exerciseLogDto.id, index: index);
    _cacheLog();
  }

  void _updateWeight({required int index, required double value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: value);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateWeight(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _updateReps({required int index, required num value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: value);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateReps(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _checkAndUpdateDuration(
      {required int index, required Duration duration, required SetDto setDto, required bool checked}) {
    if (setDto.checked) {
      final duration = setDto.durationValue();
      final startTime = DateTime.now().subtract(Duration(milliseconds: duration));
      _durationControllers[index] = startTime;
      _updateSetCheck(index: index, setDto: setDto);
    } else {
      final updatedSet = setDto.copyWith(value1: duration.inMilliseconds, checked: checked);
      Provider.of<ExerciseLogController>(context, listen: false)
          .updateDuration(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet, notify: checked);
      _cacheLog();
    }
  }

  void _updateDuration({required int index, required Duration duration, required SetDto setDto}) {
    SetDto updatedSet = setDto;
    if (setDto.checked) {
      updatedSet = setDto.copyWith(value1: duration.inMilliseconds);
    } else {
      updatedSet = setDto.copyWith(value1: duration.inMilliseconds, checked: true);
    }

    Provider.of<ExerciseLogController>(context, listen: false)
        .updateDuration(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet, notify: true);
    _cacheLog();
  }

  void _updateSetCheck({required int index, required SetDto setDto}) {
    final checked = !setDto.checked;
    final updatedSet = setDto.copyWith(checked: checked);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateSetCheck(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _loadTextEditingControllers() {
    final sets = widget.exerciseLogDto.sets;
    List<(TextEditingController, TextEditingController)> controllers = [];
    for (var set in sets) {
      final value1Controller = TextEditingController(text: set.weightValue().toString());
      final value2Controller = TextEditingController(text: set.repsValue().toString());
      controllers.add((value1Controller, value2Controller));
    }
    _controllers.addAll(controllers);
  }

  void _loadDurationControllers() {
    final sets = widget.exerciseLogDto.sets;
    List<DateTime> controllers = [];
    for (var set in sets) {
      final duration = set.durationValue();
      final startTime = DateTime.now().subtract(Duration(milliseconds: duration));
      controllers.add(startTime);
    }
    _durationControllers.addAll(controllers);
  }

  @override
  void initState() {
    super.initState();
    _loadTextEditingControllers();
    if(widget.editorType == RoutineEditorMode.log) {
      _loadDurationControllers();
    }
  }

  void _cacheLog() {
    final cacheLog = widget.onCache;
    if (cacheLog != null) {
      cacheLog();
    }
  }

  String _timerMessage() {
    if (widget.editorType == RoutineEditorMode.log) {
      return _logModeTimerMessage;
    } else {
      return _editModeTimerMessage;
    }
  }

  bool _canAddSets({required ExerciseType type}) {
    return withWeightsOnly(type: type) || withReps(type: type) || widget.editorType == RoutineEditorMode.log;
  }

  @override
  Widget build(BuildContext context) {

    final sets = widget.exerciseLogDto.sets;

    final superSetExerciseDto = widget.superSet;

    final exerciseType = widget.exerciseLogDto.exercise.type;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: sapphireDark80, // Set the background color
        borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomeScreen(exercise: widget.exerciseLogDto.exercise)));
                },
                child: Text(widget.exerciseLogDto.exercise.name,
                    style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              )),
              MenuAnchor(
                  style: MenuStyle(
                    backgroundColor: MaterialStateProperty.all(sapphireDark80),
                    surfaceTintColor: MaterialStateProperty.all(sapphireDark),
                  ),
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
                      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
                      tooltip: 'Show menu',
                    );
                  },
                  menuChildren: _menuActionButtons())
            ],
          ),
          if (superSetExerciseDto != null)
            Column(
              children: [
                Text("with ${superSetExerciseDto.exercise.name}",
                    style: GoogleFonts.montserrat(color: vibrantGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
              ],
            ),
          TextField(
            controller: TextEditingController(text: widget.exerciseLogDto.notes),
            onChanged: (value) => _updateProcedureNotes(value: value),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: sapphireLighter)),
              filled: true,
              fillColor: sapphireDark.withOpacity(0.4),
              hintText: "Enter notes",
              hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
            ),
            maxLines: null,
            cursorColor: Colors.white,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            style:
                GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 12),
          switch (exerciseType) {
            ExerciseType.weights => WeightRepsSetHeader(
                editorType: widget.editorType,
                firstLabel: weightLabel().toUpperCase(),
                secondLabel: 'REPS',
              ),
            ExerciseType.bodyWeight => RepsSetHeader(editorType: widget.editorType),
            ExerciseType.duration => DurationSetHeader(editorType: widget.editorType),
          },
          const SizedBox(height: 8),
          if (sets.isNotEmpty)
            _SetListView(
              exerciseType: exerciseType,
              sets: sets,
              editorType: widget.editorType,
              updateSetCheck: _updateSetCheck,
              removeSet: _removeSet,
              updateReps: _updateReps,
              updateWeight: _updateWeight,
              checkAndUpdateDuration: _checkAndUpdateDuration,
              controllers: _controllers,
              durationControllers: _durationControllers,
              updateDuration: _updateDuration,
            ),
          const SizedBox(height: 8),
          if (withDurationOnly(type: exerciseType) && sets.isEmpty)
            Center(
              child: Text(_timerMessage(),
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white70)),
            ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (withWeightsOnly(type: exerciseType))
              IconButton(
                  onPressed: _show1RMRecommendations,
                  icon: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.dumbbell, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text("WEIGHTS",
                          style:
                              GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                  style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      shape:
                          MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
            const Spacer(),
            if (_canAddSets(type: exerciseType))
              IconButton(
                  onPressed: _addSet,
                  icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
                  style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: MaterialStateProperty.all(sapphireDark.withOpacity(0.2)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))))
          ])
        ],
      ),
    );
  }
}

class _SetListView extends StatelessWidget {
  final ExerciseType exerciseType;
  final List<SetDto> sets;
  final RoutineEditorMode editorType;
  final List<(TextEditingController, TextEditingController)> controllers;
  final List<DateTime> durationControllers;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required num value, required SetDto setDto}) updateReps;
  final void Function({required int index, required double value, required SetDto setDto}) updateWeight;
  final void Function({required int index, required Duration duration, required SetDto setDto, required bool checked})
      checkAndUpdateDuration;
  final void Function({required int index, required Duration duration, required SetDto setDto}) updateDuration;

  const _SetListView(
      {required this.exerciseType,
      required this.sets,
      required this.editorType,
      required this.controllers,
      required this.durationControllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.updateReps,
      required this.updateWeight,
      required this.checkAndUpdateDuration,
      required this.updateDuration});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      final setWidget = switch (exerciseType) {
        ExerciseType.weights => WeightsSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onChangedReps: (num value) => updateReps(index: index, value: value, setDto: setDto),
            onChangedWeight: (double value) => updateWeight(index: index, value: value, setDto: setDto),
            controllers: controllers[index],
          ),
        ExerciseType.bodyWeight => RepsSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onChangedReps: (num value) => updateReps(index: index, value: value, setDto: setDto),
            controllers: controllers[index],
          ),
        ExerciseType.duration => DurationSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onCheckAndUpdateDuration: (Duration duration, {bool? checked}) =>
                checkAndUpdateDuration(index: index, duration: duration, setDto: setDto, checked: checked ?? false),
            startTime: durationControllers.isNotEmpty ? durationControllers[index] : DateTime.now(),
            onupdateDuration: (Duration duration) => updateDuration(index: index, duration: duration, setDto: setDto),
          ),
      };

      return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: setWidget);
    }).toList();

    return Column(children: children);
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
        Text(widget.exercise,
            style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            text: "Based on your recent progress, consider",
            style:
                GoogleFonts.montserrat(height: 1.5, color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
            children: [
              TextSpan(
                text: "\n",
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: "$_weight${weightLabel()}",
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
              ),
              TextSpan(
                text: " ",
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: "for",
                style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 18),
              ),
              TextSpan(
                text: " ",
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: "${_reps.toInt()} ${pluralize(word: "rep", count: _reps.toInt())}",
                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
              )
            ],
          ),
        ),
        Slider(value: _reps, onChanged: onChanged, min: 1, max: 20, divisions: 20, thumbColor: vibrantGreen),
      ],
    );
  }

  void onChanged(double value) {
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
