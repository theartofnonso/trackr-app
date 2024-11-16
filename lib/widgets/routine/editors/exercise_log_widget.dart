import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/pickers/exercise_equipment_picker.dart';
import 'package:tracker_app/widgets/pickers/exercise_metric_picker.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/weight_reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/weights_set_row.dart';

import '../../../colors.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../screens/exercise/history/exercise_home_screen.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/one_rep_max_calculator.dart';
import '../../pickers/exercise_modality_picker.dart';

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
  final void Function(ExerciseLogDto exerciseLogDto) onUpdate;

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
      required this.isMinimised,
      required this.onUpdate});

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget> {
  final List<(TextEditingController, TextEditingController)> _controllers = [];
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
            .exerciseLogsByName[widget.exerciseLogDto.exercise.name] ??
        [];
    final completedPastExerciseLogs = completedExercises(exerciseLogs: pastExerciseLogs);
    if (completedPastExerciseLogs.isNotEmpty) {
      final previousLog = completedPastExerciseLogs.last;
      final heaviestSetWeight = heaviestSetWeightForExerciseLog(exerciseLog: previousLog);
      final oneRepMax = average1RM(weight: heaviestSetWeight.weight(), reps: heaviestSetWeight.reps());
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
        .updateExerciseLogNotes(exerciseName: widget.exerciseLogDto.exercise.name, value: value);
    _cacheLog();
  }

  void _addSet() {
    if (withDurationOnly(type: widget.exerciseLogDto.exercise.metric)) {
      _durationControllers.add(DateTime.now());
    } else {
      _controllers.add((TextEditingController(), TextEditingController()));
    }
    final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .whereSetsForExercise(exercise: widget.exerciseLogDto.exercise);
    Provider.of<ExerciseLogController>(context, listen: false)
        .addSet(exerciseName: widget.exerciseLogDto.exercise.name, pastSets: pastSets);
    _cacheLog();
  }

  void _removeSet({required int index}) {
    if (withDurationOnly(type: widget.exerciseLogDto.exercise.metric)) {
      _durationControllers.removeAt(index);
    } else {
      _controllers.removeAt(index);
    }

    Provider.of<ExerciseLogController>(context, listen: false)
        .removeSetForExerciseLog(exerciseName: widget.exerciseLogDto.exercise.name, index: index);
    _cacheLog();
  }

  void _updateWeight({required int index, required double value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: value);
    widget.onTapWeightEditor(updatedSet);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateWeight(exerciseName: widget.exerciseLogDto.exercise.name, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _updateReps({required int index, required num value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: value);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateReps(exerciseName: widget.exerciseLogDto.exercise.name, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _checkAndUpdateDuration(
      {required int index, required Duration duration, required SetDto setDto, required bool checked}) {
    if (setDto.checked) {
      final duration = setDto.duration();
      final startTime = DateTime.now().subtract(Duration(milliseconds: duration));
      _durationControllers[index] = startTime;
      _updateSetCheck(index: index, setDto: setDto);
    } else {
      final updatedSet = setDto.copyWith(value1: duration.inMilliseconds, checked: checked);
      Provider.of<ExerciseLogController>(context, listen: false).updateDuration(
          exerciseName: widget.exerciseLogDto.exercise.name, index: index, setDto: updatedSet, notify: checked);
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

    Provider.of<ExerciseLogController>(context, listen: false).updateDuration(
        exerciseName: widget.exerciseLogDto.exercise.name, index: index, setDto: updatedSet, notify: true);
    _cacheLog();
  }

  void _updateSetCheck({required int index, required SetDto setDto}) {
    final checked = !setDto.checked;
    final updatedSet = setDto.copyWith(checked: checked);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateSetCheck(exerciseName: widget.exerciseLogDto.exercise.name, index: index, setDto: updatedSet);
    _cacheLog();
  }

  void _loadTextEditingControllers() {
    final sets = widget.exerciseLogDto.sets;
    List<(TextEditingController, TextEditingController)> controllers = [];
    for (var set in sets) {
      final value1Controller = TextEditingController(text: set.weight().toString());
      final value2Controller = TextEditingController(text: set.reps().toString());
      controllers.add((value1Controller, value2Controller));
    }
    _controllers.addAll(controllers);
  }

  void _loadDurationControllers() {
    final sets = widget.exerciseLogDto.sets;
    List<DateTime> controllers = [];
    for (var set in sets) {
      final duration = set.duration();
      final startTime = DateTime.now().subtract(Duration(milliseconds: duration));
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
    _loadTextEditingControllers();
    if (widget.editorType == RoutineEditorMode.log) {
      _loadDurationControllers();
    }
  }

  void _cacheLog() {
    final cacheLog = widget.onCache;
    if (cacheLog != null) {
      cacheLog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sets = widget.exerciseLogDto.sets;

    final superSetExerciseDto = widget.superSet;

    final exerciseType = widget.exerciseLogDto.exercise.metric;

    print(exerciseType);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: sapphireDark80, // Set the background color
        borderRadius: BorderRadius.circular(5), // Set the border radius to make it rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        OpacityButtonWidget(
                          label: widget.exerciseLogDto.exercise.equipment.name.toUpperCase(),
                          buttonColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          textStyle:
                              GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                          onPressed: _showExerciseEquipmentPicker,
                        ),
                        const SizedBox(width: 6),
                        OpacityButtonWidget(
                          label: widget.exerciseLogDto.exercise.modality.name.toUpperCase(),
                          buttonColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          textStyle:
                              GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
                          onPressed: _showExerciseModalityPicker,
                        ),
                        const SizedBox(width: 6),
                        OpacityButtonWidget(
                          label: widget.exerciseLogDto.exercise.metric.name.toUpperCase(),
                          buttonColor: vibrantBlue,
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: vibrantBlue),
                          onPressed: _showExerciseMetricPicker,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 12),
          switch (exerciseType) {
            ExerciseMetric.weights => WeightRepsSetHeader(
                editorType: widget.editorType,
                firstLabel: weightLabel().toUpperCase(),
                secondLabel: 'REPS',
              ),
            ExerciseMetric.reps => RepsSetHeader(editorType: widget.editorType),
            ExerciseMetric.duration => DurationSetHeader(editorType: widget.editorType),
            // TODO: Handle this case.
            ExerciseMetric.none => throw UnimplementedError(),
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
              onTapWeightEditor: _onTapWeightEditor,
              onTapRepsEditor: _onTapRepsEditor,
            ),
          const SizedBox(height: 8),
          if (withDurationOnly(type: exerciseType) && sets.isEmpty)
            Center(
              child: Text("Tap + to add a timer",
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white70)),
            ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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

  void _showExerciseEquipmentPicker() {
    displayBottomSheet(
        height: 216,
        context: context,
        child: ExerciseEquipmentPicker(
            initialEquipment: widget.exerciseLogDto.exercise.equipment,
            onSelect: (newEquipment) {
              Navigator.of(context).pop();
              final updatedExercise = widget.exerciseLogDto.exercise.copyWith(equipment: newEquipment);
              final updatedExerciseLog = widget.exerciseLogDto.copyWith(exercise: updatedExercise);
              widget.onUpdate(updatedExerciseLog);
            }));
  }

  void _showExerciseModalityPicker() {
    displayBottomSheet(
        height: 216,
        context: context,
        child: ExerciseModalityPicker(
            initialModality: widget.exerciseLogDto.exercise.modality,
            onSelect: (newMode) {
              Navigator.of(context).pop();
              final updatedExercise = widget.exerciseLogDto.exercise.copyWith(modality: newMode);
              final updatedExerciseLog = widget.exerciseLogDto.copyWith(exercise: updatedExercise);
              widget.onUpdate(updatedExerciseLog);
            }));
  }

  void _showExerciseMetricPicker() {
    displayBottomSheet(
        height: 216,
        context: context,
        child: ExerciseMetricPicker(
            initialMetric: widget.exerciseLogDto.exercise.metric,
            onSelect: (newMetric) {
              Navigator.of(context).pop();
              final updatedExercise = widget.exerciseLogDto.exercise.copyWith(metric: newMetric);
              final updatedExerciseLog = widget.exerciseLogDto.copyWith(exercise: updatedExercise);
              widget.onUpdate(updatedExerciseLog);
            }));
  }
}

class _SetListView extends StatelessWidget {
  final ExerciseMetric exerciseType;
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
  final void Function({required SetDto setDto}) onTapWeightEditor;
  final void Function({required SetDto setDto}) onTapRepsEditor;

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
      required this.updateDuration,
      required this.onTapWeightEditor,
      required this.onTapRepsEditor});

  @override
  Widget build(BuildContext context) {
    final children = sets.mapIndexed((index, setDto) {
      final setWidget = switch (exerciseType) {
        ExerciseMetric.weights => WeightsSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onChangedReps: (num value) => updateReps(index: index, value: value, setDto: setDto),
            onChangedWeight: (double value) => updateWeight(index: index, value: value, setDto: setDto),
            onTapWeightEditor: () => onTapWeightEditor(setDto: setDto),
            onTapRepsEditor: () => onTapRepsEditor(setDto: setDto),
            controllers: controllers[index],
          ),
        ExerciseMetric.reps => RepsSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onChangedReps: (num value) => updateReps(index: index, value: value, setDto: setDto),
            onTapRepsEditor: () => onTapRepsEditor(setDto: setDto),
            controllers: controllers[index],
          ),
        ExerciseMetric.duration => DurationSetRow(
            setDto: setDto,
            editorType: editorType,
            onCheck: () => updateSetCheck(index: index, setDto: setDto),
            onRemoved: () => removeSet(index: index),
            onCheckAndUpdateDuration: (Duration duration, {bool? checked}) =>
                checkAndUpdateDuration(index: index, duration: duration, setDto: setDto, checked: checked ?? false),
            startTime: durationControllers.isNotEmpty ? durationControllers[index] : DateTime.now(),
            onupdateDuration: (Duration duration) => updateDuration(index: index, duration: duration, setDto: setDto),
          ),
        // TODO: Handle this case.
        ExerciseMetric.none => throw UnimplementedError(),
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
