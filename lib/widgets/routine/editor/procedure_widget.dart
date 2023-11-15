import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/duration_num_pair.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/dtos/double_num_pair.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
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

class ProcedureWidget extends StatelessWidget {
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
  final void Function(int setIndex) onCheckSet;
  final void Function(int setIndex, double value) onChangedWeight;
  final void Function(int setIndex, num value) onChangedReps;
  final void Function(int setIndex, Duration duration) onChangedDuration;
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
  });

  /// [MenuItemButton]
  List<Widget> _menuActionButtons() {
    return [
      MenuItemButton(
        onPressed: onReOrderProcedures,
        leadingIcon: const Icon(Icons.repeat_outlined),
        child: const Text("Reorder"),
      ),
      procedureDto.superSetId.isNotEmpty
          ? MenuItemButton(
              onPressed: () {
                onRemoveSuperSet(procedureDto.superSetId);
              },
              leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
              child: Text("Remove Super-set", style: GoogleFonts.lato(color: Colors.red)),
            )
          : MenuItemButton(
              onPressed: onSuperSet,
              leadingIcon: const Icon(Icons.add),
              child: const Text("Super-set"),
            ),
      MenuItemButton(
        onPressed: onReplaceProcedure,
        leadingIcon: const Icon(Icons.find_replace_rounded),
        child: const Text("Replace"),
      ),
      MenuItemButton(
        onPressed: onRemoveProcedure,
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
    if (procedureDto.sets.isEmpty) return [];

    Map<SetType, int> setCounts = {SetType.warmUp: 0, SetType.working: 0, SetType.failure: 0, SetType.drop: 0};

    final pastSets =
        Provider.of<RoutineLogProvider>(context, listen: false).wherePastSets(exercise: procedureDto.exercise);

    return procedureDto.sets.mapIndexed((index, setDto) {
      SetDto? pastSet = _wherePastSets(type: setDto.type, index: setCounts[setDto.type]!, pastSets: pastSets);
      final setWidget = _SetWidget(
          type: exerciseType,
          index: index,
          onRemoved: () => onRemoveSet(index),
          onTapCheck: () => onCheckSet(index),
          onChangedWeight: (double value) => onChangedWeight(index, value),
          onChangedReps: (num value) => onChangedReps(index, value),
          onChangedType: (SetType type) => onChangedSetType(index, type),
          onChangedDuration: (Duration duration) => onChangedDuration(index, duration),
          onChangedDistance: (double value) => onChangedDistance(index, value),
          workingIndex: setDto.type == SetType.working ? setCounts[SetType.working]! : -1,
          setDto: setDto,
          pastSet: pastSet,
          editorType: editorType);

      setCounts[setDto.type] = setCounts[setDto.type]! + 1;

      return setWidget;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final otherProcedureDto = otherSuperSetProcedureDto;

    final exerciseString = procedureDto.exercise.type;
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
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ExerciseHistoryScreen(exercise: procedureDto.exercise)));
                },
                child: Text(procedureDto.exercise.name,
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
                  child: Text("with ${otherProcedureDto.exercise.name}",
                      style: GoogleFonts.lato(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 10),
          TextField(
            controller: TextEditingController(text: procedureDto.notes),
            onChanged: (value) => onUpdateNotes(value),
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
                editorType: editorType,
                firstLabel: weightLabel().toUpperCase(),
                secondLabel: 'REPS',
              ),
            ExerciseType.weightedBodyWeight => WeightedSetHeader(
                editorType: editorType,
                firstLabel: "+${weightLabel().toUpperCase()}",
                secondLabel: 'REPS',
              ),
            ExerciseType.assistedBodyWeight => WeightedSetHeader(
                editorType: editorType,
                firstLabel: '-${weightLabel().toUpperCase()}',
                secondLabel: 'REPS',
              ),
            ExerciseType.weightAndDistance => WeightedSetHeader(
                editorType: editorType, firstLabel: weightLabel().toUpperCase(), secondLabel: distanceLabel()),
            ExerciseType.bodyWeightAndReps => RepsSetHeader(editorType: editorType),
            ExerciseType.duration => DurationSetHeader(editorType: editorType),
            ExerciseType.distanceAndDuration => DistanceDurationSetHeader(editorType: editorType),
          },
          ..._displaySets(context: context, exerciseType: exerciseType),
          SizedBox(width: double.infinity, child: CTextButton(onPressed: onAddSet, label: 'Add set', buttonColor: tealBlueLight, textStyle: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _SetWidget extends StatelessWidget {
  final int index;
  final void Function() onRemoved;
  final void Function() onTapCheck;
  final void Function(double value) onChangedWeight;
  final void Function(num value) onChangedReps;
  final void Function(SetType type) onChangedType;
  final void Function(Duration duration) onChangedDuration;
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
      required this.onChangedWeight,
      required this.onChangedType,
      required this.onChangedDuration,
      required this.onChangedReps,
      required this.workingIndex,
      required this.setDto,
      required this.pastSet,
      required this.editorType,
      required this.onChangedDistance});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ExerciseType.weightAndReps ||
      ExerciseType.weightedBodyWeight ||
      ExerciseType.assistedBodyWeight ||
      ExerciseType.weightAndDistance =>
        WeightedSetRow(
          index: index,
          onRemoved: onRemoved,
          workingIndex: workingIndex,
          setDto: setDto as DoubleNumPair,
          pastSetDto: pastSet as DoubleNumPair?,
          editorType: editorType,
          onChangedOther: (num value) => onChangedReps(value),
          onChangedWeight: (double value) => onChangedWeight(value),
          onChangedType: (SetType type) => onChangedType(type),
          onTapCheck: onTapCheck,
        ),
      ExerciseType.bodyWeightAndReps => RepsSetRow(
          index: index,
          onRemoved: onRemoved,
          workingIndex: workingIndex,
          setDto: setDto as DoubleNumPair,
          pastSetDto: pastSet as DoubleNumPair?,
          editorType: editorType,
          onChangedOther: (num value) => onChangedReps(value),
          onChangedType: (SetType type) => onChangedType(type),
          onTapCheck: onTapCheck,
        ),
      ExerciseType.duration => DurationSetRow(
          index: index,
          workingIndex: workingIndex,
          setDto: setDto as DurationNumPair,
          pastSetDto: pastSet as DurationNumPair?,
          editorType: editorType,
          onRemoved: onRemoved,
          onChangedType: (SetType type) => onChangedType(type),
          onTapCheck: onTapCheck,
          onChangedDuration: (Duration duration) => onChangedDuration(duration),
        ),
      ExerciseType.distanceAndDuration => DistanceDurationSetRow(
          index: index,
          workingIndex: workingIndex,
          setDto: setDto as DurationNumPair,
          pastSetDto: pastSet as DurationNumPair?,
          editorType: editorType,
          onTapCheck: onTapCheck,
          onRemoved: onRemoved,
          onChangedType: (SetType type) {},
          onChangedDuration: (Duration duration) => onChangedDuration(duration),
          onChangedDistance: (double distance) => onChangedDistance(distance),
        ),
    };
  }
}
