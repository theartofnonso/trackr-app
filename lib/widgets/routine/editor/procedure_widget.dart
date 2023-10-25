import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/routine/editor/set_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
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

  /// Show [CupertinoActionSheet]
  List<Widget> _menuActionButtons(BuildContext context) {
    return [
      MenuItemButton(
        onPressed: () {
          onReOrderProcedures();
        },
        // style: ButtonStyle(backgroundColor: MaterialStateProperty.all(tealBlueLight),),
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
        // style: ButtonStyle(backgroundColor: MaterialStateProperty.all(tealBlueLight),),
        leadingIcon: const Icon(Icons.find_replace_rounded),
        child: const Text("Replace"),
      ),
      MenuItemButton(
        onPressed: () {
          onRemoveProcedure();
        },
        // style: ButtonStyle(backgroundColor: MaterialStateProperty.all(tealBlueLight),),
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
      padding: const EdgeInsets.only(right: 12, bottom: 10, left: 12),
      decoration: BoxDecoration(
        color: tealBlueLight, // Set the background color
        borderRadius: BorderRadius.circular(2), // Set the border radius to make it rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(procedureDto.exercise.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
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
                      icon: const Icon(CupertinoIcons.ellipsis, color: CupertinoColors.white),
                      tooltip: 'Show menu',
                    );
                  },
                  menuChildren: _menuActionButtons(context))
            ],
          ),
          // procedureDto.superSetId.isNotEmpty
          //     ? Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 0.0),
          //   child: Text("with ${otherSuperSetProcedureDto?.exercise.name}",
          //       style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          // )
          //     : const SizedBox.shrink(),
          TextField(
            controller: TextEditingController(text: procedureDto.notes),
            onChanged: (value) => onUpdateNotes(value),
            expands: true,
            //decoration: const BoxDecoration(color: tealBlueLighter, borderRadius: BorderRadius.all(Radius.circular(2))),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
              filled: true,
              fillColor: const Color.fromRGBO(32, 32, 32, 1), // Set
            ),
            keyboardType: TextInputType.text,
            maxLength: 150,
            maxLines: null,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: TextStyle(fontWeight: FontWeight.w500, color: CupertinoColors.white.withOpacity(0.8), fontSize: 14),
            // placeholder: "Enter notes",
            // placeholderStyle: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 15),
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
          Column(
            children: [...?_displaySets()],
          )
        ],
      ),
    );
  }
}
