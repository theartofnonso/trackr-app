import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/widgets/workout/set_list_item.dart';

import '../../dtos/procedure_dto.dart';

class ExerciseInWorkoutListSection extends StatelessWidget {
  final ExerciseInWorkoutDto exerciseInWorkoutDto;
  final ExerciseInWorkoutDto? otherExerciseInWorkoutDto;

  /// Exercise callbacks
  final void Function(String value) onUpdateNotes;
  final void Function() onRemoveExercise;
  final void Function() onAddSuperSetExercises;
  final void Function(String superSetId) onRemoveSuperSetExercises;
  final void Function() onReplaceExercise;
  final void Function() onSetProcedureTimer;
  final void Function() onRemoveProcedureTimer;

  /// Procedure callbacks
  final void Function() onAddProcedure;
  final void Function(int procedureIndex) onRemoveProcedure;

  /// Procedure values callbacks
  final void Function(int procedureIndex, int value) onChangedProcedureRepCount;
  final void Function(int procedureIndex, int value) onChangedProcedureWeight;
  final void Function(int procedureIndex, ProcedureType type) onChangedProcedureType;

  const ExerciseInWorkoutListSection({
    super.key,
    required this.exerciseInWorkoutDto,
    required this.otherExerciseInWorkoutDto,
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
  });

  /// Show [CupertinoActionSheet]
  void _showExerciseInWorkoutActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          exerciseInWorkoutDto.exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onAddProcedure();
            },
            child: const Text('Add new set', style: TextStyle(fontSize: 16)),
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
                  child: const Text(
                    'Super-set with ...',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onReplaceExercise();
            },
            child: const Text(
              'Replace with ...',
              style: TextStyle(fontSize: 16),
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

  List<SetListItem> _displayProcedures() {
    final workingProcedures = []; //3

    return exerciseInWorkoutDto.procedures.mapIndexed(((index, procedure) {

      final item = SetListItem(
        index: index,
        onRemoved: (int index) => onRemoveProcedure(index),
        workingIndex: procedure.type == ProcedureType.working ? workingProcedures.length : -1,
        exerciseInWorkoutDto: exerciseInWorkoutDto,
        procedureDto: procedure,
        onChangedRepCount: (int value) => onChangedProcedureRepCount(index, value),
        onChangedWeight: (int value) => onChangedProcedureWeight(index, value),
        onChangedType: (ProcedureType type) => onChangedProcedureType(index, type),
      );

      if(procedure.type == ProcedureType.working) {
        workingProcedures.add(procedure);
      }

      return item;
    }))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
        margin: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoListTile(
              padding: EdgeInsets.zero,
              title: Text(exerciseInWorkoutDto.exercise.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: exerciseInWorkoutDto.isSuperSet
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text("Super set: ${otherExerciseInWorkoutDto?.exercise.name}",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  : const SizedBox.shrink(),
              trailing: GestureDetector(
                  onTap: () => _showExerciseInWorkoutActionSheet(context),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 1.0),
                    child: Icon(CupertinoIcons.ellipsis),
                  )),
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
              style: TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.white.withOpacity(0.8)),
              placeholder: "Enter notes",
              placeholderStyle: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
        children: [
          ..._displayProcedures(),
        ]);
  }
}
