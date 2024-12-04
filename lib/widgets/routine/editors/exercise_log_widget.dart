import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
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
  final VoidCallback? onCache;
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
      this.onCache,
      required this.onReplaceLog,
      required this.onResize,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor,
      required this.isMinimised});

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget> {
  final List<(TextEditingController, TextEditingController)> _weightAndRepsControllers = [];
  final List<TextEditingController> _repsControllers = [];
  final List<DateTime> _durationControllers = [];

  /// [MenuItemButton]
  List<Widget> _menuActionButtons() {
    return [
      MenuItemButton(
        onPressed: widget.onReplaceLog,
        child: Text(
          "Replace",
          style: GoogleFonts.ubuntu(color: Colors.white),
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
    ];
  }

  void _show1RMRecommendations() {
    final pastExerciseLogs = Provider.of<ExerciseAndRoutineController>(context, listen: false)
            .exerciseLogsByExerciseId[widget.exerciseLogDto.id] ??
        [];
    final completedPastExerciseLogs = completedExercises(exerciseLogs: pastExerciseLogs);
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

  void _updateProcedureNotes({required String value}) {
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateExerciseLogNotes(exerciseLogId: widget.exerciseLogDto.id, value: value);
    _cacheLog();
  }

  void _addSet() {
    if (withDurationOnly(type: widget.exerciseLogDto.exercise.type)) {
      _durationControllers.add(DateTime.now());
    } else {
      if (withWeightsOnly(type: widget.exerciseLogDto.exercise.type)) {
        _weightAndRepsControllers.add((TextEditingController(), TextEditingController()));
      } else {
        _repsControllers.add(TextEditingController());
      }
    }
    final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exercise: widget.exerciseLogDto.exercise);
    Provider.of<ExerciseLogController>(context, listen: false)
        .addSet(exerciseLogId: widget.exerciseLogDto.id, pastSets: pastSets);
    _cacheLog();
  }

  void _removeSet({required int index}) {
    if (withDurationOnly(type: widget.exerciseLogDto.exercise.type)) {
      _durationControllers.removeAt(index);
    } else {
      if (withWeightsOnly(type: widget.exerciseLogDto.exercise.type)) {
        _weightAndRepsControllers.removeAt(index);
      } else {
        _repsControllers.removeAt(index);
      }
    }

    Provider.of<ExerciseLogController>(context, listen: false)
        .removeSetForExerciseLog(exerciseLogId: widget.exerciseLogDto.id, index: index);
    _cacheLog();
  }

  void _updateWeight({required int index, required double weight, required SetDto setDto}) {
    final updatedSet = (setDto as WeightAndRepsSetDto).copyWith(weight: weight);
    widget.onTapWeightEditor(updatedSet);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateWeight(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _updateReps({required int index, required int reps, required SetDto setDto}) {
    final updatedSet =
        setDto is WeightAndRepsSetDto ? setDto.copyWith(reps: reps) : (setDto as RepsSetDto).copyWith(reps: reps);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateReps(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet);
    _cacheLog();
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
      _cacheLog();
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
    _cacheLog();
  }

  void _updateSetCheck({required int index, required SetDto setDto}) {
    final checked = !setDto.checked;
    final updatedSet = setDto.copyWith(checked: checked);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateSetCheck(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _loadWeightAndRepsControllers() {
    final sets = widget.exerciseLogDto.sets;
    List<(TextEditingController, TextEditingController)> controllers = [];
    for (final set in sets) {
      final weightController = TextEditingController(text: (set as WeightAndRepsSetDto).weight.toString());
      final repsController = TextEditingController(text: set.reps.toString());
      controllers.add((weightController, repsController));
    }
    _weightAndRepsControllers.addAll(controllers);
  }

  void _loadRepsControllers() {
    final sets = widget.exerciseLogDto.sets;
    List<TextEditingController> controllers = [];
    for (var set in sets) {
      final repsController = TextEditingController(text: (set as RepsSetDto).reps.toString());
      _repsControllers.add((repsController));
    }
    _repsControllers.addAll(controllers);
  }

  void _loadDurationControllers() {
    final sets = widget.exerciseLogDto.sets;
    List<DateTime> controllers = [];
    for (var set in sets) {
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

  @override
  void initState() {
    super.initState();
    if (widget.exerciseLogDto.exercise.type == ExerciseType.weights) {
      _loadWeightAndRepsControllers();
    } else if (widget.exerciseLogDto.exercise.type == ExerciseType.bodyWeight) {
      _loadRepsControllers();
    } else {
      _loadDurationControllers();
    }
  }

  void _cacheLog() {
    final cacheLog = widget.onCache;
    if (cacheLog != null) {
      cacheLog();
    }
  }

  void _stt() async {
    navigateWithSlideTransition(context: context, child: STTLogging(exerciseLog: widget.exerciseLogDto));
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
                        style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    if (superSetExerciseDto != null)
                      Column(
                        children: [
                          Text("with ${superSetExerciseDto.exercise.name}",
                              style:
                                  GoogleFonts.ubuntu(color: vibrantGreen, fontWeight: FontWeight.w500, fontSize: 12)),
                          const SizedBox(height: 10)
                        ],
                      ),
                  ],
                ),
              )),
              MenuAnchor(
                  style: MenuStyle(
                    backgroundColor: WidgetStateProperty.all(sapphireDark80),
                    surfaceTintColor: WidgetStateProperty.all(sapphireDark),
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
              hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14),
            ),
            maxLines: null,
            cursorColor: Colors.white,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 12),
          switch (exerciseType) {
            ExerciseType.weights => WeightAndRepsSetHeader(
                editorType: widget.editorType,
                firstLabel: weightLabel().toUpperCase(),
                secondLabel: 'REPS',
              ),
            ExerciseType.bodyWeight => RepsSetHeader(editorType: widget.editorType),
            ExerciseType.duration => DurationSetHeader(editorType: widget.editorType)
          },
          const SizedBox(height: 8),
          if (sets.isNotEmpty)
            switch (exerciseType) {
              ExerciseType.weights => _WeightAndRepsSetListView(
                  sets: sets.map((set) => set as WeightAndRepsSetDto).toList(),
                  editorType: widget.editorType,
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
                  editorType: widget.editorType,
                  updateSetCheck: _updateSetCheck,
                  removeSet: _removeSet,
                  updateReps: _updateReps,
                  controllers: _repsControllers,
                  onTapWeightEditor: _onTapWeightEditor,
                  onTapRepsEditor: _onTapRepsEditor,
                ),
              ExerciseType.duration => _DurationSetListView(
                  sets: sets.map((set) => set as DurationSetDto).toList(),
                  editorType: widget.editorType,
                  updateSetCheck: _updateSetCheck,
                  removeSet: _removeSet,
                  controllers: _durationControllers,
                  onTapWeightEditor: _onTapWeightEditor,
                  onTapRepsEditor: _onTapRepsEditor,
                  checkAndUpdateDuration: _checkAndUpdateDuration,
                  updateDuration: _updateDuration,
                ),
            },
          const SizedBox(height: 8),
          if (withDurationOnly(type: exerciseType) && sets.isEmpty)
            Center(
              child: Text("Tap + to add a timer",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white70)),
            ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (withReps(type: exerciseType))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(onTap: () => _stt(), child: TRKRCoachWidget()),
                  const SizedBox(width: 6),
                ],
              ),
            if (withWeightsOnly(type: exerciseType))
              IconButton(
                  onPressed: _show1RMRecommendations,
                  icon: const FaIcon(FontAwesomeIcons.solidLightbulb, color: Colors.white, size: 16),
                  style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
            const Spacer(),
            IconButton(
              onPressed: widget.onResize,
              icon: const Icon(Icons.close_fullscreen_rounded, color: Colors.white),
              tooltip: 'Maximise card',
            ),
            const SizedBox(
              width: 6,
            ),
            IconButton(
                onPressed: _addSet,
                icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
                style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: WidgetStateProperty.all(sapphireDark.withOpacity(0.2)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
          ])
        ],
      ),
    );
  }
}

class _WeightAndRepsSetListView extends StatelessWidget {
  final List<WeightAndRepsSetDto> sets;
  final RoutineEditorMode editorType;
  final List<(TextEditingController, TextEditingController)> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index, required int reps, required SetDto setDto}) updateReps;
  final void Function({required int index, required double weight, required SetDto setDto}) updateWeight;
  final void Function({required SetDto setDto}) onTapWeightEditor;
  final void Function({required SetDto setDto}) onTapRepsEditor;

  const _WeightAndRepsSetListView(
      {required this.sets,
      required this.editorType,
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
      return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: WeightsAndRepsSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onChangedReps: (int value) => updateReps(index: index, reps: value, setDto: setDto),
            onChangedWeight: (double value) => updateWeight(index: index, weight: value, setDto: setDto),
            onTapWeightEditor: () => onTapWeightEditor(setDto: setDto),
            onTapRepsEditor: () => onTapRepsEditor(setDto: setDto),
            controllers: controllers[index],
          ));
    }).toList();

    return Column(children: children);
  }
}

class _RepsSetListView extends StatelessWidget {
  final List<RepsSetDto> sets;
  final RoutineEditorMode editorType;
  final List<TextEditingController> controllers;
  final void Function({required int index}) removeSet;
  final void Function({required int index, required SetDto setDto}) updateSetCheck;
  final void Function({required int index, required int reps, required SetDto setDto}) updateReps;
  final void Function({required SetDto setDto}) onTapWeightEditor;
  final void Function({required SetDto setDto}) onTapRepsEditor;

  const _RepsSetListView(
      {required this.sets,
      required this.editorType,
      required this.controllers,
      required this.updateSetCheck,
      required this.removeSet,
      required this.updateReps,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RepsSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onChangedReps: (int value) => updateReps(index: index, reps: value, setDto: setDto),
            onTapRepsEditor: () => onTapRepsEditor(setDto: setDto),
            controller: controllers[index],
          ));
    }).toList();

    return Column(children: children);
  }
}

class _DurationSetListView extends StatelessWidget {
  final List<DurationSetDto> sets;
  final RoutineEditorMode editorType;
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
      required this.editorType,
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
      return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: DurationSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onCheckAndUpdateDuration: (Duration duration, {bool? checked}) =>
                checkAndUpdateDuration(index: index, duration: duration, setDto: setDto, checked: checked ?? false),
            startTime: controllers.isNotEmpty ? controllers[index] : DateTime.now(),
            onupdateDuration: (Duration duration) => updateDuration(index: index, duration: duration, setDto: setDto),
          ));
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
            style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            text: "Based on your recent progress, consider",
            style: GoogleFonts.ubuntu(height: 1.5, color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
            children: [
              TextSpan(
                text: "\n",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: "$_weight${weightLabel()}",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
              ),
              TextSpan(
                text: " ",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: "for",
                style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 18),
              ),
              TextSpan(
                text: " ",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              TextSpan(
                text: "${_reps.toInt()} ${pluralize(word: "rep", count: _reps.toInt())}",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
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
