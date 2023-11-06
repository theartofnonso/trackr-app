import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';

import '../../screens/exercise/exercise_history_screen.dart';
import '../../screens/exercise/exercise_library_screen.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function() onTap;

  const ExerciseWidget({super.key, required this.exerciseInLibraryDto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: tealBlueLight
      ),
      child: ListTile(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ExerciseHistoryScreen(exerciseId: exerciseInLibraryDto.exercise.id)));
          },
          icon: const Icon(
            Icons.timeline_rounded,
            color: Colors.white,
          ),
        ),
          title: Text(exerciseInLibraryDto.exercise.name, style: Theme.of(context).textTheme.bodyMedium),
          onTap: onTap,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 300,
                  child: Text(
                    "Primary: ${exerciseInLibraryDto.exercise.primaryMuscle.name}",
                    style: GoogleFonts.lato(
                        color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                  )),
              SizedBox(
                  width: 300,
                  child: Text(
                    "Secondary: ${exerciseInLibraryDto.exercise.secondaryMuscles.isNotEmpty ? exerciseInLibraryDto.exercise.secondaryMuscles.join(", ") : "None"}",
                    style: GoogleFonts.lato(
                        color: Colors.white70).copyWith(overflow: TextOverflow.ellipsis),
                  )),
            ],
          )),
    );
  }
}
