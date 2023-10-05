import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

class ExerciseListItem extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool) onTap;

  const ExerciseListItem(
      {super.key, required this.exercise, required this.onTap});

  @override
  State<ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {
  bool _isSelected = false;

  final _listTileStyle = const TextStyle(color: CupertinoColors.white);

  void _onSelect() {
    _isSelected = !_isSelected;
    setState(() {
      _isSelected = _isSelected;
    });
    widget.onTap(_isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onSelect,
      child: CupertinoListTile.notched(
          backgroundColor: const Color.fromRGBO(25, 28, 36, 1),
          leading: CupertinoCheckbox(
            value: _isSelected,
            onChanged: (bool? value) {},
          ),
          title: Text(widget.exercise.name, style: _listTileStyle)),
    );
  }
}
