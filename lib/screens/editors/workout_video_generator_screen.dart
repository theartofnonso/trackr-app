import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../utils/general_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';

class WorkoutVideoGeneratorScreen extends StatefulWidget {

  final String? workoutVideoUrl;

  const WorkoutVideoGeneratorScreen({super.key, this.workoutVideoUrl});

  @override
  State<WorkoutVideoGeneratorScreen> createState() => _WorkoutVideoGeneratorScreenState();
}

class _WorkoutVideoGeneratorScreenState extends State<WorkoutVideoGeneratorScreen> {
  final yt = YoutubeExplode();

  late TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.squareXmark,
            size: 28,
          ),
          onPressed: context.pop,
        ),
        title: Text("Create a guided session".toUpperCase()),
        centerTitle: true,
      ),
      body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
              minimum: const EdgeInsets.all(10.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Take your strength training to the next level",
                      textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.5)),
                  Text(
                      "Let TRKR do the work for you—upload a Youtube video, and we’ll analyze it to automatically identify the exercises, making tracking seamless.",
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14, height: 1.8)),
                  const SizedBox(height: 2),
                  TextField(
                    controller: _textEditingController,
                    cursorColor: isDarkMode ? Colors.white : Colors.black,
                    decoration: InputDecoration(
                      hintText: "Paste a link to a workout video",
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OpacityButtonWidget(
                        onPressed: _generate,
                        label: "Create guided session",
                        buttonColor: vibrantGreen,
                        padding: const EdgeInsets.all(10.0)),
                  )
                ],
              ))),
    );
  }

  void _generate() async {
    final url = _textEditingController.text.trim();

    final isValidUrl = _isYouTubeUrl(url: url);

    if (!isValidUrl) {
      showSnackbar(
          context: context, icon: FaIcon(FontAwesomeIcons.circleInfo), message: "Please provide a valid Youtube Url");
      return;
    }
    Navigator.of(context).pop(url);
  }

  bool _isYouTubeUrl({required String url}) {
    try {
      final uri = Uri.parse(url);

      // Check if the host contains "youtube.com" or "youtu.be"
      if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
        return true;
      }
    } catch (e) {
      // If parsing fails, it's not a valid URL at all
      return false;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.workoutVideoUrl);
  }

  @override
  void dispose() {
    yt.close();
    super.dispose();
  }
}
