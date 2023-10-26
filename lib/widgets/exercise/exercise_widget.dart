import 'package:flutter/material.dart';

import '../../screens/exercise_library_screen.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function() onTap;

  const ExerciseWidget({super.key, required this.exerciseInLibraryDto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(exerciseInLibraryDto.exercise.name, style: Theme.of(context).textTheme.bodyMedium),
        onTap: onTap,
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
        ));
  }
}
