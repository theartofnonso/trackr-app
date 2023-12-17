import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/empty_states/exercise_log_empty_state.dart';

class IntroScreen extends StatelessWidget {
  final ThemeData themeData;
  final VoidCallback onComplete;

  IntroScreen({super.key, required this.themeData, required this.onComplete});

  final _headers = ["CREATE", "LOG", "TRACK"];

  final _contents = [
    "TRACKR helps you create workouts with custom exercises, sets, reps, and weights.",
    "A user-friendly way to keep note of every detail about your workout sessions.",
    "Measure and gain insights on your performance across all training sessions and exercises.",
  ];

  final _titleStyle = GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16);

  final _subTitleStyle = GoogleFonts.lato(fontSize: 15, color: Colors.white.withOpacity(0.8));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 10),
              Image.asset(
                'assets/trackr.png',
                fit: BoxFit.contain,
                height: 16, // Adjust the height as needed
              ),
              const SizedBox(height: 20),
              const ExerciseLogEmptyState(mode: RoutineEditorMode.log, message: ""),
              ListTile(
                  leading: const Icon(Icons.add),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(_headers[0]),
                  ),
                  subtitle: Text(_contents[0]),
                  titleTextStyle: _titleStyle,
                  subtitleTextStyle: _subTitleStyle),
              const SizedBox(height: 8),
              ListTile(
                  leading: const Icon(Icons.history),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(_headers[1]),
                  ),
                  subtitle: Text(_contents[1]),
                  titleTextStyle: _titleStyle,
                  subtitleTextStyle: _subTitleStyle),
              const SizedBox(height: 8),
              ListTile(
                  leading: const Icon(Icons.timeline_rounded),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(_headers[2]),
                  ),
                  subtitle: Text(_contents[2]),
                  titleTextStyle: _titleStyle,
                  subtitleTextStyle: _subTitleStyle),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CTextButton(
                  onPressed: onComplete,
                  label: "Start Tracking",
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  buttonColor: Colors.green,
                  textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
            ]),
          ),
        ),
      ),
    );
  }
}
