import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/workout/editor/set_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/procedure_dto.dart';
import '../../../screens/workout_editor_screen.dart';

class ExerciseInWorkoutEditor extends StatelessWidget {
  final WorkoutEditorType editorType;

  final ExerciseInWorkoutDto exerciseInWorkoutDto;
  final ExerciseInWorkoutDto? superSetExerciseInWorkoutDto;

  /// Exercise callbacks
  final void Function(String value) onUpdateNotes;
  final void Function() onRemoveExercise;
  final void Function() onAddSuperSetExercises;
  final void Function(String superSetId) onRemoveSuperSetExercises;
  final void Function() onReplaceExercise;
  final void Function() onSetProcedureTimer;
  final void Function() onRemoveProcedureTimer;
  final void Function() onReOrderExercises;

  /// Procedure callbacks
  final void Function() onAddProcedure;
  final void Function(int procedureIndex) onRemoveProcedure;
  final void Function(int procedureIndex) onCheckProcedure;

  /// Procedure values callbacks
  final void Function(int procedureIndex, int value) onChangedProcedureRepCount;
  final void Function(int procedureIndex, int value) onChangedProcedureWeight;
  final void Function(int procedureIndex, SetType type) onChangedProcedureType;

  const ExerciseInWorkoutEditor({
    super.key,
    this.editorType = WorkoutEditorType.editing,
    required this.exerciseInWorkoutDto,
    required this.superSetExerciseInWorkoutDto,
    required this.onAddSuperSetExercises,
    required this.onRemoveSuperSetExercises,
    required this.onRemoveExercise,
    required this.onChangedProcedureRepCount,
    required this.onChangedProcedureWeight,
    required this.onAddProcedure,
    required this.onRemoveProcedure,
    required this.onUpdateNotes,
    required this.onReplaceExercise,
    required this.onSetProcedureTimer,
    required this.onRemoveProcedureTimer,
    required this.onChangedProcedureType,
    required this.onReOrderExercises,
    required this.onCheckProcedure,
  });

  /// Show [CupertinoActionSheet]
  void _showExerciseInWorkoutActionSheet(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          exerciseInWorkoutDto.exercise.name,
          style: textStyle?.copyWith(color: tealBlueLight.withOpacity(0.6)),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onReOrderExercises();
            },
            child: Text(
              'Reorder Exercises',
              style: textStyle,
            ),
          ),
          exerciseInWorkoutDto.isSuperSet
              ? CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                    onRemoveSuperSetExercises(exerciseInWorkoutDto.superSetId);
                  },
                  child: const Text(
                    'Remove super set',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    onAddSuperSetExercises();
                  },
                  child: Text(
                    'Super-set with ...',
                    style: textStyle,
                  ),
                ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onReplaceExercise();
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
              onRemoveExercise();
            },
            child: const Text('Remove', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  List<SetWidget> _displayProcedures() {
    int workingSets = 0;

    return exerciseInWorkoutDto.procedures.mapIndexed(((index, setDto) {
      final widget = SetWidget(
        index: index,
        onRemoved: () => onRemoveProcedure(index),
        workingIndex: setDto.type == SetType.working ? workingSets : -1,
        setDto: setDto,
        editorType: editorType,
        onChangedRep: (int value) => onChangedProcedureRepCount(index, value),
        onChangedWeight: (int value) => onChangedProcedureWeight(index, value),
        onChangedType: (SetType type) => onChangedProcedureType(index, type),
        onTapCheck: () => onCheckProcedure(index),
      );

      if (setDto.type == SetType.working) {
        workingSets += 1;
      }

      return widget;
    })).toList();
  }

  String _displayTimer() {
    final duration = exerciseInWorkoutDto.procedureDuration;
    return duration != null && duration != Duration.zero ? duration.secondsOrMinutesOrHours() : "Off";
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      margin: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      header: Column(
        children: [
          CupertinoListTile(
            backgroundColorActivated: Colors.transparent,
            onTap: () => _showExerciseInWorkoutActionSheet(context),
            padding: EdgeInsets.zero,
            title: Text(exerciseInWorkoutDto.exercise.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: exerciseInWorkoutDto.isSuperSet
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("Super set: ${superSetExerciseInWorkoutDto?.exercise.name}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                : const SizedBox.shrink(),
            trailing: const Padding(
              padding: EdgeInsets.only(right: 1.0),
              child: Icon(CupertinoIcons.ellipsis, color: CupertinoColors.white),
            ),
          ),
          CupertinoTextField(
            controller: TextEditingController(text: exerciseInWorkoutDto.notes),
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
          const SizedBox(
            height: 8,
          ),
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
            onTap: onAddProcedure,
            title: Text(
              "Add Set",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            leading: const Icon(CupertinoIcons.add_circled, color: CupertinoColors.white, size: 20),
          ),
        ],
      ),
      children: [
        ..._displayProcedures(),
      ],
    );
  }
}
