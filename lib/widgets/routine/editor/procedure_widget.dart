import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/routine/editor/set_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
import '../../../providers/exercise_provider.dart';
import '../../../screens/exercise_history_screen.dart';
import '../../../screens/routine_editor_screen.dart';

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

  /// [MenuItemButton]
  List<Widget> _menuActionButtons() {
    return [
      MenuItemButton(
        onPressed: () {
          onReOrderProcedures();
        },
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
              onPressed: () {
                onSuperSet();
              },
              leadingIcon: const Icon(Icons.add),
              child: const Text("Super-set"),
            ),
      MenuItemButton(
        onPressed: () {
          onReplaceProcedure();
        },
        leadingIcon: const Icon(Icons.find_replace_rounded),
        child: const Text("Replace"),
      ),
      MenuItemButton(
        onPressed: () {
          onRemoveProcedure();
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: Text(
          "Remove",
          style: GoogleFonts.lato(color: Colors.red),
        ),
      )
    ];
  }

  SetDto? _whereSets({required SetType type, required int index,  required List<ProcedureDto> procedures}) {

    SetDto? set;

    for (ProcedureDto procedure in procedures) {
      final pastSets = procedure.sets;

      if (pastSets.isEmpty) continue; /// Skip to next past [ProcedureDto] in the list

      final sets = pastSets.where((set) => set.type == type).toList();

      if (sets.length <= index) continue; /// Skip to next past [ProcedureDto] in the list

      final pastSet = sets[index];
      final volume = pastSet.reps * pastSet.weight;

      if (volume > 0) {
        set = pastSet;
        break;
      }
    }
    return set;
  }

  List<Widget>? _displaySets(BuildContext context) {
    int warmupSets = 0;
    int workingSets = 0;
    int failureSets = 0;
    int dropSets = 0;

    final pastProcedures = Provider.of<RoutineLogProvider>(context, listen: false).whereProcedureDtos(procedureDto: procedureDto);

    return procedureDto.sets.mapIndexed(((index, setDto) {
      SetDto? pastSet = switch(setDto.type) {
        SetType.warmUp => _whereSets(type: setDto.type, index: warmupSets, procedures: pastProcedures),
        SetType.working => _whereSets(type: setDto.type, index: workingSets, procedures: pastProcedures),
        SetType.failure => _whereSets(type: setDto.type, index: failureSets, procedures: pastProcedures),
        SetType.drop => _whereSets(type: setDto.type, index: dropSets, procedures: pastProcedures),
      };

      final widget = SetWidget(
        index: index,
        onRemoved: () => onRemoveSet(index),
        workingIndex: setDto.type == SetType.working ? workingSets : -1,
        setDto: setDto,
        pastSetDto: pastSet,
        editorType: editorType,
        onChangedReps: (int value) => onChangedSetRep(index, value),
        onChangedWeight: (double value) => onChangedSetWeight(index, value),
        onChangedType: (SetType type) => onChangedSetType(index, type),
        onTapCheck: () => onCheckSet(index),
      );

      if (setDto.type == SetType.warmUp) {
        warmupSets += 1;
      }

      if (setDto.type == SetType.working) {
        workingSets += 1;
      }

      if (setDto.type == SetType.failure) {
        failureSets += 1;
      }

      if (setDto.type == SetType.drop) {
        dropSets += 1;
      }

      return widget;
    })).toList();
  }

  String _displayTimer() {
    final duration = procedureDto.restInterval;
    return duration != Duration.zero ? duration.secondsOrMinutesOrHours() : "Off";
  }

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    final otherProcedureDto = otherSuperSetProcedureDto;

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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ExerciseHistoryScreen(exerciseId: procedureDto.exerciseId)));
                },
                child: Text(exerciseProvider.whereExercise(exerciseId: procedureDto.exerciseId).name,
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
                  child: Text("with ${exerciseProvider.whereExercise(exerciseId: otherProcedureDto.exerciseId).name}",
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
          const SizedBox(height: 6),
          Row(
            children: [
              CTextButton(
                  onPressed: onSetRestInterval, label: 'Rest timer: ${_displayTimer()}', buttonColor: tealBlueLighter),
              const SizedBox(width: 6),
              CTextButton(onPressed: onAddSet, label: 'Add set', buttonColor: tealBlueLighter),
            ],
          ),
          const SizedBox(height: 10),
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FixedColumnWidth(110),
              2: FixedColumnWidth(85),
              3: FixedColumnWidth(55),
              4: FixedColumnWidth(55),
            },
            children: <TableRow>[
              TableRow(
                children: [
                  Text("SET",
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center),
                  Text("PREVIOUS",
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center),
                  Text(weightLabel().toUpperCase(),
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center),
                  Text("REPS",
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center),
                  const TableCell(verticalAlignment: TableCellVerticalAlignment.middle, child: Icon(Icons.check, size: 12,))
                ]
              ),
            ],
          ),
          ...?_displaySets(context)
        ],
      ),
    );
  }
}
