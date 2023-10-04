import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

class ExerciseListItem extends StatefulWidget {

  final Exercise exercise;
  final void Function(bool) onSelect;

  const ExerciseListItem({super.key, required this.exercise, required this.onSelect});

  @override
  State<ExerciseListItem> createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {

  bool _isSelected = false;

  final _listTileStyle = const TextStyle(color: CupertinoColors.white);

  void _onSelect(bool value) {
    _isSelected = value == true;
      setState(() {
        _isSelected = _isSelected;
      });
      widget.onSelect(_isSelected);
  }

  void _onChanged(bool? value) {
    if(value != null) {
      _onSelect(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile.adaptive(value: _isSelected, onChanged: (bool? value) => _onChanged(value), title: Text(widget.exercise.name, style: _listTileStyle), controlAffinity: ListTileControlAffinity.leading,);
  }
}
