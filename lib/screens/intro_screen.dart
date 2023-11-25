import 'package:flutter/material.dart';

import '../widgets/buttons/text_button_widget.dart';

class IntroScreen extends StatelessWidget {
  final ThemeData themeData;
  final VoidCallback onComplete;

  IntroScreen({super.key, required this.themeData, required this.onComplete});

  final _headers = ["CREATE", "LOG", "TRACK", ""];

  final _contents = [
    "TRACKR helps you pre-plan gym sessions and create workouts with custom exercises, sets, reps, and weights.",
    "A user-friendly way to keep note of every detail about your workout sessions.",
    "Measure and gain insights on your performance across all training sessions and exercises.",
    ""
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _IntroTile(title: _headers[0], body: _contents[0], image: 'assets/screen1.png'),
                const SizedBox(height: 8),
                _IntroTile(title: _headers[1], body: _contents[1], image: 'assets/screen1.png'),
                const SizedBox(height: 8),
                _IntroTile(title: _headers[2], body: _contents[2], image: 'assets/screen3.png'),
                const SizedBox(height: 10),
                CTextButton(
                  onPressed: onComplete,
                  label: 'Start Tracking performance',
                  textStyle: const TextStyle(fontSize: 16),
                  buttonColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroTile extends StatelessWidget {
  final String title;
  final String body;
  final String image;

  const _IntroTile({required this.title, required this.body, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 3)),
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      SizedBox(
        width: double.infinity,
        child: Image.asset(
          image,
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
        ),
      )
    ]);
  }
}
