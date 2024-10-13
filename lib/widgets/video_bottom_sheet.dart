import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoBottomSheet extends StatelessWidget {
  final String url;

  const VideoBottomSheet({super.key, required this.url});

  @override
  Widget build(BuildContext context) {

    final videoId = YoutubePlayer.convertUrlToId(url) ?? "";

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
        ]),
      ),
    );
  }
}
