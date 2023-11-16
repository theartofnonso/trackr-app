import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/providers/procedures_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/distance_duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/duration_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/weighted_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/distance_duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/weighted_set_row.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
import '../../../screens/exercise/exercise_history_screen.dart';
import '../../../screens/editor/routine_editor_screen.dart';
import '../../../utils/general_utils.dart';

class ProcedureWidget extends StatefulWidget {
  final RoutineEditorType editorType;

  final ProcedureDto procedureDto;
  final ProcedureDto? otherSuperSetProcedureDto;

  /// Procedure callbacks
  final void Function(String value) onUpdateNotes;
  final void Function() onReplaceProcedure;
  final void Function() onRemoveProcedure;
  final void Function() onSuperSet;
  final void Function(String superSetId) onRemoveSuperSet;
  final void Function() onReOrderProcedures;

  /// Set callbacks
  final void Function() onAddSet;
  final void Function(int setIndex) onRemoveSet;
  final void Function() onCheckSet;
  final void Function(int setIndex, SetType type) onChangedSetType;
  final void Function(int setIndex, double value) onChangedWeight;
  final void Function(int setIndex, num value) onChangedReps;
  final void Function(int setIndex, Duration duration) onChangedDuration;
  final void Function(int setIndex, double distance) onChangedDistance;

  final List<SetDto> sets;

  const ProcedureWidget({
    super.key,
    this.editorType = RoutineEditorType.edit,
    required this.procedureDto,
    required this.otherSuperSetProcedureDto,
    required this.onSuperSet,
    required this.onRemoveSuperSet,
    required this.onRemoveProcedure,
    required this.onChangedReps,
    required this.onChangedWeight,
    required this.onChangedDuration,
    required this.onChangedDistance,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateNotes,
    required this.onReplaceProcedure,
    required this.onChangedSetType,
    required this.onReOrderProcedures,
    required this.onCheckSet,
    required this.sets,
  });

  @override
  State<ProcedureWidget> createState() => _ProcedureWidgetState();
}

class _ProcedureWidgetState extends State<ProcedureWidget> {
  List<SetDto> _sets = [];

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
              onPressed: () {
                widget.onRemoveSuperSet(widget.procedureDto.superSetId);
              },
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

  SetDto? _wherePastSets({required SetType type, required int index, required List<SetDto> pastSets}) {
    final sets = pastSets.where((set) => set.type == type).toList();
    return sets.length > index ? sets.elementAt(index) : null;
  }

  List<Widget> _displaySets({required BuildContext context, required ExerciseType exerciseType}) {
    if (_sets.isEmpty) return [];

    Map<SetType, int> setCounts = {SetType.warmUp: 0, SetType.working: 0, SetType.failure: 0, SetType.drop: 0};

    final pastSets =
        Provider.of<RoutineLogProvider>(context, listen: false).wherePastSets(exercise: widget.procedureDto.exercise);

    return _sets.mapIndexed((index, setDto) {
      SetDto? pastSet = _wherePastSets(type: setDto.type, index: setCounts[setDto.type]!, pastSets: pastSets);
      Widget setWidget = _createSetWidget(index, setDto, pastSet, exerciseType, setCounts);

      setCounts[setDto.type] = setCounts[setDto.type]! + 1;

      return setWidget;
    }).toList();
  }

  Widget _createSetWidget(
      int index, SetDto setDto, SetDto? pastSet, ExerciseType exerciseType, Map<SetType, int> setCounts) {
    switch (exerciseType) {
      case ExerciseType.weightAndReps:
      case ExerciseType.weightedBodyWeight:
      case ExerciseType.assistedBodyWeight:
      case ExerciseType.weightAndDistance:
        return WeightedSetRow(
          key: ValueKey(setDto.id),
          index: index,
          label: setDto.type == SetType.working ? "${setCounts[SetType.working]! + 1}" : setDto.type.label,
          exerciseId: widget.procedureDto.exercise.id,
          setDto: setDto,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onRemoved: () => widget.onRemoveSet(index),
          onCheck: widget.onCheckSet,
          onChangedType: (SetType type) => widget.onChangedSetType(index, type),
          onChangedReps: (num value) => widget.onChangedReps(index, value),
          onChangedWeight: (double value) => widget.onChangedWeight(index, value),
        );
      case ExerciseType.bodyWeightAndReps:
        return RepsSetRow(
          key: ValueKey(setDto.id),
          index: index,
          label: setDto.type == SetType.working ? "${setCounts[SetType.working]! + 1}" : setDto.type.label,
          exerciseId: widget.procedureDto.exercise.id,
          setDto: setDto,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onRemoved: () {
            Provider.of<ProceduresProvider>(context, listen: false)
                .removeSetForProcedure(exerciseId: widget.procedureDto.exercise.id, setIndex: index);
            setState(() {
              _sets.removeAt(index);
            });
            widget.onRemoveSet(index);
          },
          onCheck: widget.onCheckSet,
          onChangedType: (SetType type) => widget.onChangedSetType(index, type),
          onChangedReps: (num value) => widget.onChangedReps(index, value),
        );
      case ExerciseType.duration:
        return DurationSetRow(
          key: ValueKey(setDto.id),
          index: index,
          label: setDto.type == SetType.working ? "${setCounts[SetType.working]! + 1}" : setDto.type.label,
          exerciseId: widget.procedureDto.exercise.id,
          setDto: setDto,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onRemoved: () => widget.onRemoveSet(index),
          onCheck: widget.onCheckSet,
          onChangedType: (SetType type) => widget.onChangedSetType(index, type),
          onChangedDuration: (Duration duration) => widget.onChangedDuration(index, duration),
        );
      case ExerciseType.distanceAndDuration:
        return DistanceDurationSetRow(
          index: index,
          label: setDto.type == SetType.working ? "${setCounts[SetType.working]! + 1}" : setDto.type.label,
          exerciseId: widget.procedureDto.exercise.id,
          setDto: setDto,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onRemoved: () => widget.onRemoveSet(index),
          onCheck: widget.onCheckSet,
          onChangedType: (SetType type) => widget.onChangedSetType(index, type),
          onChangedDuration: (Duration duration) => widget.onChangedDuration(index, duration),
          onChangedDistance: (double distance) => widget.onChangedDistance(index, distance),
        );
      // Add other cases or a default case
    }
  }

  @override
  Widget build(BuildContext context) {

    final otherProcedureDto = widget.otherSuperSetProcedureDto;

    final exerciseString = widget.procedureDto.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseString);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tealBlueLight, // Set the background color
        borderRadius: BorderRadius.circular(3), // Set the border radius to make it rounded
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ExerciseHistoryScreen(exercise: widget.procedureDto.exercise)));
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
            onChanged: (value) => widget.onUpdateNotes(value),
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
            ExerciseType.weightAndReps => WeightedSetHeader(
                editorType: widget.editorType,
                firstLabel: weightLabel().toUpperCase(),
                secondLabel: 'REPS',
              ),
            ExerciseType.weightedBodyWeight => WeightedSetHeader(
                editorType: widget.editorType,
                firstLabel: "+${weightLabel().toUpperCase()}",
                secondLabel: 'REPS',
              ),
            ExerciseType.assistedBodyWeight => WeightedSetHeader(
                editorType: widget.editorType,
                firstLabel: '-${weightLabel().toUpperCase()}',
                secondLabel: 'REPS',
              ),
            ExerciseType.weightAndDistance => WeightedSetHeader(
                editorType: widget.editorType, firstLabel: weightLabel().toUpperCase(), secondLabel: distanceLabel()),
            ExerciseType.bodyWeightAndReps => RepsSetHeader(editorType: widget.editorType),
            ExerciseType.duration => DurationSetHeader(editorType: widget.editorType),
            ExerciseType.distanceAndDuration => DistanceDurationSetHeader(editorType: widget.editorType),
          },
          ..._displaySets(context: context, exerciseType: exerciseType),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
                onPressed: () {
                  Provider.of<ProceduresProvider>(context, listen: false)
                      .addSetForProcedure(exerciseId: widget.procedureDto.exercise.id);
                  setState(() {
                    _sets.add(SetDto(0, 0, SetType.working, false));
                  });
                  widget.onAddSet();
                },
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

  @override
  void initState() {
    super.initState();
    _sets = List.from(widget.sets);
  }
}
