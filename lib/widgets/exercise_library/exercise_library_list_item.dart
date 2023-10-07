import 'package:flutter/cupertino.dart';

import '../../dtos/exercise_in_library_dto.dart';

class ExerciseLibraryListItem extends StatefulWidget {
  final ExerciseInLibraryDto exerciseItem;
  final void Function(bool) onTap;

  const ExerciseLibraryListItem(
      {super.key, required this.exerciseItem, required this.onTap});

  @override
  State<ExerciseLibraryListItem> createState() => _ExerciseLibraryListItemState();
}

class _ExerciseLibraryListItemState extends State<ExerciseLibraryListItem> {

  bool _isSelected = false;

  void _onSelect() {
    final isSelected = !_isSelected;
        setState(() {
      _isSelected = isSelected;
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
            onChanged: (bool? _) => _onSelect(),
          ),
          title:
              Text(widget.exerciseItem.exercise.name)),
    );
  }

  @override
  void initState() {
    super.initState();
    final isSelected = widget.exerciseItem.isSelected;
    _isSelected = isSelected ?? false;
  }
}
