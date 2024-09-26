import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../screens/exercise/library/exercise_library_screen.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseInLibraryDto exerciseInLibraryDto;
  final void Function(ExerciseInLibraryDto exerciseInLibraryDto)? onSelect;
  final void Function(ExerciseInLibraryDto exerciseInLibraryDto)? onNavigateToExercise;

  const ExerciseWidget(
      {super.key, required this.exerciseInLibraryDto, required this.onSelect, required this.onNavigateToExercise});

  @override
  Widget build(BuildContext context) {
    final selectExercise = onSelect;
    final navigateToExercise = onNavigateToExercise;

    final exercise = exerciseInLibraryDto.exercise;
    final video = exercise.video;
    final videoUrl = video != null ? video.toString() : "";
    final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? "";

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: true,
      ),
    );

    return GestureDetector(
      onTap: () => navigateToExercise != null ? navigateToExercise(exerciseInLibraryDto) : null,
      child: Theme(
          data: ThemeData(splashColor: sapphireLight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: YoutubePlayer(
                  controller: controller,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name,
                        style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(exercise.description ?? "No Description",
                        style: GoogleFonts.montserrat(
                            color: Colors.white70, height: 1.8, fontWeight: FontWeight.w400, fontSize: 14)),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(exercise.primaryMuscleGroup.name.toUpperCase(),
                        style: GoogleFonts.montserrat(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 14)),

                  ],
                ),
              ),
            ],
          )),
    );
  }
}
