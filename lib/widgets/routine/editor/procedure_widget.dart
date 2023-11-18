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
import 'package:tracker_app/widgets/routine/editor/set_headers/weight_distance_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_headers/weight_reps_set_header.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/distance_duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/reps_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/duration_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/weight_distance_set_row.dart';
import 'package:tracker_app/widgets/routine/editor/set_rows/weight_reps_set_row.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
import '../../../screens/exercise/history/home_screen.dart';
import '../../../screens/editor/routine_editor_screen.dart';
import '../../../utils/general_utils.dart';

class ProcedureWidget extends StatefulWidget {
  final RoutineEditorType editorType;

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
    this.editorType = RoutineEditorType.edit,
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

  SetDto? _wherePastSets({required SetType type, required int index, required List<SetDto> pastSets}) {
    final sets = pastSets.where((set) => set.type == type).toList();
    return sets.length > index ? sets.elementAt(index) : null;
  }

  List<Widget> _displaySets(
      {required BuildContext context, required ExerciseType exerciseType, required List<SetDto> sets}) {
    if (sets.isEmpty) return [];

    Map<SetType, int> setCounts = {SetType.warmUp: 0, SetType.working: 0, SetType.failure: 0, SetType.drop: 0};

    final pastSets =
        Provider.of<RoutineLogProvider>(context, listen: false).wherePastSets(exercise: widget.procedureDto.exercise);

    return sets.mapIndexed((index, setDto) {
      SetDto? pastSet = _wherePastSets(type: setDto.type, index: setCounts[setDto.type]!, pastSets: pastSets);
      Widget setWidget = _createSetWidget(context, index, setDto, pastSet, exerciseType, setCounts);

      setCounts[setDto.type] = setCounts[setDto.type]! + 1;

      return setWidget;
    }).toList();
  }

  Widget _createSetWidget(BuildContext context, int index, SetDto setDto, SetDto? pastSet, ExerciseType exerciseType,
      Map<SetType, int> setCounts) {
    _controllers.add((TextEditingController(), TextEditingController()));
    switch (exerciseType) {
      case ExerciseType.weightAndReps:
      case ExerciseType.weightedBodyWeight:
      case ExerciseType.assistedBodyWeight:
        return WeightRepsSetRow(
          index: index,
          label: setDto.type == SetType.working ? "${setCounts[SetType.working]! + 1}" : setDto.type.label,
          procedureId: widget.procedureDto.id,
          setDto: setDto,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () =>
              _updateSetCheck(context: context, procedureId: widget.procedureDto.id, setIndex: index, setDto: setDto),
          onRemoved: () => _removeSet(context, index),
          onChangedType: (SetType type) => _updateSetType(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, type: type, setDto: setDto),
          onChangedReps: (num value) => _updateReps(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, value: value, setDto: setDto),
          onChangedWeight: (double value) => _updateWeight(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, value: value, setDto: setDto),
          controllers: _controllers[index],
        );
      case ExerciseType.bodyWeightAndReps:
        return RepsSetRow(
          index: index,
          label: setDto.type == SetType.working ? "${setCounts[SetType.working]! + 1}" : setDto.type.label,
          procedureId: widget.procedureDto.id,
          setDto: setDto,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () =>
              _updateSetCheck(context: context, procedureId: widget.procedureDto.id, setIndex: index, setDto: setDto),
          onRemoved: () => _removeSet(context, index),
          onChangedType: (SetType type) => _updateSetType(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, type: type, setDto: setDto),
          onChangedReps: (num value) => _updateReps(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, value: value, setDto: setDto),
          controllers: _controllers[index],
        );
      case ExerciseType.weightAndDistance:
        return WeightDistanceSetRow(
          index: index,
          label: setDto.type == SetType.working ? "${setCounts[SetType.working]! + 1}" : setDto.type.label,
          procedureId: widget.procedureDto.id,
          setDto: setDto,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () =>
              _updateSetCheck(context: context, procedureId: widget.procedureDto.id, setIndex: index, setDto: setDto),
          onRemoved: () => _removeSet(context, index),
          onChangedType: (SetType type) => _updateSetType(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, type: type, setDto: setDto),
          onChangedDistance: (double value) => _updateDistance(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, distance: value, setDto: setDto),
          onChangedWeight: (double value) => _updateWeight(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, value: value, setDto: setDto),
          controllers: _controllers[index],
        );
      case ExerciseType.duration:
        return DurationSetRow(
          index: index,
          label: setDto.type == SetType.working ? "${setCounts[SetType.working]! + 1}" : setDto.type.label,
          procedureId: widget.procedureDto.id,
          setDto: setDto,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () =>
              _updateSetCheck(context: context, procedureId: widget.procedureDto.id, setIndex: index, setDto: setDto),
          onRemoved: () => _removeSet(context, index),
          onChangedType: (SetType type) => _updateSetType(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, type: type, setDto: setDto),
          onChangedDuration: (Duration duration) => _updateDuration(
              context: context,
              procedureId: widget.procedureDto.id,
              setIndex: index,
              duration: duration,
              setDto: setDto),
        );
      case ExerciseType.distanceAndDuration:
        return DistanceDurationSetRow(
          index: index,
          label: setDto.type == SetType.working ? "${setCounts[SetType.working]! + 1}" : setDto.type.label,
          procedureId: widget.procedureDto.id,
          setDto: setDto,
          pastSetDto: pastSet,
          editorType: widget.editorType,
          onCheck: () =>
              _updateSetCheck(context: context, procedureId: widget.procedureDto.id, setIndex: index, setDto: setDto),
          onRemoved: () => _removeSet(context, index),
          onChangedType: (SetType type) => _updateSetType(
              context: context, procedureId: widget.procedureDto.id, setIndex: index, type: type, setDto: setDto),
          onChangedDuration: (Duration duration) => _updateDuration(
              context: context,
              procedureId: widget.procedureDto.id,
              setIndex: index,
              duration: duration,
              setDto: setDto),
          onChangedDistance: (double distance) => _updateDistance(
              context: context,
              procedureId: widget.procedureDto.id,
              setIndex: index,
              distance: distance,
              setDto: setDto),
          controllers: _controllers[index],
        );
      // Add other cases or a default case
    }
  }

  void _updateProcedureNotes({required BuildContext context, required String value}) {
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateProcedureNotes(procedureId: widget.procedureDto.id, value: value);
    widget.onCache();
  }

  void _addSet(BuildContext context) {
    _controllers.add((TextEditingController(), TextEditingController()));
    final pastSets =
        Provider.of<RoutineLogProvider>(context, listen: false).wherePastSets(exercise: widget.procedureDto.exercise);
    Provider.of<ProceduresProvider>(context, listen: false)
        .addSetForProcedure(procedureId: widget.procedureDto.id, pastSets: pastSets);
    widget.onCache();
  }

  void _removeSet(BuildContext context, int index) {
    _controllers.removeAt(index);
    Provider.of<ProceduresProvider>(context, listen: false)
        .removeSetForProcedure(procedureId: widget.procedureDto.id, setIndex: index);
    widget.onCache();
  }

  void _updateWeight(
      {required BuildContext context,
      required String procedureId,
      required int setIndex,
      required double value,
      required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: value);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateWeight(procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
    widget.onCache();
  }

  void _updateReps(
      {required BuildContext context,
      required String procedureId,
      required int setIndex,
      required num value,
      required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: value);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateReps(procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
    widget.onCache();
  }

  void _updateDuration(
      {required BuildContext context,
      required String procedureId,
      required int setIndex,
      required Duration duration,
      required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value1: duration.inMilliseconds);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateDuration(procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
    widget.onCache();
  }

  void _updateDistance(
      {required BuildContext context,
      required String procedureId,
      required int setIndex,
      required double distance,
      required SetDto setDto}) {
    final updatedSet = setDto.copyWith(value2: distance);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateDistance(procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
    widget.onCache();
  }

  void _updateSetType(
      {required BuildContext context,
      required String procedureId,
      required int setIndex,
      required SetType type,
      required SetDto setDto}) {
    final pastSets =
        Provider.of<RoutineLogProvider>(context, listen: false).wherePastSets(exercise: widget.procedureDto.exercise);
    final updatedSet = setDto.copyWith(type: type);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateSetType(procedureId: procedureId, setIndex: setIndex, setDto: updatedSet, pastSets: pastSets);
    widget.onCache();
  }

  void _updateSetCheck(
      {required BuildContext context, required String procedureId, required int setIndex, required SetDto setDto}) {
    final updatedSet = setDto.copyWith(checked: !setDto.checked);
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateSetCheck(procedureId: procedureId, setIndex: setIndex, setDto: updatedSet);
    widget.onCache();
  }

  @override
  Widget build(BuildContext context) {
    final sets = context.select((ProceduresProvider provider) => provider.sets)[widget.procedureDto.id];

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
                      builder: (context) => HomeScreen(exercise: widget.procedureDto.exercise)));
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
            onChanged: (value) => _updateProcedureNotes(context: context, value: value),
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
            ExerciseType.distanceAndDuration => DistanceDurationSetHeader(editorType: widget.editorType),
          },
          const SizedBox(height: 8),
          ..._displaySets(context: context, exerciseType: exerciseType, sets: sets ?? []),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
                onPressed: () => _addSet(context),
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
