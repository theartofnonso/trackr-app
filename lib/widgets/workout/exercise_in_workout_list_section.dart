import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/widgets/workout/set_list_item.dart';

class ExerciseInWorkoutListSection extends StatelessWidget {
  final ExerciseInWorkoutDto exerciseInWorkoutDto;
  final ExerciseInWorkoutDto? otherExerciseInWorkoutDto;

  /// Exercise callbacks
  final void Function(String value) onUpdateNotes;
  final void Function() onRemoveExercise;
  final void Function() onAddSuperSetExercises;
  final void Function(String superSetId) onRemoveSuperSetExercises;

  /// Set callbacks
  final void Function() onAddWorkingSet;
  final void Function(int index) onRemoveWorkingSet;
  final void Function() onAddWarmUpSet;
  final void Function(int index) onRemoveWarmUpSet;

  /// Set values callbacks
  final void Function(int exerciseIndex, int value) onChangedWorkingSetRepCount;
  final void Function(int exerciseIndex, int value) onChangedWorkingSetWeight;
  final void Function(int exerciseIndex, int value) onChangedWarmUpSetRepCount;
  final void Function(int exerciseIndex, int value) onChangedWarmUpSetWeight;

  const ExerciseInWorkoutListSection({
    super.key,
    required this.exerciseInWorkoutDto,
    required this.otherExerciseInWorkoutDto,
    required this.onAddSuperSetExercises,
    required this.onRemoveSuperSetExercises,
    required this.onRemoveExercise,
    required this.onChangedWorkingSetRepCount,
    required this.onChangedWorkingSetWeight,
    required this.onChangedWarmUpSetRepCount,
    required this.onChangedWarmUpSetWeight,
    required this.onAddWorkingSet,
    required this.onRemoveWorkingSet,
    required this.onAddWarmUpSet,
    required this.onRemoveWarmUpSet,
    required this.onUpdateNotes,
  });

  /// Show [CupertinoActionSheet]
  void _showExerciseInWorkoutActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onAddWorkingSet();
            },
            child: const Text('Add new set', style: TextStyle(fontSize: 18)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onAddWarmUpSet();
            },
            child:
                const Text('Add warm-up set', style: TextStyle(fontSize: 18)),
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
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    onAddSuperSetExercises();
                  },
                  child: Text(
                    'Super set ${exerciseInWorkoutDto.exercise.name} with ...',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onRemoveExercise();
            },
            child: Text('Remove ${exerciseInWorkoutDto.exercise.name}',
                style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  List<SetListItem> _displayWorkingSets() {
    return exerciseInWorkoutDto.workingProcedures
        .mapIndexed(((index, procedure) => SetListItem(
              index: index,
              onRemoved: (int index) => onRemoveWorkingSet(index),
              isWarmup: false,
              exerciseInWorkoutDto: exerciseInWorkoutDto,
              procedureDto: procedure,
              onChangedRepCount: (int value) =>
                  onChangedWorkingSetRepCount(index, value),
              onChangedWeight: (int value) =>
                  onChangedWorkingSetWeight(index, value),
            )))
        .toList();
  }

  List<SetListItem> _displayWarmUpSets() {
    return exerciseInWorkoutDto.warmupProcedures
        .mapIndexed(((index, procedure) => SetListItem(
              index: index,
              onRemoved: (int index) => onRemoveWarmUpSet(index),
              isWarmup: true,
              exerciseInWorkoutDto: exerciseInWorkoutDto,
              procedureDto: procedure,
              onChangedRepCount: (int value) =>
                  onChangedWarmUpSetRepCount(index, value),
              onChangedWeight: (int value) =>
                  onChangedWarmUpSetWeight(index, value),
            )))
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
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              subtitle: exerciseInWorkoutDto.isSuperSet
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                          "Super set: ${otherExerciseInWorkoutDto?.exercise.name}",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
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
              controller:
                  TextEditingController(text: exerciseInWorkoutDto.notes),
              onChanged: (value) => onUpdateNotes(value),
              expands: true,
              decoration: const BoxDecoration(color: Colors.transparent),
              padding: EdgeInsets.zero,
              keyboardType: TextInputType.text,
              maxLength: 240,
              maxLines: null,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white.withOpacity(0.8)),
              placeholder: "Enter notes",
              placeholderStyle: const TextStyle(
                  color: CupertinoColors.inactiveGray, fontSize: 14),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
        children: [
          ..._displayWarmUpSets(),
          ..._displayWorkingSets(),
        ]);
  }
}
