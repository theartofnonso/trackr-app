import 'package:flutter/material.dart';

import '../../screens/exercise_library_screen.dart';

class SelectableExrLibraryListItem extends StatefulWidget {
  final ExerciseInLibraryDto exerciseInLibrary;
  final void Function(bool isSelected) onTap;

  const SelectableExrLibraryListItem({super.key, required this.exerciseInLibrary, required this.onTap});

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
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
      ),
      child: CheckboxListTile(
        value: _isSelected,
        onChanged: (bool? _) => _selectExercise(),
        activeColor: Colors.white,
        checkColor: Colors.black,
        hoverColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(widget.exerciseInLibrary.exercise.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Primary: ${widget.exerciseInLibrary.exercise.primary.join(", ")}", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),),
            const SizedBox(height: 5),
            Text("Secondary: ${widget.exerciseInLibrary.exercise.secondary.join(", ")}", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isSelected = widget.exerciseInLibrary.isSelected ?? false;
  }
}
