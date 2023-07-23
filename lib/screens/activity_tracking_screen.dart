import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../providers/activity_provider.dart';
import '../widgets/buttons/gradient_button_widget.dart';

class ActivityTrackingScreen extends StatefulWidget {
  final String activityLabel;
  final String activityId;
  final DateTime? lastActivityStartDatetime;

  const ActivityTrackingScreen(
      {super.key, required this.activityId, this.lastActivityStartDatetime, required this.activityLabel});

  @override
  State<ActivityTrackingScreen> createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> {
  late Timer _timer;

  String _elapsedDuration = ". . .";

  late DateTime _startDatetime;

  void _navigateToActivityOverviewScreen() {
    SharedPrefs().removeLastActivity();
    SharedPrefs().removeLastActivityId();
    SharedPrefs().removeLastActivityStartDatetime();
    Navigator.of(context).pop();
  }

  void _cacheActivityTracking() {
    SharedPrefs().lastActivity = widget.activityLabel;
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

    Activity? activity = Provider.of<ActivityProvider>(context)
          .activities
          .firstWhereOrNull((activity) => activity.id == widget.activityId);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(_elapsedDuration,
                  style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(
                height: 3,
              ),
              Text(activity?.label ?? widget.activityLabel,
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Spacer(),
              GradientButton(
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