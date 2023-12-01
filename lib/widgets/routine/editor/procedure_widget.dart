import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/providers/procedures_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/duration_distance_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/weight_distance_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/weight_reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/duration_distance_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/weight_distance_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/weight_reps_set_row.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
import '../../../screens/exercise/history/home_screen.dart';
import '../../../screens/editors/routine_editor_screen.dart';
import '../../../utils/general_utils.dart';

class ProcedureWidget extends StatefulWidget {
  final RoutineEditorMode editorType;

  final ProcedureDto procedureDto;
  final ProcedureDto? otherSuperSetProcedureDto;

  /// Procedure callbacks
  final VoidCallback onRemoveProcedure;
  final VoidCallback onSuperSet;
  final void Function(String superSetId) onRemoveSuperSet;
  final VoidCallback onReOrderProcedures;

  final VoidCallback onCache;

  const ProcedureWidget({
    super.key,
    this.editorType = RoutineEditorMode.edit,
    required this.procedureDto,
    required this.otherSuperSetProcedureDto,
    required this.onSuperSet,
    required this.onRemoveSuperSet,
    required this.onRemoveProcedure,
    required this.onReOrderProcedures,
    required this.onCache,
  });

  @override
  State<ProcedureWidget> createState() => _ProcedureWidgetState();
}

class _ProcedureWidgetState extends State<ProcedureWidget> {
  final List<(TextEditingController, TextEditingController)> _controllers = [];
  final List<SetDto> _pastSets = [];

  /// [MenuItemButton]
  List<Widget> _menuActionButtons() {
    return [
      MenuItemButton(
        onPressed: widget.onReOrderProcedures,
        child: const Text("Reorder"),
      ),
      widget.procedureDto.superSetId.isNotEmpty
          ? MenuItemButton(
              onPressed: () => widget.onRemoveSuperSet(widget.procedureDto.superSetId),
              child: Text("Remove Super-set", style: GoogleFonts.lato(color: Colors.red)),
            )
          : MenuItemButton(
              onPressed: widget.onSuperSet,
              child: const Text("Super-set"),
            ),
      MenuItemButton(
        onPressed: widget.onRemoveProcedure,
        child: Text(
          "Remove",
          style: GoogleFonts.lato(color: Colors.red),
        ),
      )
    ];
  }

  SetDto? _wherePastSetOrNull({required String id, required List<SetDto> pastSets}) {
    return pastSets.firstWhereOrNull((pastSet) => pastSet.id == id);
  }

  List<Widget> _displaySets({required ExerciseType exerciseType, required List<SetDto> sets}) {
    if (sets.isEmpty) return [];

    return sets.mapIndexed((index, setDto) {
      Widget setWidget = _createSetWidget(index: index, set: setDto, exerciseType: exerciseType);

      return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: setWidget);
    }).toList();
  }

  Widget _createSetWidget({required int index, required SetDto set, required ExerciseType exerciseType}) {
    SetDto? pastSet = _wherePastSetOrNull(id: set.id, pastSets: _pastSets);
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
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateProcedureNotes(procedureId: widget.procedureDto.id, value: value);
  }

  void _addSet() {
    _controllers.add((TextEditingController(), TextEditingController()));
    Provider.of<ProceduresProvider>(context, listen: false)
        .addSetForProcedure(procedureId: widget.procedureDto.id, pastSets: _pastSets);
  }

  void _removeSet(int index) {
    _controllers.removeAt(index);
    Provider.of<ProceduresProvider>(context, listen: false)
        .removeSetForProcedure(procedureId: widget.procedureDto.id, setIndex: index, pastSets: _pastSets);
  }

  void _updateWeight({required int setIndex, required double value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: value);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateWeight(procedureId: widget.procedureDto.id, setIndex: setIndex, setDto: updatedSet);
  }

  void _updateReps({required int setIndex, required num value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: value);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateReps(procedureId: widget.procedureDto.id, setIndex: setIndex, setDto: updatedSet);
  }

  void _updateDuration({required int setIndex, required Duration duration, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: duration.inMilliseconds);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateDuration(procedureId: widget.procedureDto.id, setIndex: setIndex, setDto: updatedSet);
  }

  void _updateDistance({required int setIndex, required double distance, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: distance);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateDistance(procedureId: widget.procedureDto.id, setIndex: setIndex, setDto: updatedSet);
  }

  void _updateSetType({required int index, required SetType type, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(type: type);
    final shouldUpdateValue1 = _controllers[index].$1.text.isEmpty;
    final shouldUpdateValue2 = _controllers[index].$2.text.isEmpty;
    Provider.of<ProceduresProvider>(context, listen: false).updateSetType(
        procedureId: widget.procedureDto.id,
        setIndex: index,
        setDto: updatedSet,
        pastSets: _pastSets,
        updateValue1: shouldUpdateValue1,
        updateValue2: shouldUpdateValue2);
  }

  void _updateSetCheck({required int setIndex, required SetDto setDto}) {
    final checked = setDto.checked;
    final updatedSet = setDto.copyWith(checked: !checked);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateSetCheck(procedureId: widget.procedureDto.id, setIndex: setIndex, setDto: updatedSet);
  }

  void _loadTextEditingControllers() {
    for (var set in widget.procedureDto.sets) {
      final value1 = set.value1;
      final value2 = set.value2;
      final pastSet = _pastSets.firstWhereOrNull((pastSet) => pastSet.id == set.id);
      final pastSetValue1 = pastSet?.value1 ?? 0;
      final pastSetValue2 = pastSet?.value2 ?? 0;
      TextEditingController controller1 = _getController(value1, pastSetValue1);
      TextEditingController controller2 = _getController(value2, pastSetValue2);

      _controllers.add((controller1, controller2));
    }
  }

  TextEditingController _getController(num currentValue, num pastSetValue) {
    return currentValue == pastSetValue
        ? TextEditingController()
        : TextEditingController(text: currentValue.toString());
  }

  @override
  void initState() {
    super.initState();

    final pastSets =
        Provider.of<RoutineLogProvider>(context, listen: false).wherePastSets(exercise: widget.procedureDto.exercise);
    _pastSets.addAll(pastSets);

    _loadTextEditingControllers();
  }

  @override
  Widget build(BuildContext context) {
    widget.onCache();

    final sets = context.select((ProceduresProvider provider) => provider.sets)[widget.procedureDto.id];

    final otherProcedureDto = widget.otherSuperSetProcedureDto;

    final exerciseString = widget.procedureDto.exercise.type;
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
                      MaterialPageRoute(builder: (context) => HomeScreen(exercise: widget.procedureDto.exercise)));
                },
                child: Text(widget.procedureDto.exercise.name,
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
          otherProcedureDto != null
              ? Text("with ${otherProcedureDto.exercise.name}",
                  style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12))
              : const SizedBox.shrink(),
          const SizedBox(height: 10),
          TextField(
            controller: TextEditingController(text: widget.procedureDto.notes),
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
          ..._displaySets(exerciseType: exerciseType, sets: sets ?? []),
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
