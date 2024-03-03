import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/utils/uri_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../dtos/exercise_dto.dart';

class ExerciseVideoScreen extends StatelessWidget {
  final ExerciseDto exercise;

  const ExerciseVideoScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final video = exercise.video;
    final videoUrl = video != null ? video.toString() : "";
    final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? "";

    final creditSource = exercise.creditSource;

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: YoutubePlayer(
            controller: controller,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        RichText(
          text: TextSpan(
            text: "Video by",
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            children: <TextSpan>[
              const TextSpan(text: " "),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (creditSource != null) {
                      openUrl(url: creditSource.toString(), context: context);
                    }
                  },
                text: exercise.credit ?? "",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
