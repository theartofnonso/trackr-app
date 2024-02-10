import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
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
import '../../../utils/general_utils.dart';

const _logModeTimerMessage = "Tap + to add a timer";
const _editModeTimerMessage = "Timer will be available in log mode";

class ExerciseLogWidget extends StatefulWidget {
  final RoutineEditorMode editorType;

  final ExerciseLogDto exerciseLogDto;
  final ExerciseLogDto? superSet;

  /// ExerciseLogDto callbacks
  final VoidCallback onRemoveLog;
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
      this.onCache});

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
        onPressed: widget.onRemoveLog,
        child: Text(
          "Remove",
          style: GoogleFonts.montserrat(color: Colors.red),
        ),
      )
    ];
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

  void _updateDuration({required int index, required Duration duration, required SetDto setDto, required bool notify}) {
    final updatedSet = setDto.copyWith(value1: duration.inMilliseconds, checked: notify);
    Provider.of<ExerciseLogController>(context, listen: false)
        .updateDuration(exerciseLogId: widget.exerciseLogDto.id, index: index, setDto: updatedSet, notify: notify);
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
    final sets = Provider.of<ExerciseLogController>(context, listen: false).sets[widget.exerciseLogDto.id] ?? [];
    List<(TextEditingController, TextEditingController)> controllers = [];
    for (var set in sets) {
      final value1Controller = TextEditingController(text: set.value1.toString());
      final value2Controller = TextEditingController(text: set.value2.toString());
      controllers.add((value1Controller, value2Controller));
    }
    _controllers.addAll(controllers);
  }

  void _loadDurationControllers() {
    final sets = Provider.of<ExerciseLogController>(context, listen: false).sets[widget.exerciseLogDto.id] ?? [];
    List<DateTime> controllers = [];
    for (var _ in sets) {
      controllers.add(DateTime.now());
    }
    _durationControllers.addAll(controllers);
  }

  @override
  void initState() {
    super.initState();
    _loadTextEditingControllers();
    _loadDurationControllers();
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

    final sets = Provider.of<ExerciseLogController>(context, listen: true).sets[widget.exerciseLogDto.id] ?? [];

    final superSetExerciseDto = widget.superSet;

    final exerciseType = widget.exerciseLogDto.exercise.type;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: sapphireLight, // Set the background color
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
                    backgroundColor: MaterialStateProperty.all(sapphireLighter),
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
                    style: GoogleFonts.montserrat(color: vibrantBlue, fontWeight: FontWeight.bold, fontSize: 12)),
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
                fillColor: sapphireLighter,
                hintText: "Enter notes",
                hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 14),
              ),
              maxLines: null,
              cursorColor: Colors.white,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
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
              updateDuration: _updateDuration,
              controllers: _controllers,
              durationControllers: _durationControllers,
            ),
          const SizedBox(height: 8),
          if (withDurationOnly(type: exerciseType) && sets.isEmpty)
            Center(
              child: Text(_timerMessage(),
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white70)),
            ),
          const SizedBox(height: 8),
          /// Do not remove this condition
          if (_canAddSets(type: exerciseType))
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                  onPressed: _addSet,
                  icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
                  style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: MaterialStateProperty.all(sapphireLighter),
                      shape:
                          MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
            )
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
  final void Function({required int index, required Duration duration, required SetDto setDto, required bool notify})
      updateDuration;

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
            onChangedDuration: (Duration duration, bool notify) =>
                updateDuration(index: index, duration: duration, setDto: setDto, notify: notify),
            startTime: durationControllers.isNotEmpty ? durationControllers[index] : DateTime.now(),
          ),
      };

      return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: setWidget);
    }).toList();

    return Column(children: children);
  }
}
