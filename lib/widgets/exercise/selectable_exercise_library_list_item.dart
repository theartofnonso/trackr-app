import 'package:flutter/material.dart';

import '../../screens/exercise_library_screen.dart';

class SelectableExrLibraryListItem extends StatefulWidget {
  final ExerciseInLibraryDto exercise;
  final void Function(bool isSelected) onTap;

  const SelectableExrLibraryListItem({super.key, required this.exercise, required this.onTap});

  @override
  State<SelectableExrLibraryListItem> createState() => _SelectableExrLibraryListItemState();
}

class _SelectableExrLibraryListItemState extends State<SelectableExrLibraryListItem> {
  bool _isSelected = false;

  /// Select an exercise
  void _selectExercise() {
    final isSelected = !_isSelected;
    setState(() {
      _isSelected = isSelected;
    });
    widget.onTap(_isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: _isSelected,
      onChanged: (bool? _) => _selectExercise(),
      activeColor: Colors.white,
      checkColor: Colors.black,
      hoverColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(widget.exercise.exercise.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
    );
  }

  @override
  void initState() {
    super.initState();
    _isSelected = widget.exercise.isSelected ?? false;
  }
}
