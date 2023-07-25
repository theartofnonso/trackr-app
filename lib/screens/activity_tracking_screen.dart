import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../models/Activity.dart';
import '../providers/activity_provider.dart';
import '../widgets/buttons/gradient_button_widget.dart';

class ActivityTrackingScreen extends StatefulWidget {
  final String activityName;
  final String activityId;
  final DateTime? lastActivityStartDatetime;

  const ActivityTrackingScreen(
      {super.key,
      required this.activityId,
      this.lastActivityStartDatetime,
      required this.activityName});

  @override
  State<ActivityTrackingScreen> createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> {
  late Timer _timer;

  String _elapsedDuration = ". . .";

  late DateTime _startDatetime;

  late ActivityProvider _activityProvider;

  void _goBack() {
    SharedPrefs().removeLastActivity();
    SharedPrefs().removeLastActivityId();
    SharedPrefs().removeLastActivityStartDatetime();
    Navigator.of(context).pop();
  }

  void _cacheActivityTracking() {
    SharedPrefs().lastActivity = widget.activityName;
    SharedPrefs().lastActivityId = widget.activityId;
    SharedPrefs().lastActivityStartDatetime =
        _startDatetime.millisecondsSinceEpoch;
  }

  void _endTracking() {
    _addNewActivityDuration();
    _goBack();
  }

  void _addNewActivityDuration() async {
    await _activityProvider.addActivityDuration(
        activityId: widget.activityId,
        startTime: _startDatetime,
        endTime: DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _activityProvider = Provider.of<ActivityProvider>(context, listen: false);
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
              SizedBox(
                width: 180,
                child: Center(
                  child: Text(activity?.name ?? widget.activityName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const Spacer(),
              GradientButton(
                onPressed: _endTracking,
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
