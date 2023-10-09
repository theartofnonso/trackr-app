import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/widgets/workout/set_list_item.dart';

import '../../providers/exercise_in_workout_provider.dart';

class ExerciseInWorkoutListSection extends StatefulWidget {
  final int index;
  final Key keyValue;
  final ExerciseInWorkoutDto exerciseInWorkoutDto;
  final void Function(ExerciseInWorkoutDto firstSuperSetExercise)
      onAddSuperSetExercises;
  final void Function(String superSetId) onRemoveSuperSetExercises;
  final void Function(ExerciseInWorkoutDto exerciseInWorkoutDto)
      onRemoveExerciseInWorkout;

  const ExerciseInWorkoutListSection({
    required this.index,
    required this.exerciseInWorkoutDto,
    required this.onAddSuperSetExercises,
    required this.onRemoveSuperSetExercises,
    required this.onRemoveExerciseInWorkout,
    required this.keyValue,
  }) : super(key: keyValue);

  @override
  State<ExerciseInWorkoutListSection> createState() =>
      _ExerciseInWorkoutListSectionState();
}

class _ExerciseInWorkoutListSectionState
    extends State<ExerciseInWorkoutListSection> {
  List<SetListItem> _warmupSetItems = [];
  List<SetListItem> _workingSetItems = [];
  final List<TextEditingController> _warmupSetRepsControllers = [];
  final List<TextEditingController> _warmupSetWeightControllers = [];
  final List<TextEditingController> _workingSetRepsControllers = [];
  final List<TextEditingController> _workingSetWeightControllers = [];

  /// Show [CupertinoActionSheet]
  void _showExerciseInWorkoutActionSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _addNewSetListItem();
              });
            },
            child: const Text('Add new set', style: TextStyle(fontSize: 18)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _addNewWarmupSetListItem();
              });
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
  void _addNewSetListItem() {
    final repsController = TextEditingController();
    final setsController = TextEditingController();
    final setItem = SetListItem(
      index: _workingSetItems.length,
      onRemove: (int index) {
        if (_workingSetItems.isNotEmpty) {
          _removeSetListItem(index: index);
        }
      },
      repsController: repsController,
      weightController: setsController,
      isWarmup: false,
    );
    _workingSetItems.add(setItem);
    _workingSetRepsControllers.add(repsController);
    _workingSetWeightControllers.add(setsController);

    Provider.of<ExerciseInWorkoutProvider>(context, listen: false).addNewWorkingSet(exerciseInWorkout: widget.exerciseInWorkoutDto);
  }

  /// Remove [SetListItem] from [_workingSetItems]
  void _removeSetListItem({required int index}) {
    setState(() {
      _workingSetItems.removeAt(index);
      _workingSetItems = _workingSetItems.mapIndexed((index, item) {
        return SetListItem(
          index: index,
          onRemove: item.onRemove,
          repsController: item.repsController,
          weightController: item.weightController,
          isWarmup: item.isWarmup,
        );
      }).toList();

      _workingSetRepsControllers.removeAt(index);
      _workingSetWeightControllers.removeAt(index);
    });

    Provider.of<ExerciseInWorkoutProvider>(context, listen: false).removeWorkingSet(exerciseInWorkout: widget.exerciseInWorkoutDto, index: index);
  }

  /// Add new [SetListItem] to list [_warmupItems]
  void _addNewWarmupSetListItem() {
    final repsController = TextEditingController();
    final setsController = TextEditingController();
    final setItem = SetListItem(
      index: _warmupSetItems.length,
      isWarmup: true,
      onRemove: (int index) => removeWarmupSetListItem(index: index),
      repsController: repsController,
      weightController: setsController,
    );
    _warmupSetItems.add(setItem);
    _warmupSetRepsControllers.add(repsController);
    _warmupSetWeightControllers.add(setsController);

    Provider.of<ExerciseInWorkoutProvider>(context, listen: false).addNewWarmupSet(exerciseInWorkout: widget.exerciseInWorkoutDto);
  }

  /// Remove [SetListItem] from [_warmupItems]
  void removeWarmupSetListItem({required int index}) {
    setState(() {
      _warmupSetItems.removeAt(index);
      _warmupSetItems = _warmupSetItems.mapIndexed((index, item) {
        return SetListItem(
          index: index,
          onRemove: item.onRemove,
          repsController: item.repsController,
          weightController: item.weightController,
          isWarmup: item.isWarmup,
        );
      }).toList();

      _warmupSetRepsControllers.removeAt(index);
      _warmupSetWeightControllers.removeAt(index);
    });

    Provider.of<ExerciseInWorkoutProvider>(context, listen: false).removeWarmupSet(exerciseInWorkout: widget.exerciseInWorkoutDto, index: index);
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

  @override
  Widget build(BuildContext context) {

    return CupertinoListSection.insetGrouped(
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
            trailing: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                  onTap: _showExerciseInWorkoutActionSheet,
                  child: const Icon(CupertinoIcons.ellipsis)),
            ),
          ),
          CupertinoTextField(
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
      children: [..._warmupSetItems, ..._workingSetItems],
    );
  }

  @override
  void initState() {
    super.initState();
    _addNewSetListItem();
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _warmupSetRepsControllers) {
      controller.dispose();
    }
    for (var controller in _warmupSetWeightControllers) {
      controller.dispose();
    }
    for (var controller in _workingSetRepsControllers) {
      controller.dispose();
    }
    for (var controller in _workingSetWeightControllers) {
      controller.dispose();
    }
  }
}
