import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/dtos/weighted_set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
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
  final void Function() onSetRestInterval;
  final void Function() onRemoveProcedureTimer;
  final void Function() onReOrderProcedures;

  /// Set callbacks
  final void Function() onAddSet;
  final void Function(int setIndex) onRemoveSet;
  final void Function(int setIndex) onCheckSet;
  final void Function(int setIndex, double value) onChangedWeightedValue;
  final void Function(int setIndex, num value) onChangedWeightedOther;
  final void Function(int setIndex, Duration duration, bool cache) onChangedDuration;
  final void Function(int setIndex, double distance) onChangedDistance;
  final void Function(int setIndex, SetType type) onChangedSetType;

  const ProcedureWidget({
    super.key,
    this.editorType = RoutineEditorType.edit,
    required this.procedureDto,
    required this.otherSuperSetProcedureDto,
    required this.onSuperSet,
    required this.onRemoveSuperSet,
    required this.onRemoveProcedure,
    required this.onChangedWeightedOther,
    required this.onChangedWeightedValue,
    required this.onChangedDuration,
    required this.onChangedDistance,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateNotes,
    required this.onReplaceProcedure,
    required this.onSetRestInterval,
    required this.onRemoveProcedureTimer,
    required this.onChangedSetType,
    required this.onReOrderProcedures,
    required this.onCheckSet,
  });

  @override
  State<ProcedureWidget> createState() => _ProcedureWidgetState();
}

class _ProcedureWidgetState extends State<ProcedureWidget> {
  List<SetDto> _pastSets = [];

  /// [MenuItemButton]
  List<Widget> _menuActionButtons() {
    return [
      MenuItemButton(
        onPressed: () {
          widget.onReOrderProcedures();
        },
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
              onPressed: () {
                widget.onSuperSet();
              },
              leadingIcon: const Icon(Icons.add),
              child: const Text("Super-set"),
            ),
      MenuItemButton(
        onPressed: () {
          widget.onReplaceProcedure();
        },
        leadingIcon: const Icon(Icons.find_replace_rounded),
        child: const Text("Replace"),
      ),
      MenuItemButton(
        onPressed: () {
          widget.onRemoveProcedure();
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: Text(
          "Remove",
          style: GoogleFonts.lato(color: Colors.red),
        ),
      )
    ];
  }

  SetDto? _wherePastSets({required SetType type, required int index}) {
    SetDto? pastSet;

    final sets = _pastSets.where((set) => set.type == type).toList();

    if (sets.length > index) {
      pastSet = sets[index];
    }
    return pastSet;
  }

  List<Widget> _displaySets({required ExerciseType exerciseType}) {
    if (widget.procedureDto.sets.isEmpty) {
      return <Widget>[];
    }

    int warmupSets = 0;
    int workingSets = 0;
    int failureSets = 0;
    int dropSets = 0;

    return widget.procedureDto.sets.mapIndexed(((index, setDto) {
      SetDto? pastSet = switch (setDto.type) {
        SetType.warmUp => _wherePastSets(type: setDto.type, index: warmupSets),
        SetType.working => _wherePastSets(type: setDto.type, index: workingSets),
        SetType.failure => _wherePastSets(type: setDto.type, index: failureSets),
        SetType.drop => _wherePastSets(type: setDto.type, index: dropSets),
      };

      final setWidget = _SetWidget(
          type: exerciseType,
          index: index,
          onRemoved: () => widget.onRemoveSet(index),
          onTapCheck: () => widget.onCheckSet(index),
          onChangedWeightedValue: (double value) => widget.onChangedWeightedValue(index, value),
          onChangedWeightedOther: (num value) => widget.onChangedWeightedOther(index, value),
          onChangedType: (SetType type) => widget.onChangedSetType(index, type),
          onChangedDuration: (Duration duration, bool cache) => widget.onChangedDuration(index, duration, cache),
          onChangedDistance: (double value) => widget.onChangedDistance(index, value),
          workingIndex: setDto.type == SetType.working ? workingSets : -1,
          setDto: setDto,
          pastSet: pastSet,
          editorType: widget.editorType);

      switch (setDto.type) {
        case SetType.warmUp:
          warmupSets += 1;
          break;
        case SetType.working:
          workingSets += 1;
          break;
        case SetType.failure:
          failureSets += 1;
          break;
        case SetType.drop:
          dropSets += 1;
          break;
      }

      return setWidget;
    })).toList();
  }

  String _displayTimer() {
    final duration = widget.procedureDto.restInterval;
    return duration != Duration.zero ? duration.secondsOrMinutesOrHours() : "Off";
  }

  @override
  Widget build(BuildContext context) {
    final otherProcedureDto = widget.otherSuperSetProcedureDto;

    final exerciseString = widget.procedureDto.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseString);

    return Container(
      padding: const EdgeInsets.only(top: 12, right: 12, bottom: 10, left: 12),
      decoration: BoxDecoration(
        color: tealBlueLight, // Set the background color
        borderRadius: BorderRadius.circular(2), // Set the border radius to make it rounded
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
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: Text("with ${widget.procedureDto.exercise.name}",
                      style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                )
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
          const SizedBox(height: 6),
          Row(
            children: [
              CTextButton(
                  onPressed: widget.onSetRestInterval,
                  label: 'Rest timer: ${_displayTimer()}',
                  buttonColor: tealBlueLighter),
              const SizedBox(width: 6),
              CTextButton(onPressed: widget.onAddSet, label: 'Add set', buttonColor: tealBlueLighter),
            ],
          ),
          const SizedBox(height: 10),
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
          ..._displaySets(exerciseType: exerciseType)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pastSets = Provider.of<RoutineLogProvider>(context, listen: false)
        .wherePastSetDtos(exercise: widget.procedureDto.exercise);
  }
}

class _SetWidget extends StatelessWidget {
  final int index;
  final void Function() onRemoved;
  final void Function() onTapCheck;
  final void Function(double value) onChangedWeightedValue;
  final void Function(num value) onChangedWeightedOther;
  final void Function(SetType type) onChangedType;
  final void Function(Duration duration, bool cache) onChangedDuration;
  final void Function(double distance) onChangedDistance;
  final int workingIndex;
  final SetDto setDto;
  final SetDto? pastSet;
  final RoutineEditorType editorType;
  final ExerciseType type;

  const _SetWidget(
      {required this.type,
      required this.index,
      required this.onRemoved,
      required this.onTapCheck,
      required this.onChangedWeightedValue,
      required this.onChangedType,
      required this.onChangedDuration,
      required this.onChangedWeightedOther,
      required this.workingIndex,
      required this.setDto,
      required this.pastSet,
      required this.editorType,
      required this.onChangedDistance});

  @override
  Widget build(BuildContext context) {
    //print(pastSet);
    return switch (type) {
      ExerciseType.weightAndReps ||
      ExerciseType.weightedBodyWeight ||
      ExerciseType.assistedBodyWeight ||
      ExerciseType.weightAndDistance =>
        WeightedSetRow(
          index: index,
          onRemoved: onRemoved,
          workingIndex: workingIndex,
          setDto: setDto as WeightedSetDto,
          pastSetDto: pastSet as WeightedSetDto?,
          editorType: editorType,
          onChangedOther: (num value) => onChangedWeightedOther(value),
          onChangedWeight: (double value) => onChangedWeightedValue(value),
          onChangedType: (SetType type) => onChangedType(type),
          onTapCheck: onTapCheck,
        ),
      ExerciseType.bodyWeightAndReps => RepsSetRow(
          index: index,
          onRemoved: onRemoved,
          workingIndex: workingIndex,
          setDto: setDto as WeightedSetDto,
          pastSetDto: pastSet as WeightedSetDto?,
          editorType: editorType,
          onChangedOther: (num value) => onChangedWeightedOther(value),
          onChangedType: (SetType type) => onChangedType(type),
          onTapCheck: onTapCheck,
        ),
      ExerciseType.duration => DurationSetRow(
          index: index,
          workingIndex: workingIndex,
          setDto: setDto as DurationDto,
          pastSetDto: pastSet as DurationDto?,
          editorType: editorType,
          onRemoved: onRemoved,
          onChangedType: (SetType type) => onChangedType(type),
          onTapCheck: onTapCheck,
          onChangedDuration: (Duration duration, bool cache) => onChangedDuration(duration, cache),
        ),
      ExerciseType.distanceAndDuration => DistanceDurationSetRow(
          index: index,
          workingIndex: workingIndex,
          setDto: setDto as DurationDto,
          editorType: editorType,
          onTapCheck: onTapCheck,
          onRemoved: onRemoved,
          onChangedType: (SetType type) {},
          onChangedDuration: (Duration duration, bool cache) => onChangedDuration(duration, cache),
          onChangedDistance: (double distance) => onChangedDistance(distance),
        ),
    };
  }
}
