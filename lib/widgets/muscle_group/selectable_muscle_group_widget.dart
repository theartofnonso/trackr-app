import 'package:flutter/material.dart';
import '../../app_constants.dart';
import '../../screens/exercise/muscle_groups_screen.dart';

class SelectableMuscleGroupWidget extends StatelessWidget {
  final MuscleGroupDto muscleGroupDto;
  final void Function(bool selected) onTap;

  const SelectableMuscleGroupWidget({super.key, required this.muscleGroupDto, required this.onTap});

  void _onTap() {
    final isSelected = !muscleGroupDto.selected;
    onTap(isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
      ),
      child: ListTile(
        onTap: _onTap,
        tileColor: tealBlueLight,
        dense: true,
        title: Text(muscleGroupDto.muscleGroup.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        trailing: muscleGroupDto.selected
            ? const Icon(Icons.check_box_rounded, color: Colors.green)
            : Icon(Icons.check_box_rounded, color: Colors.grey.shade800),
      ),
    );
  }
}
