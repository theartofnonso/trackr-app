import 'package:flutter/cupertino.dart';

import '../../app_constants.dart';
import '../../dtos/exercise_in_library_dto.dart';

class SelectableExrLibraryListItem extends StatefulWidget {
  final ExerciseInLibraryDto exercise;
  final void Function(bool isSelected) onTap;

  const SelectableExrLibraryListItem(
      {super.key, required this.exercise, required this.onTap});

  @override
  State<SelectableExrLibraryListItem> createState() =>
      _SelectableExrLibraryListItemState();
}

class _SelectableExrLibraryListItemState
    extends State<SelectableExrLibraryListItem> {
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
          title: Text(widget.exercise.exercise.name)),
    );
  }

  @override
  void initState() {
    super.initState();
    _isSelected = widget.exercise.isSelected ?? false;
  }
}
