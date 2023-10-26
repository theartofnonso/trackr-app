import 'package:flutter/material.dart';

import '../../screens/exercise_library_screen.dart';

class SelectableExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function(bool selected) onTap;

  const SelectableExerciseWidget({super.key, required this.exerciseInLibraryDto, required this.onTap});

  void _onTap() {
    final isSelected = !exerciseInLibraryDto.selected;
    onTap(isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
      ),
      child: CheckboxListTile(
        value: exerciseInLibraryDto.selected,
        onChanged: (bool? _) => _onTap(),
        activeColor: Colors.white,
        checkColor: Colors.black,
        hoverColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(exerciseInLibraryDto.exercise.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 300,
                child: Text(
                  "Primary: ${exerciseInLibraryDto.exercise.primary.join(", ")}",
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                )),
            const SizedBox(height: 5),
            SizedBox(
                width: 300,
                child: Text(
                  "Secondary: ${exerciseInLibraryDto.exercise.secondary.isNotEmpty ? exerciseInLibraryDto.exercise.secondary.join(", ") : "None"}",
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                )),
          ],
        ),
      ),
    );
  }
}
