import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/widgets/workout/set_list_item.dart';

class ExerciseInWorkoutListSection extends StatefulWidget {
  final int index;
  final ExerciseInWorkoutDto exerciseInWorkoutDto;
  final List<ExerciseInWorkoutDto> exercisesInWorkoutDtos;
  final void Function(ExerciseInWorkoutDto firstSuperSetExercise)
      onAddSuperSetExercises;
  final void Function(String superSetId) onRemoveSuperSetExercises;
  final void Function(ExerciseInWorkoutDto exerciseInWorkoutDto)
      onRemoveExerciseInWorkout;

  const ExerciseInWorkoutListSection(
      {super.key,
      required this.index,
      required this.exerciseInWorkoutDto,
      required this.onAddSuperSetExercises,
      required this.exercisesInWorkoutDtos,
      required this.onRemoveSuperSetExercises,
      required this.onRemoveExerciseInWorkout});

  @override
  State<ExerciseInWorkoutListSection> createState() =>
      _ExerciseInWorkoutListSectionState();
}

class _ExerciseInWorkoutListSectionState
    extends State<ExerciseInWorkoutListSection> {
  List<SetListItem> _warmupSetItems = [];
  List<SetListItem> _setItems = [];
  final List<TextEditingController> _warmupSetRepsController = [];
  final List<TextEditingController> _warmupSetWeightController = [];
  final List<TextEditingController> _setRepsController = [];
  final List<TextEditingController> _setWeightController = [];

  void _removeSetListItem({required int index}) {
    setState(() {
      _setItems.removeAt(index);
      _setItems = _setItems.mapIndexed((index, item) {
        return SetListItem(
          index: index,
          leadingColor: item.leadingColor,
          onRemove: item.onRemove,
          repsController: item.repsController,
          weightController: item.weightController,
          isWarmup: item.isWarmup,
        );
      }).toList();

      _setRepsController.removeAt(index);
      _setWeightController.removeAt(index);
    });
  }

  void removeWarmupSetListItem({required int index}) {
    setState(() {
      _warmupSetItems.removeAt(index);
      _warmupSetItems = _warmupSetItems.mapIndexed((index, item) {
        return SetListItem(
          index: index,
          leadingColor: item.leadingColor,
          onRemove: item.onRemove,
          repsController: item.repsController,
          weightController: item.weightController,
          isWarmup: item.isWarmup,
        );
      }).toList();

      _warmupSetRepsController.removeAt(index);
      _warmupSetWeightController.removeAt(index);
    });
  }

  void _showProcedureActionSheet({required BuildContext context}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _createNewSetListItem();
              });
            },
            child: const Text('Add new set', style: TextStyle(fontSize: 18)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _createNewWarmupSetListItem();
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

  void _createNewSetListItem() {
    final repsController = TextEditingController();
    final setsController = TextEditingController();
    final setItem = SetListItem(
      index: _setItems.length,
      leadingColor: CupertinoColors.activeBlue,
      onRemove: (int index) {
        if (_setItems.isNotEmpty) {
          _removeSetListItem(index: index);
        }
      },
      repsController: repsController,
      weightController: setsController,
      isWarmup: false,
    );
    _setItems.add(setItem);
    _setRepsController.add(repsController);
    _setWeightController.add(setsController);
  }

  void _createNewWarmupSetListItem() {
    final repsController = TextEditingController();
    final setsController = TextEditingController();
    final setItem = SetListItem(
      index: _warmupSetItems.length,
      isWarmup: true,
      leadingColor: CupertinoColors.activeOrange,
      onRemove: (int index) => removeWarmupSetListItem(index: index),
      repsController: repsController,
      weightController: setsController,
    );
    _warmupSetItems.add(setItem);
    _warmupSetRepsController.add(repsController);
    _warmupSetWeightController.add(setsController);
  }

  void _markAsSuperSet() {
    widget.onAddSuperSetExercises(widget.exerciseInWorkoutDto);
  }

  ExerciseInWorkoutDto _whereExerciseSuperSet() {
    return widget.exercisesInWorkoutDtos.firstWhere((exerciseInWorkout) {
      return exerciseInWorkout.superSetId ==
              widget.exerciseInWorkoutDto.superSetId &&
          exerciseInWorkout.exercise != widget.exerciseInWorkoutDto.exercise;
    });
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
                        "Super set: ${_whereExerciseSuperSet().exercise.name}",
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  )
                : const SizedBox.shrink(),
            trailing: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GestureDetector(
                  onTap: () => _showProcedureActionSheet(context: context),
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
      children: [..._warmupSetItems, ..._setItems],
    );
  }

  @override
  void initState() {
    super.initState();
    _createNewSetListItem();
  }
}
