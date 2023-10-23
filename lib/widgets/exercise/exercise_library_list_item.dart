import 'package:flutter/material.dart';

import '../../screens/exercise_library_screen.dart';

class ExrLibraryListItem extends StatelessWidget {
  final ExerciseInLibraryDto exercise;
  final void Function() onTap;

  const ExrLibraryListItem({super.key, required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(exercise.exercise.name, style: Theme.of(context).textTheme.bodyMedium), onTap: onTap);
  }
}
