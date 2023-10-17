import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app_constants.dart';
import '../../../dtos/procedure_dto.dart';

class ReOrderExercisesInWorkoutEditor extends StatefulWidget {
  final List<ProcedureDto> exercises;

  const ReOrderExercisesInWorkoutEditor({super.key, required this.exercises});

  @override
  State<ReOrderExercisesInWorkoutEditor> createState() => _ReOrderExercisesInWorkoutEditorState();
}

class _ReOrderExercisesInWorkoutEditorState extends State<ReOrderExercisesInWorkoutEditor> {
  bool _hasReOrdered = false;
  late List<ProcedureDto> _reOrderedExercises;

  void _reOrderExercises({required int oldIndex, required int newIndex}) {
    setState(() {
      _hasReOrdered = true;

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ProcedureDto item = _reOrderedExercises.removeAt(oldIndex);
      _reOrderedExercises.insert(newIndex, item);
    });
  }

  List<Widget> _exerciseToListTile() {
    return _reOrderedExercises
        .mapIndexed((index, exercise) => CupertinoListTile(
              key: Key("$index"),
              title: Text(exercise.exercise.name, style: Theme.of(context).textTheme.bodyLarge),
              trailing: const Icon(
                CupertinoIcons.bars,
                color: CupertinoColors.white,
              ),
            ))
        .toList();
  }

  /// Navigate to previous screen
  void _saveReOrdering() {
    Navigator.of(context).pop(_reOrderedExercises);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: tealBlueDark,
        middle: const Text(
          "Reorder",
          style: TextStyle(color: CupertinoColors.white),
        ),
        trailing: GestureDetector(
            onTap: _saveReOrdering,
            child: _hasReOrdered
                ? const Text(
                    "Save",
                    style: TextStyle(color: CupertinoColors.white),
                  )
                : const SizedBox.shrink()),
      ),
      child: ReorderableListView(
          children: _exerciseToListTile(),
          onReorder: (int oldIndex, int newIndex) => _reOrderExercises(oldIndex: oldIndex, newIndex: newIndex)),
    );
  }

  @override
  void initState() {
    super.initState();
    _reOrderedExercises = widget.exercises;
  }
}
