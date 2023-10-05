import 'package:flutter/cupertino.dart';

import 'exercise_item.dart';

class ExerciseListItem extends StatefulWidget {
  final ExerciseItem exerciseItem;
  final void Function(bool) onTap;

  const ExerciseListItem(
      {super.key, required this.exerciseItem, required this.onTap});

  @override
  State<ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {

  void _onSelect() {
    widget.onTap(!widget.exerciseItem.isSelected!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onSelect,
      child: CupertinoListTile.notched(
          backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
          leading: CupertinoCheckbox(
            value: widget.exerciseItem.isSelected,
            onChanged: (bool? value) {},
          ),
          title:
              Text(widget.exerciseItem.exercise.name)),
    );
  }
}
