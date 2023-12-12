import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/providers/exercise_log_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/duration_distance_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/weight_distance_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_headers/weight_reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/duration_distance_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/weight_distance_set_row.dart';
import 'package:tracker_app/widgets/routine/editors/set_rows/weight_reps_set_row.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums/routine_editor_type_enums.dart';
import '../../../screens/exercise/history/home_screen.dart';
import '../../../utils/general_utils.dart';

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
      required this.superSet,
      required this.onSuperSet,
      required this.onRemoveSuperSet,
      required this.onRemoveLog, this.onCache});

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget> {
  final List<(TextEditingController, TextEditingController)> _controllers = [];
  List<SetDto> _pastSets = [];

  /// [MenuItemButton]
  List<Widget> _menuActionButtons() {
    return [
      widget.exerciseLogDto.superSetId.isNotEmpty
          ? MenuItemButton(
              onPressed: () => widget.onRemoveSuperSet(widget.exerciseLogDto.superSetId),
              child: Text("Remove Super-set", style: GoogleFonts.lato(color: Colors.red)),
            )
          : MenuItemButton(
              onPressed: widget.onSuperSet,
              child: const Text("Super-set"),
            ),
      MenuItemButton(
        onPressed: widget.onRemoveLog,
        child: Text(
          "Remove",
          style: GoogleFonts.lato(color: Colors.red),
        ),
      )
    ];
  }

  SetDto? _wherePastSetOrNull({required String id}) {
    return _pastSets.firstWhereOrNull((pastSet) => pastSet.id == id);
  }

  List<Widget> _displaySets({required ExerciseType exerciseType, required List<SetDto> sets}) {
    return sets.mapIndexed((index, setDto) {
      Widget setWidget = _createSetWidget(index: index, set: setDto, exerciseType: exerciseType);

      return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: setWidget);
    }).toList();
  }

  Widget _createSetWidget({required int index, required SetDto set, required ExerciseType exerciseType}) {
    SetDto? pastSet = _wherePastSetOrNull(id: set.id);
    switch (exerciseType) {
      case ExerciseType.weightAndReps:
      case ExerciseType.weightedBodyWeight:
      case ExerciseType.assistedBodyWeight:
        return WeightRepsSetRow(
          setDto: set,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(setIndex: index, setDto: set),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) => _updateSetType(index: index, type: type, setDto: set),
          onChangedReps: (num value) => _updateReps(setIndex: index, value: value, setDto: set),
          onChangedWeight: (double value) => _updateWeight(setIndex: index, value: value, setDto: set),
          controllers: _controllers[index],
        );
      case ExerciseType.bodyWeightAndReps:
        return RepsSetRow(
          setDto: set,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(setIndex: index, setDto: set),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) => _updateSetType(index: index, type: type, setDto: set),
          onChangedReps: (num value) => _updateReps(setIndex: index, value: value, setDto: set),
          controllers: _controllers[index],
        );
      case ExerciseType.weightAndDistance:
        return WeightDistanceSetRow(
          setDto: set,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(setIndex: index, setDto: set),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) => _updateSetType(index: index, type: type, setDto: set),
          onChangedDistance: (double value) => _updateDistance(setIndex: index, distance: value, setDto: set),
          onChangedWeight: (double value) => _updateWeight(setIndex: index, value: value, setDto: set),
          controllers: _controllers[index],
        );
      case ExerciseType.duration:
        return DurationSetRow(
          setDto: set,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(setIndex: index, setDto: set),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) => _updateSetType(index: index, type: type, setDto: set),
          onChangedDuration: (Duration duration) => _updateDuration(setIndex: index, duration: duration, setDto: set),
        );
      case ExerciseType.durationAndDistance:
        return DurationDistanceSetRow(
          setDto: set,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(setIndex: index, setDto: set),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) => _updateSetType(index: index, type: type, setDto: set),
          onChangedDuration: (Duration duration) => _updateDuration(setIndex: index, duration: duration, setDto: set),
          onChangedDistance: (double distance) => _updateDistance(setIndex: index, distance: distance, setDto: set),
          controllers: _controllers[index],
        );
    }
  }

  void _updateProcedureNotes({required String value}) {
    Provider.of<ExerciseLogProvider>(context, listen: false)
        .updateExerciseLogNotes(exerciseLogId: widget.exerciseLogDto.id, value: value);
    _cacheLog();
  }

  void _addSet() {
    _controllers.add((TextEditingController(), TextEditingController()));
    Provider.of<ExerciseLogProvider>(context, listen: false)
        .addSet(exerciseLogId: widget.exerciseLogDto.id, pastSets: _pastSets);
    _cacheLog();
  }

  void _removeSet(int index) {
    _controllers.removeAt(index);
    Provider.of<ExerciseLogProvider>(context, listen: false)
        .removeSetForExerciseLog(exerciseLogId: widget.exerciseLogDto.id, setIndex: index);
    _cacheLog();
  }

  void _updateWeight({required int setIndex, required double value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: value);
    Provider.of<ExerciseLogProvider>(context, listen: false)
        .updateWeight(exerciseLogId: widget.exerciseLogDto.id, setIndex: setIndex, setDto: updatedSet);
    _cacheLog();
  }

  void _updateReps({required int setIndex, required num value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: value);
    Provider.of<ExerciseLogProvider>(context, listen: false)
        .updateReps(exerciseLogId: widget.exerciseLogDto.id, setIndex: setIndex, setDto: updatedSet);
    _cacheLog();
  }

  void _updateDuration({required int setIndex, required Duration duration, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: duration.inMilliseconds);
    Provider.of<ExerciseLogProvider>(context, listen: false)
        .updateDuration(exerciseLogId: widget.exerciseLogDto.id, setIndex: setIndex, setDto: updatedSet);
    _cacheLog();
  }

  void _updateDistance({required int setIndex, required double distance, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: distance);
    Provider.of<ExerciseLogProvider>(context, listen: false)
        .updateDistance(exerciseLogId: widget.exerciseLogDto.id, setIndex: setIndex, setDto: updatedSet);
    _cacheLog();
  }

  void _updateSetType({required int index, required SetType type, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(type: type);
    Provider.of<ExerciseLogProvider>(context, listen: false).updateSetType(exerciseLogId: widget.exerciseLogDto.id, setIndex: index, setDto: updatedSet, pastSets: _pastSets);
    _cacheLog();
  }

  void _updateSetCheck({required int setIndex, required SetDto setDto}) {
    final checked = setDto.checked;
    final updatedSet = setDto.copyWith(checked: !checked);
    Provider.of<ExerciseLogProvider>(context, listen: false)
        .updateSetCheck(exerciseLogId: widget.exerciseLogDto.id, setIndex: setIndex, setDto: updatedSet);
    _cacheLog();
  }

  void _loadTextEditingControllers() {
    List<(TextEditingController, TextEditingController)> controllers = [];
    for (var set in widget.exerciseLogDto.sets) {
      final value1Controller = TextEditingController(text: set.value1.toString());
      final value2Controller = TextEditingController(text: set.value2.toString());
      controllers.add((value1Controller, value2Controller));
    }
    _controllers.addAll(controllers);
  }

  @override
  void initState() {
    super.initState();

    _pastSets =
        Provider.of<RoutineLogProvider>(context, listen: false).wherePastSets(exercise: widget.exerciseLogDto.exercise);

    _loadTextEditingControllers();

  }

  void _cacheLog() {
    final cacheLog = widget.onCache;
    if(cacheLog != null) {
      cacheLog();
    }
  }

  @override
  Widget build(BuildContext context) {

    final sets = context.select((ExerciseLogProvider provider) => provider.sets)[widget.exerciseLogDto.id] ?? [];

    final superSetExerciseDto = widget.superSet;

    final exerciseString = widget.exerciseLogDto.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseString);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tealBlueLight, // Set the background color
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
                    style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              )),
              MenuAnchor(
                  style: MenuStyle(
                    backgroundColor: MaterialStateProperty.all(tealBlueLighter),
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
                    style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 10),
              ],
            ),
          TextField(
            controller: TextEditingController(text: widget.exerciseLogDto.notes),
            onChanged: (value) => _updateProcedureNotes(value: value),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: tealBlueLighter)),
              filled: true,
              fillColor: tealBlueLighter,
              hintText: "Enter notes",
              hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14),
            ),
            maxLines: null,
            cursorColor: Colors.white,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.lato(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 12),
          switch (exerciseType) {
            ExerciseType.weightAndReps => WeightRepsSetHeader(
                editorType: widget.editorType,
                firstLabel: weightLabel().toUpperCase(),
                secondLabel: 'REPS',
              ),
            ExerciseType.weightedBodyWeight => WeightRepsSetHeader(
                editorType: widget.editorType,
                firstLabel: "+${weightLabel().toUpperCase()}",
                secondLabel: 'REPS',
              ),
            ExerciseType.assistedBodyWeight => WeightRepsSetHeader(
                editorType: widget.editorType,
                firstLabel: '-${weightLabel().toUpperCase()}',
                secondLabel: 'REPS',
              ),
            ExerciseType.weightAndDistance => WeightDistanceSetHeader(editorType: widget.editorType),
            ExerciseType.bodyWeightAndReps => RepsSetHeader(editorType: widget.editorType),
            ExerciseType.duration => DurationSetHeader(editorType: widget.editorType),
            ExerciseType.durationAndDistance => DurationDistanceSetHeader(editorType: widget.editorType),
          },
          const SizedBox(height: 8),
          if (sets.isNotEmpty) Column(children: [..._displaySets(exerciseType: exerciseType, sets: sets)]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
                onPressed: _addSet,
                icon: const Icon(Icons.add, color: Colors.white70),
                style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: MaterialStateProperty.all(tealBlueLighter),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))))),
          )
        ],
      ),
    );
  }
}
