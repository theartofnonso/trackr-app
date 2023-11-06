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
      child: CheckboxListTile(
          value: muscleGroupDto.selected,
          onChanged: (bool? _) => _onTap(),
          tileColor: tealBlueLight,
          activeColor: Colors.white,
          checkColor: Colors.black,
          hoverColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(muscleGroupDto.bodyPart.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
    );
  }
}
