import 'package:flutter/material.dart';

import '../../screens/exercise_library_screen.dart';

class ExrLibraryListItem extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibrary;
  final void Function() onTap;

  const ExrLibraryListItem({super.key, required this.exerciseInLibrary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(exerciseInLibrary.exercise.name, style: Theme.of(context).textTheme.bodyMedium),
        onTap: onTap,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 300,
                child: Text(
                  "Primary: ${exerciseInLibrary.exercise.primary.join(", ")}",
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                )),
            const SizedBox(height: 5),
            SizedBox(
                width: 300,
                child: Text(
                  "Secondary: ${exerciseInLibrary.exercise.secondary.isNotEmpty ? exerciseInLibrary.exercise.secondary.join(", ") : "None"}",
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                )),
          ],
        ));
  }
}
