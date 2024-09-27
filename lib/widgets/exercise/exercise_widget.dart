import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../dtos/exercise_dto.dart';

class ExerciseWidget extends StatelessWidget {
  final ExerciseDto exerciseDto;
  final void Function(ExerciseDto exerciseInLibraryDto)? onSelect;
  final void Function(ExerciseDto exerciseInLibraryDto)? onNavigateToExercise;

  const ExerciseWidget(
      {super.key, required this.exerciseDto, required this.onSelect, required this.onNavigateToExercise});

  @override
  Widget build(BuildContext context) {
    final selectExercise = onSelect;
    final navigateToExercise = onNavigateToExercise;

    final exercise = exerciseDto;
    final video = exercise.video;
    final videoUrl = video != null ? video.toString() : "";
    final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? "";

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        loop: true,
        disableDragSeek: true,
        showLiveFullscreenButton: false,
        enableCaption: false,
        mute: true,
      ),
    );

    final description = exercise.description ?? "";

    return Stack(children: [
      Column(
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
          GestureDetector(
            onTap: () => selectExercise != null ? selectExercise(exerciseDto) : null,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                      style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  if (description.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(description,
                            style: GoogleFonts.montserrat(
                                color: Colors.white70, height: 1.8, fontWeight: FontWeight.w400, fontSize: 14)),
                      ],
                    ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(exercise.primaryMuscleGroup.name.toUpperCase(),
                      style: GoogleFonts.montserrat(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      Positioned(
          top: 10,
          right: 20,
          child: GestureDetector(
              onTap: () => navigateToExercise != null ? navigateToExercise(exerciseDto) : null,
              child: const FaIcon(
                FontAwesomeIcons.circleArrowRight,
                color: Colors.white,
              )))
    ]);
  }
}
