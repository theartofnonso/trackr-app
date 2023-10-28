import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/routine/editor/set_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
import '../../../screens/exercise_history_screen.dart';
import '../../../screens/routine_editor_screen.dart';

class ProcedureWidget extends StatelessWidget {
  final RoutineEditorMode editorType;

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
  final void Function(int setIndex, int value) onChangedSetWeight;
  final void Function(int setIndex, SetType type) onChangedSetType;

  const ProcedureWidget({
    super.key,
    this.editorType = RoutineEditorMode.editing,
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
              child: const Text("Remove Super-set", style: TextStyle(color: Colors.red)),
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
        child: const Text(
          "Remove",
          style: TextStyle(color: Colors.red),
        ),
      )
    ];
  }

  List<Widget>? _displaySets() {
    int workingSets = 0;

    return procedureDto.sets.mapIndexed(((index, setDto) {
      final widget = SetWidget(
        index: index,
        onRemoved: () => onRemoveSet(index),
        workingIndex: setDto.type == SetType.working ? workingSets : -1,
        setDto: setDto,
        editorType: editorType,
        onChangedRep: (int value) => onChangedSetRep(index, value),
        onChangedWeight: (int value) => onChangedSetWeight(index, value),
        onChangedType: (SetType type) => onChangedSetType(index, type),
        onTapCheck: () => onCheckSet(index),
      );

      if (setDto.type == SetType.working) {
        workingSets += 1;
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
                      builder: (context) => ExerciseHistoryScreen(exerciseId: procedureDto.exercise.id)));
                },
                child: Text(procedureDto.exercise.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
                      icon: const Icon(CupertinoIcons.ellipsis, color: Colors.white),
                      tooltip: 'Show menu',
                    );
                  },
                  menuChildren: _menuActionButtons())
            ],
          ),
          procedureDto.superSetId.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: Text("with ${otherSuperSetProcedureDto?.exercise.name}",
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
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
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            maxLines: null,
            cursorColor: Colors.white,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
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
          Column(
            children: [
              const Row(
                children: [
                  SizedBox(
                      width: 30,
                      child: Text("SET", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70), textAlign: TextAlign.center)),
                  SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                      width: 85,
                      child: Text("REPS",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70), textAlign: TextAlign.center)),
                  SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                      width: 85,
                      child: Text("KG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70), textAlign: TextAlign.center))
                ],
              ),
              ...?_displaySets()
            ],
          )
        ],
      ),
    );
  }
}
