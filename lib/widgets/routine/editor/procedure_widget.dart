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
  final VoidCallback onReplaceProcedure;
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
    required this.onReplaceProcedure,
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
        leadingIcon: const Icon(Icons.repeat_outlined),
        child: const Text("Reorder"),
      ),
      widget.procedureDto.superSetId.isNotEmpty
          ? MenuItemButton(
              onPressed: () => widget.onRemoveSuperSet(widget.procedureDto.superSetId),
              leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
              child: Text("Remove Super-set", style: GoogleFonts.lato(color: Colors.red)),
            )
          : MenuItemButton(
              onPressed: widget.onSuperSet,
              leadingIcon: const Icon(Icons.add),
              child: const Text("Super-set"),
            ),
      MenuItemButton(
        onPressed: widget.onReplaceProcedure,
        leadingIcon: const Icon(Icons.find_replace_rounded),
        child: const Text("Replace"),
      ),
      MenuItemButton(
        onPressed: widget.onRemoveProcedure,
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: Text(
          "Remove",
          style: GoogleFonts.lato(color: Colors.red),
        ),
      )
    ];
  }

  SetDto? _wherePastSet({required SetType type, required int index, required List<SetDto> pastSets}) {
    final sets = pastSets.where((set) => set.type == type).toList();
    return sets.length > index ? sets.elementAt(index) : null;
  }

  List<Widget> _displaySets({required ExerciseType exerciseType, required List<SetDto> sets}) {
    if (sets.isEmpty) return [];

    Map<SetType, int> setTypeCounts = {SetType.warmUp: 0, SetType.working: 0, SetType.failure: 0, SetType.drop: 0};

    final pastSets =
        Provider.of<RoutineLogProvider>(context, listen: false).wherePastSets(exercise: widget.procedureDto.exercise);

    return sets.mapIndexed((index, setDto) {
      SetDto? pastSet = _wherePastSet(type: setDto.type, index: setTypeCounts[setDto.type]!, pastSets: pastSets);

      Widget setWidget = _createSetWidget(
          index: index,
          currentSet: setDto,
          pastSet: pastSet,
          exerciseType: exerciseType,
          currentSetTypeIndex: setTypeCounts[setDto.type]!);

      setTypeCounts[setDto.type] = setTypeCounts[setDto.type]! + 1;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: setWidget,
      );
    }).toList();
  }

  Widget _createSetWidget(
      {required int index,
      required SetDto currentSet,
      required SetDto? pastSet,
      required ExerciseType exerciseType,
      required int currentSetTypeIndex}) {
    switch (exerciseType) {
      case ExerciseType.weightAndReps:
      case ExerciseType.weightedBodyWeight:
      case ExerciseType.assistedBodyWeight:
      _controllers.add((TextEditingController(), TextEditingController()));
        return WeightRepsSetRow(
          index: index,
          setTypeIndex: currentSetTypeIndex,
          procedureId: widget.procedureDto.id,
          setDto: currentSet,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(procedureId: widget.procedureDto.id, setIndex: index, setDto: currentSet),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) =>
              _updateSetType(procedureId: widget.procedureDto.id, index: index, type: type, setDto: currentSet),
          onChangedReps: (num value) =>
              _updateReps(procedureId: widget.procedureDto.id, setIndex: index, value: value, setDto: currentSet),
          onChangedWeight: (double value) =>
              _updateWeight(procedureId: widget.procedureDto.id, setIndex: index, value: value, setDto: currentSet),
          controllers: _controllers[index],
        );
      case ExerciseType.bodyWeightAndReps:
        _controllers.add((TextEditingController(), TextEditingController()));
        return RepsSetRow(
          index: index,
          setTypeIndex: currentSetTypeIndex,
          procedureId: widget.procedureDto.id,
          setDto: currentSet,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(procedureId: widget.procedureDto.id, setIndex: index, setDto: currentSet),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) =>
              _updateSetType(procedureId: widget.procedureDto.id, index: index, type: type, setDto: currentSet),
          onChangedReps: (num value) =>
              _updateReps(procedureId: widget.procedureDto.id, setIndex: index, value: value, setDto: currentSet),
          controllers: _controllers[index],
        );
      case ExerciseType.weightAndDistance:
        _controllers.add((TextEditingController(), TextEditingController()));
        return WeightDistanceSetRow(
          index: index,
          setTypeIndex: currentSetTypeIndex,
          procedureId: widget.procedureDto.id,
          setDto: currentSet,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(procedureId: widget.procedureDto.id, setIndex: index, setDto: currentSet),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) =>
              _updateSetType(procedureId: widget.procedureDto.id, index: index, type: type, setDto: currentSet),
          onChangedDistance: (double value) => _updateDistance(
              procedureId: widget.procedureDto.id, setIndex: index, distance: value, setDto: currentSet),
          onChangedWeight: (double value) =>
              _updateWeight(procedureId: widget.procedureDto.id, setIndex: index, value: value, setDto: currentSet),
          controllers: _controllers[index],
        );
      case ExerciseType.duration:
        return DurationSetRow(
          index: index,
          setTypeIndex: currentSetTypeIndex,
          procedureId: widget.procedureDto.id,
          setDto: currentSet,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(procedureId: widget.procedureDto.id, setIndex: index, setDto: currentSet),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) =>
              _updateSetType(procedureId: widget.procedureDto.id, index: index, type: type, setDto: currentSet),
          onChangedDuration: (Duration duration) => _updateDuration(
              procedureId: widget.procedureDto.id, setIndex: index, duration: duration, setDto: currentSet),
        );
      case ExerciseType.durationAndDistance:
        _controllers.add((TextEditingController(), TextEditingController()));
        return DurationDistanceSetRow(
          index: index,
          setTypeIndex: currentSetTypeIndex,
          procedureId: widget.procedureDto.id,
          setDto: currentSet,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () => _updateSetCheck(procedureId: widget.procedureDto.id, setIndex: index, setDto: currentSet),
          onRemoved: () => _removeSet(index),
          onChangedType: (SetType type) =>
              _updateSetType(procedureId: widget.procedureDto.id, index: index, type: type, setDto: currentSet),
          onChangedDuration: (Duration duration) => _updateDuration(
              procedureId: widget.procedureDto.id, setIndex: index, duration: duration, setDto: currentSet),
          onChangedDistance: (double distance) => _updateDistance(
              procedureId: widget.procedureDto.id, setIndex: index, distance: distance, setDto: currentSet),
          controllers: _controllers[index],
        );
      // Add other cases or a default case
    }
  }

  void _updateProcedureNotes({required String value}) {
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateProcedureNotes(context: context, procedureId: widget.procedureDto.id, value: value);
  }

  void _addSet() {
    _controllers.add((TextEditingController(), TextEditingController()));
    Provider.of<ProceduresProvider>(context, listen: false).addSetForProcedure(context: context, procedureId: widget.procedureDto.id, pastSets: _pastSets);
  }

  void _removeSet(int index) {
    _controllers.removeAt(index);
    Provider.of<ProceduresProvider>(context, listen: false)
        .removeSetForProcedure(procedureId: widget.procedureDto.id, setIndex: index);
  }

  void _updateWeight(
      {required String procedureId, required int setIndex, required double value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: value);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateWeight(context: context, procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
  }

  void _updateReps({required String procedureId, required int setIndex, required num value, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: value);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateReps(context: context, procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
  }

  void _updateDuration(
      {required String procedureId, required int setIndex, required Duration duration, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: duration.inMilliseconds);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateDuration(context: context, procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
  }

  void _updateDistance(
      {required String procedureId, required int setIndex, required double distance, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: distance);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateDistance(context: context, procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
  }

  void _updateSetType(
      {required String procedureId, required int index, required SetType type, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(type: type);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateSetType(context: context, procedureId: procedureId, setIndex: index, setDto: updatedSet);
  }

  void _updateSetCheck({required String procedureId, required int setIndex, required SetDto setDto}) {
    final checked = setDto.checked;
    final updatedSet = setDto.copyWith(checked: !checked);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateSetCheck(context: context, procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
  }

  @override
  void initState() {
    super.initState();
    for (var _ in widget.procedureDto.sets) {
      _controllers.add((TextEditingController(), TextEditingController()));
    }
    final pastSets = Provider.of<RoutineLogProvider>(context, listen: false).wherePastSets(exercise: widget.procedureDto.exercise);
    _pastSets.addAll(pastSets);
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
