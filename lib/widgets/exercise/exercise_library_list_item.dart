import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_constants.dart';
import '../../screens/exercise_library_screen.dart';

class ExrLibraryListItem extends StatelessWidget {
  final ExerciseInLibraryDto exercise;
  final void Function() onTap;

  const ExrLibraryListItem(
      {super.key, required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CupertinoListTile.notched(
          backgroundColor: tealBlueLight, title: Text(exercise.exercise.name, style: Theme.of(context).textTheme.bodyMedium)),
    );
  }
}
