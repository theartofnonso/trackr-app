import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/workout/editor/set_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
import '../../../screens/workout_editor_screen.dart';

class ProcedureWidget extends StatelessWidget {
  final WorkoutEditorType editorType;

  final ProcedureDto procedureDto;
  final ProcedureDto? superSetProcedureDto;

  /// Procedure callbacks
  final void Function(String value) onUpdateNotes;
  final void Function() onReplaceProcedure;
  final void Function() onRemoveProcedure;
  final void Function() onAddSuperSetProcedure;
  final void Function(String superSetId) onRemoveSuperSetProcedure;
  final void Function() onSetProcedureTimer;
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
    this.editorType = WorkoutEditorType.editing,
    required this.procedureDto,
    required this.superSetProcedureDto,
    required this.onAddSuperSetProcedure,
    required this.onRemoveSuperSetProcedure,
    required this.onRemoveProcedure,
    required this.onChangedSetRep,
    required this.onChangedSetWeight,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onUpdateNotes,
    required this.onReplaceProcedure,
    required this.onSetProcedureTimer,
    required this.onRemoveProcedureTimer,
    required this.onChangedSetType,
    required this.onReOrderProcedures,
    required this.onCheckSet,
  });

  /// Show [CupertinoActionSheet]
  void _showProcedureActionSheet(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          procedureDto.exercise.name,
          style: textStyle?.copyWith(color: tealBlueLight.withOpacity(0.6)),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onReOrderProcedures();
            },
            child: Text(
              'Reorder Exercises',
              style: textStyle,
            ),
          ),
          procedureDto.isSuperSet
              ? CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                    onRemoveSuperSetProcedure(procedureDto.superSetId);
                  },
                  child: const Text(
                    'Remove super set',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    onAddSuperSetProcedure();
                  },
                  child: Text(
                    'Super-set with ...',
                    style: textStyle,
                  ),
                ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onReplaceProcedure();
            },
            child: Text(
              'Replace with ...',
              style: textStyle,
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onRemoveProcedure();
            },
            child: const Text('Remove', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  List<Widget> _displaySets() {
    int workingSets = 0;

    return procedureDto.sets.mapIndexed(((index, setDto) {
      final widget = Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: SetWidget(
          index: index,
          onRemoved: () => onRemoveSet(index),
          workingIndex: setDto.type == SetType.working ? workingSets : -1,
          setDto: setDto,
          editorType: editorType,
          onChangedRep: (int value) => onChangedSetRep(index, value),
          onChangedWeight: (int value) => onChangedSetWeight(index, value),
          onChangedType: (SetType type) => onChangedSetType(index, type),
          onTapCheck: () => onCheckSet(index),
        ),
      );

      if (setDto.type == SetType.working) {
        workingSets += 1;
      }

      return widget;
    })).toList();
  }

  String _displayTimer() {
    final duration = procedureDto.procedureDuration;
    return duration != null && duration != Duration.zero ? duration.secondsOrMinutesOrHours() : "Off";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          CupertinoListTile(
            backgroundColorActivated: Colors.transparent,
            onTap: () => _showProcedureActionSheet(context),
            padding: EdgeInsets.zero,
            title: Text(procedureDto.exercise.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: procedureDto.isSuperSet
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("Super set: ${superSetProcedureDto?.exercise.name}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                : const SizedBox.shrink(),
            trailing: const Icon(CupertinoIcons.ellipsis, color: CupertinoColors.white),
          ),
          CupertinoTextField(
            controller: TextEditingController(text: procedureDto.notes),
            onChanged: (value) => onUpdateNotes(value),
            expands: true,
            decoration: const BoxDecoration(color: Colors.transparent),
            padding: EdgeInsets.zero,
            keyboardType: TextInputType.text,
            maxLength: 240,
            maxLines: null,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.white.withOpacity(0.8), fontSize: 15),
            placeholder: "Enter notes",
            placeholderStyle: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 15),
          ),
          const SizedBox(height: 6),
          CupertinoListTile(
            leadingToTitle: 8,
            backgroundColorActivated: Colors.transparent,
            onTap: onSetProcedureTimer,
            padding: EdgeInsets.zero,
            leading: const Icon(
              CupertinoIcons.timer,
              color: CupertinoColors.white,
              size: 20,
            ),
            title: Text("Rest Timer", style: Theme.of(context).textTheme.bodySmall),
            trailing: Text(_displayTimer(), style: Theme.of(context).textTheme.bodyMedium),
          ),
          CupertinoListTile(
            leadingToTitle: 8,
            backgroundColorActivated: Colors.transparent,
            padding: EdgeInsets.zero,
            onTap: onAddSet,
            title: Text(
              "Add Set",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            leading: const Icon(CupertinoIcons.add_circled, color: CupertinoColors.white, size: 20),
          ),
          const SizedBox(
            height: 4,
          ),
          Column(
            children: [..._displaySets()],
          )
        ],
      ),
    );
  }
}