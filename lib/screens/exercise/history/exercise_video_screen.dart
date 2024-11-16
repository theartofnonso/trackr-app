import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/utils/uri_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../dtos/exercise_dto.dart';

class ExerciseVideoScreen extends StatelessWidget {
  final ExerciseDTO exercise;

  const ExerciseVideoScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final video = "";
    final videoUrl = video != null ? video.toString() : "";
    final videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? "";

    final creditSource = "";

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: true,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
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
              style: GoogleFonts.ubuntu(
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
                  text: "",
                  style: GoogleFonts.ubuntu(
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
      ),
    );
  }
}
