import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:tracker_app/providers/activity_provider.dart';
import 'package:tracker_app/screens/activity_history_screen.dart';
import 'package:tracker_app/screens/activity_selection_screen.dart';
import 'package:tracker_app/screens/activity_settings_screen.dart';
import 'package:tracker_app/screens/activity_tracking_screen.dart';
import 'package:tracker_app/widgets/buttons/button_wrapper_widget.dart';

import '../utils/navigator_utils.dart';
import '../widgets/buttons/text_button_widget.dart';

class ActivityOverviewScreen extends StatefulWidget {
  const ActivityOverviewScreen({super.key});

  @override
  State<ActivityOverviewScreen> createState() => _ActivityOverviewScreenState();
}

class _ActivityOverviewScreenState extends State<ActivityOverviewScreen> {
  late Activity _activity;

  DateTimeRange? _dateRange;

  void _navigateToActivityTrackingScreen() {
    final route = createNewRouteFadeTransition(const ActivityTrackingScreen(
      activity: "Sleeping",
    ));
    Navigator.of(context).push(route);
  }

  void _navigateToActivitySelectionScreen() async {
    final route = createNewRouteFadeTransition(const ActivitySelectionScreen());
    final selectedActivity = await Navigator.of(context).push(route);
    if (selectedActivity != null) {
      setState(() {
        _activity = selectedActivity;
      });
    }
  }

  void _navigateToActivitySettingsScreen() async {
    final route = createNewRouteFadeTransition( ActivitySettingsScreen(activity: _activity));
    final selectedActivity = await Navigator.of(context).push(route);
    if (selectedActivity != null) {
      setState(() {
        _activity = selectedActivity;
      });
    }
  }

  void _navigateToActivityHistoryScreen() {
    final route = createNewRouteFadeTransition(ActivityHistoryScreen(
      activity: _activity,
    ));
    Navigator.of(context).push(route);
  }

  /// Display Date picker
  Future<void> _showDatePicker() async {
    final activityHistory = _activity.history;
    activityHistory.sort((a, b) => a.start.compareTo(b.start));
    final initialDate = activityHistory.isNotEmpty ? (activityHistory[0]).start : DateTime.now();

    final selectedDateRange = _dateRange = await showDateRangePicker(
      context: context,
      firstDate: initialDate,
      initialDateRange: DateTimeRange(
          start: _dateRange?.start ?? DateTime.now(),
          end: _dateRange?.end ?? DateTime.now()),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.grey,
              secondary: Colors.orangeAccent.shade100.withAlpha(30),
              onSurface: Colors.white, // <-- SEE HERE
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedDateRange != null) {
      setState(() {
        _dateRange = selectedDateRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Consumer<ActivityProvider>(builder: (_, activityProvider, __) {
          final activity = activityProvider.activities.firstWhere((activity) => activity.id == _activity.id);
          return Column(
            children: [
              Row(
                children: [
                  CButtonWrapperWidget(
                    onPressed: _navigateToActivitySelectionScreen,
                    child: Row(
                      children: [
                        Text(
                          activity.label,
                          style: GoogleFonts.inconsolata(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: _navigateToActivitySettingsScreen,
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  CTextButtonWidget(
                    onPressed: _showDatePicker,
                    label: "Jul",
                  )
                ],
              ),
              const SizedBox(
                height: 60,
              ),
              SizedBox(
                child: SfSparkLineChart(
                  color: Colors.white,
                  data: const <double>[
                    1,
                    5,
                    -3,
                    0,
                    0,
                    0,
                    0,
                    5,
                    5,
                    5,
                    3,
                    3,
                    -3,
                    0,
                    0,
                    5,
                    3
                  ],
                ),
              ),
              const Spacer(),
              CButtonWrapperWidget(
                  onPressed: _navigateToActivityHistoryScreen,
                  child: DurationOverviewWidget(
                    activity: activity,
                  )),
              const SizedBox(
                height: 50,
              ),
              CTextButtonWidget(
                onPressed: _navigateToActivityTrackingScreen,
                label: "Start tracking",
              )
            ],
          );
        }),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);
    activityProvider.listActivities();
    _activity = activityProvider.activities[0];
  }
}

class DurationOverviewWidget extends StatelessWidget {
  final Activity activity;

  const DurationOverviewWidget({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final durations = activity.durations();

    Duration minDuration =
        durations.reduce((value, element) => value < element ? value : element);

    // Find the maximum duration
    Duration maxDuration =
        durations.reduce((value, element) => value > element ? value : element);

    // Find the average duration
    Duration totalDuration =
        durations.reduce((value, element) => value + element);
    Duration averageDuration = Duration(
        milliseconds: totalDuration.inMilliseconds ~/ durations.length);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DurationOverviewItem(
          hours: minDuration.inHours,
          label: "Low hours",
        ),
        DurationOverviewItem(
          hours: averageDuration.inHours,
          label: "Avg hours",
        ),
        DurationOverviewItem(
          hours: maxDuration.inHours,
          label: "High hours",
        )
      ],
    );
  }
}

class DurationOverviewItem extends StatelessWidget {
  final int hours;
  final String label;

  const DurationOverviewItem(
      {super.key, required this.hours, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          hours.toString(),
          style: GoogleFonts.inconsolata(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          label.toString(),
          style: GoogleFonts.inconsolata(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
      ],
    );
  }
}
