import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatefulWidget {
  final ThemeData themeData;
  final VoidCallback onComplete;

  const IntroScreen({super.key, required this.themeData, required this.onComplete});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {

  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;

  final _headers = ["CREATE", "LOG", "TRACK", ""];

  final _contents = [
    "TRACKR helps you pre-plan gym sessions and create workouts with custom exercises, sets, reps, and weights.",
    "A user-friendly way to keep note of every detail about your workout sessions.",
    "Measure and gain insights on your performance across all training sessions and exercises.",
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: widget.themeData,
      home: Scaffold(
        floatingActionButton: _showFab ? FloatingActionButton.extended(
          heroTag: "intro_screen",
          extendedPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          onPressed: widget.onComplete,
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          label: Text("Start tracking", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        ) : null,
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _IntroTile(title: _headers[0], body: _contents[0], image: 'assets/screen1.png'),
                const SizedBox(height: 8),
                _IntroTile(title: _headers[1], body: _contents[1], image: 'assets/screen1.png'),
                const SizedBox(height: 8),
                _IntroTile(title: _headers[2], body: _contents[2], image: 'assets/screen3.png'),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
        // User has scrolled to the bottom, show the FAB
        if (!_showFab) setState(() => _showFab = true);
      } else {
        // User is not at the bottom, hide the FAB
        if (_showFab) setState(() => _showFab = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
