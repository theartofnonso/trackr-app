import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/intro/screen_four.dart';
import 'package:tracker_app/screens/intro/screen_one.dart';
import 'package:tracker_app/screens/intro/screen_three.dart';
import 'package:tracker_app/screens/intro/screen_two.dart';

class IntroScreen extends StatefulWidget {
  final ThemeData themeData;
  final VoidCallback onComplete;

  const IntroScreen({super.key, required this.themeData, required this.onComplete});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _controller = PageController(
    initialPage: 0,
  );

  final _headers = ["CREATE", "LOG", "TRACK", ""];
  final _contents = [
    "TRACKR helps you pre-plan gym sessions and create workouts with custom exercises, sets, reps, and weights.",
    "A user-friendly way to keep note of every detail about your workout sessions.",
    "Measure and gain insights on your performance across all training sessions and exercises.",
    ""
  ];

  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: widget.themeData,
      home: Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
              height: 400,
              child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  children: [
                    const ScreenOne(),
                    const ScreenTwo(),
                    const ScreenThree(),
                    ScreenFour(onStartTracking: widget.onComplete)
                  ])),
          Container(
            height: 150,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_headers[_pageIndex],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24, letterSpacing: 3)),
                const SizedBox(height: 6),
                Text(
                  _contents[_pageIndex],
                  style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400),
                )
              ],
            ),
          ),
          //const Spacer(),
          SmoothPageIndicator(
            controller: _controller, // PageController
            count: 4,
            effect: const ExpandingDotsEffect(
                dotColor: tealBlueLighter, activeDotColor: Colors.white), // your preferred effect
          ),
          const Spacer(),
          Image.asset(
            'assets/trackr.png',
            fit: BoxFit.contain,
            height: 14, // Adjust the height as needed
          ),
          const Spacer(),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
