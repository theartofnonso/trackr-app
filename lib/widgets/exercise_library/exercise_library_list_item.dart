import 'package:flutter/cupertino.dart';

import '../../app_constants.dart';
import '../../dtos/exercise_in_library_dto.dart';

class ExerciseLibraryListItem extends StatefulWidget {
  final ExerciseInLibraryDto exercise;
  final void Function(bool isSelected) onTap;

  const ExerciseLibraryListItem(
      {super.key, required this.exercise, required this.onTap});

  @override
  State<ExerciseLibraryListItem> createState() => _ExerciseLibraryListItemState();
}

class _ExerciseLibraryListItemState extends State<ExerciseLibraryListItem> {

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
    return GestureDetector(
      onTap: _selectExercise,
      child: CupertinoListTile.notched(
          backgroundColor: tealBlueLight,
          leading: CupertinoCheckbox(
            value: _isSelected,
            onChanged: (bool? _) => _selectExercise(),
          ),
          title:
              Text(widget.exercise.exercise.name)),
    );
  }

  @override
  void initState() {
    super.initState();
    _isSelected = widget.exercise.isSelected ?? false;
  }
}
