import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../widgets/buttons/text_button_widget.dart';

class ActivityTrackingScreen extends StatefulWidget {
  final String activity;

  const ActivityTrackingScreen({super.key, required this.activity});

  @override
  State<ActivityTrackingScreen> createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> {
  void _navigateToActivityOverviewScreen() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(widget.activity,
                  style: GoogleFonts.inconsolata(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(
                height: 3,
              ),
              const TrackingTimerWidget(),
              const Spacer(),
              CTextButtonWidget(
                onPressed: _navigateToActivityOverviewScreen,
                label: "Stop tracking",
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TrackingTimerWidget extends StatefulWidget {
  const TrackingTimerWidget({super.key});

  @override
  State<TrackingTimerWidget> createState() => _TrackingTimerWidgetState();
}

class _TrackingTimerWidgetState extends State<TrackingTimerWidget> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;

  String _elapsedDuration = "Starting";

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedDuration = _stopwatch.elapsed.friendlyTime();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_elapsedDuration,
        style: GoogleFonts.inconsolata(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white));
  }

  @override
  void dispose() {
    super.dispose();
    _stopwatch.stop();
    _timer.cancel();
  }
}
