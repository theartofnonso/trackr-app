import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/widgets/workout/set_list_item.dart';

import '../../providers/exercise_in_workout_provider.dart';

class ExerciseInWorkoutListSection extends StatefulWidget {
  final ExerciseInWorkoutDto exerciseInWorkoutDto;
  final void Function(ExerciseInWorkoutDto firstSuperSetExercise)
      onAddSuperSetExercises;
  final void Function(String superSetId) onRemoveSuperSetExercises;
  final void Function(ExerciseInWorkoutDto exerciseInWorkoutDto)
      onRemoveExerciseInWorkout;

  const ExerciseInWorkoutListSection({
    super.key,
    required this.exerciseInWorkoutDto,
    required this.onAddSuperSetExercises,
    required this.onRemoveSuperSetExercises,
    required this.onRemoveExerciseInWorkout,
  });

  @override
  State<ExerciseInWorkoutListSection> createState() =>
      _ExerciseInWorkoutListSectionState();
}

class _ExerciseInWorkoutListSectionState
    extends State<ExerciseInWorkoutListSection> {
  /// Show [CupertinoActionSheet]
  void _showExerciseInWorkoutActionSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _addWorkingSet();
            },
            child: const Text('Add new set', style: TextStyle(fontSize: 18)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _addWarmupSet();
            },
            child:
                const Text('Add warm-up set', style: TextStyle(fontSize: 18)),
          ),
          widget.exerciseInWorkoutDto.isSuperSet
              ? CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onRemoveSuperSetExercises(
                        widget.exerciseInWorkoutDto.superSetId);
                  },
                  child: const Text(
                    'Remove super set',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    _markAsSuperSet();
                  },
                  child: Text(
                    'Super set ${widget.exerciseInWorkoutDto.exercise.name} with ...',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              widget.onRemoveExerciseInWorkout(widget.exerciseInWorkoutDto);
            },
            child: Text('Remove ${widget.exerciseInWorkoutDto.exercise.name}',
                style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  /// Add new [SetListItem] to list [_workingSetItems]
  void _addWorkingSet() {
    Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
        .addWorkingSet(exerciseInWorkout: widget.exerciseInWorkoutDto);
  }

  /// Remove [SetListItem] from [_workingSetItems]
  void _removeWorkingSet({required int index}) {
    Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
        .removeWorkingSet(
            exerciseInWorkout: widget.exerciseInWorkoutDto, index: index);
  }

  /// Add new [SetListItem] to list [_warmupItems]
  void _addWarmupSet() {
    Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
        .addWarmupSet(exerciseInWorkout: widget.exerciseInWorkoutDto);
  }

  /// Remove [SetListItem] from [_warmupItems]
  void _removeWarmupSet({required int index}) {
    Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
        .removeWarmupSet(
            exerciseInWorkout: widget.exerciseInWorkoutDto, index: index);
  }

  /// Mark [ExerciseInWorkoutDto] as superset
  void _markAsSuperSet() {
    widget.onAddSuperSetExercises(widget.exerciseInWorkoutDto);
  }

  /// Find [ExerciseInWorkoutDto] in list of [widget.exercisesInWorkoutDtos]
  ExerciseInWorkoutDto _whereOtherSuperSet() {
    return Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
        .whereOtherSuperSet(firstExercise: widget.exerciseInWorkoutDto);
  }

  List<SetListItem> _workingSets() {
    return widget.exerciseInWorkoutDto.workingProcedures
        .mapIndexed(((index, procedure) => SetListItem(
              index: index,
              onRemove: (int index) => _removeWorkingSet(index: index),
              isWarmup: false,
              exerciseInWorkoutDto: widget.exerciseInWorkoutDto,
              procedureDto: procedure,
            )))
        .toList();
  }

  List<SetListItem> _warmupSets() {
    return widget.exerciseInWorkoutDto.warmupProcedures
        .mapIndexed(((index, procedure) => SetListItem(
              index: index,
              onRemove: (int index) => _removeWarmupSet(index: index),
              isWarmup: true,
              exerciseInWorkoutDto: widget.exerciseInWorkoutDto,
              procedureDto: procedure,
            )))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: Colors.transparent,
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoListTile(
              padding: EdgeInsets.zero,
              title: Text(widget.exerciseInWorkoutDto.exercise.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              subtitle: widget.exerciseInWorkoutDto.isSuperSet
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                          "Super set: ${_whereOtherSuperSet().exercise.name}",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    )
                  : const SizedBox.shrink(),
              trailing: GestureDetector(
                  onTap: _showExerciseInWorkoutActionSheet,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 1.0),
                    child: Icon(CupertinoIcons.ellipsis),
                  )),
            ),
            CupertinoTextField(
              controller: TextEditingController(text: widget.exerciseInWorkoutDto.notes),
              onChanged: (value) =>
                  Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                      .updateNotes(
                          exerciseInWorkout: widget.exerciseInWorkoutDto,
                          notes: value),
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
          ..._warmupSets(),
          ..._workingSets(),
        ]);
  }
}
