import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../providers/activity_provider.dart';
import '../widgets/buttons/text_button_widget.dart';

class ActivityTrackingScreen extends StatefulWidget {
  final String activityId;
  final DateTime? lastActivityStartDatetime;

  const ActivityTrackingScreen(
      {super.key, required this.activityId, this.lastActivityStartDatetime});

  @override
  State<ActivityTrackingScreen> createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> {
  late Timer _timer;

  String _elapsedDuration = "";

  late DateTime _startDatetime;

  void _navigateToActivityOverviewScreen() {
    SharedPrefs().removeLastActivityId();
    SharedPrefs().removeLastActivityStartDatetime();
    Navigator.of(context).pop();
  }

  void _cacheActivityTracking() {
    SharedPrefs().lastActivityId = widget.activityId;
    SharedPrefs().lastActivityStartDatetime =
        _startDatetime.millisecondsSinceEpoch;
  }

  @override
  void initState() {
    super.initState();
    _startDatetime = widget.lastActivityStartDatetime ?? DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedDuration =
            DateTime.now().difference(_startDatetime).friendlyTime();
      });
    });
    _cacheActivityTracking();
  }

  @override
  Widget build(BuildContext context) {
    final activity = Provider.of<ActivityProvider>(context)
        .activities
        .firstWhere((activity) => activity.id == widget.activityId);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(activity.label,
                  style: GoogleFonts.inconsolata(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(
                height: 3,
              ),
              Text(_elapsedDuration,
                  style: GoogleFonts.inconsolata(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
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

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}