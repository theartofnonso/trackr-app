import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/routine/editor/procedure_table_headers/assisted_weight_table_header.dart';
import 'package:tracker_app/widgets/routine/editor/procedure_table_headers/bodyweight_table_header.dart';
import 'package:tracker_app/widgets/routine/editor/procedure_table_headers/distance_duration_table_header.dart';
import 'package:tracker_app/widgets/routine/editor/procedure_table_headers/duration_table_header.dart';
import 'package:tracker_app/widgets/routine/editor/procedure_table_headers/weight_distance_table_header.dart';
import 'package:tracker_app/widgets/routine/editor/procedure_table_headers/weight_reps_table_header.dart';
import 'package:tracker_app/widgets/routine/editor/procedure_table_headers/weighted_bodyweight_table_header.dart';
import 'package:tracker_app/widgets/routine/editor/weight_reps_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
import '../../../screens/exercise/exercise_history_screen.dart';
import '../../../screens/editor/routine_editor_screen.dart';

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
  final void Function(int setIndex, int value) onChangedSetRep;
  final void Function(int setIndex, double value) onChangedSetWeight;
  final void Function(int setIndex, SetType type) onChangedSetType;

  const ProcedureWidget({
    super.key,
    this.editorType = RoutineEditorType.edit,
    required this.procedureDto,
    required this.otherSuperSetProcedureDto,
    required this.onSuperSet,
    required this.onRemoveSuperSet,
    required this.onRemoveProcedure,
    required this.onChangedSetRep,
    required this.onChangedSetWeight,
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

  List<Widget> _displaySets() {
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

      final setWidget = WeightRepsWidget(
        index: index,
        onRemoved: () => widget.onRemoveSet(index),
        workingIndex: setDto.type == SetType.working ? workingSets : -1,
        setDto: setDto,
        pastSetDto: pastSet,
        editorType: widget.editorType,
        onChangedReps: (int value) => widget.onChangedSetRep(index, value),
        onChangedWeight: (double value) => widget.onChangedSetWeight(index, value),
        onChangedType: (SetType type) => widget.onChangedSetType(index, type),
        onTapCheck: () => widget.onCheckSet(index),
      );

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

    final exerciseType = ExerciseType.fromString(widget.procedureDto.exercise.type);

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
          switch(exerciseType) {
            ExerciseType.weightAndReps => const WeightAndRepsTableHeader(),
            ExerciseType.bodyWeightAndReps => const BodyWeightTableHeader(),
            ExerciseType.weightedBodyWeight => const WeightedBodyWeightTableHeader(),
            ExerciseType.assistedBodyWeight => const AssistedWeightTableHeader(),
            ExerciseType.duration => const DurationTableHeader(),
            ExerciseType.distanceAndDuration => const DistanceDurationTableHeader(),
            ExerciseType.weightAndDistance => const WeightAndDistanceTableHeader(),
          },
          ..._displaySets()
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
