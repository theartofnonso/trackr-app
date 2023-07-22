import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:tracker_app/providers/activity_provider.dart';
import 'package:tracker_app/screens/activity_history_screen.dart';
import 'package:tracker_app/screens/activity_selection_screen.dart';
import 'package:tracker_app/screens/activity_settings_screen.dart';
import 'package:tracker_app/screens/activity_tracking_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/button_wrapper_widget.dart';

import '../shared_prefs.dart';
import '../utils/navigator_utils.dart';
import '../widgets/buttons/elevated_button_widget.dart';
import '../widgets/buttons/text_button_widget.dart';
import 'add_activity_screen.dart';

class ActivityOverviewScreen extends StatefulWidget {
  const ActivityOverviewScreen({super.key});

  @override
  State<ActivityOverviewScreen> createState() => _ActivityOverviewScreenState();
}

class _ActivityOverviewScreenState extends State<ActivityOverviewScreen> {
  Activity? _activity;

  DateTimeRange _dateTimeRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  void _navigateToActivityTrackingScreen(
      {required String activityId, DateTime? startDatetime}) {
    final route = createNewRouteFadeTransition(ActivityTrackingScreen(
        activityId: activityId, lastActivityStartDatetime: startDatetime));
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
    final route = createNewRouteFadeTransition(
        ActivitySettingsScreen(activity: _activity!));
    final selectedActivity = await Navigator.of(context).push(route);
    if (selectedActivity != null) {
      setState(() {
        _activity = selectedActivity;
      });
    }
  }

  void _navigateToActivityHistoryScreen() {
    final route = createNewRouteFadeTransition(ActivityHistoryScreen(
      activity: _activity!,
      dateTimeRange: _dateTimeRange,
    ));
    Navigator.of(context).push(route);
  }

  void _navigateToAddNewActivityScreen() {
    final route = createNewRouteFadeTransition(const AddActivityScreen());
    Navigator.of(context).push(route);
  }

  void _restartPreviousTracking() {
    final lastActivityId = SharedPrefs().lastActivityId;
    final lastActivityStartDatetimeInMilli =
        SharedPrefs().lastActivityStartDatetime;
    if (lastActivityId.isNotEmpty && lastActivityStartDatetimeInMilli > 0) {
      final lastActivityStartDatetime =
          DateTime.fromMillisecondsSinceEpoch(lastActivityStartDatetimeInMilli);
      _navigateToActivityTrackingScreen(
          activityId: lastActivityId, startDatetime: lastActivityStartDatetime);
    }
  }

  /// Display Date picker
  Future<void> _showDatePicker() async {
    final activityHistory = _activity!.history;
    activityHistory.sort((a, b) => a.start.compareTo(b.start));
    final initialDate = activityHistory.isNotEmpty
        ? (activityHistory[0]).start
        : DateTime.now();

    final selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: initialDate,
      initialDateRange:
          DateTimeRange(start: _dateTimeRange.start, end: _dateTimeRange.end),
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
        _dateTimeRange = selectedDateRange;
      });
    }
  }

  Widget _displayTimePeriod() {
    String timePeriod = DateTime.now().formattedMonth();

    final dateTimeRange = _dateTimeRange;

    if (dateTimeRange.start.month != dateTimeRange.end.month) {
      return DateFromAndToWidget(
        start: dateTimeRange.start,
        end: dateTimeRange.end,
      );
    } else {
      timePeriod = dateTimeRange.start.formattedMonth();
    }

    return Text(
      timePeriod,
      style: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Consumer<ActivityProvider>(builder: (_, activityProvider, __) {
          try {
            _activity = activityProvider.activities
                .firstWhere((activity) => activity.id == _activity!.id);
          } catch (e) {
            _activity = activityProvider.activities.isNotEmpty
                ? activityProvider.activities.first
                : null;
          }

          final activity = _activity;

          if (activity == null) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Text("JUST TRACK AN ACTIVITY",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Colors.white)),
                  const SizedBox(
                    height: 5,
                  ),
                  Text.rich(TextSpan(
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          fontSize: 16),
                      children: const <TextSpan>[
                        TextSpan(
                            text: 'Improve or cut down',
                            style: TextStyle(color: Colors.white)),
                        TextSpan(text: ' '),
                        TextSpan(text: 'time wasted on certain activities'),
                      ])),
                  const SizedBox(
                    height: 20,
                  ),
                  CElevatedButtonWidget(
                    onPressed: _navigateToAddNewActivityScreen,
                    label: 'Track your first Activity',
                  ),
                ],
              ),
            );
          }

          final initialDate = activity.history[0].start;
          _dateTimeRange =
              DateTimeRange(start: initialDate, end: DateTime.now());

          return Column(
            children: [
              Row(
                children: [
                  CButtonWrapperWidget(
                    onPressed: _navigateToActivitySelectionScreen,
                    child: Row(
                      children: [
                        Text(
                          _activity!.label,
                          style: GoogleFonts.poppins(
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
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  CButtonWrapperWidget(
                      onPressed: _showDatePicker, child: _displayTimePeriod())
                ],
              ),
              const SizedBox(
                height: 60,
              ),
              DurationGraphWidget(
                  activity: _activity!, dateTimeRange: _dateTimeRange),
              const Spacer(),
              CButtonWrapperWidget(
                  onPressed: _navigateToActivityHistoryScreen,
                  child: DurationOverviewWidget(
                    activity: _activity!,
                    dateTimeRange: _dateTimeRange,
                  )),
              const SizedBox(
                height: 50,
              ),
              CElevatedButtonWidget(
                onPressed: () => _navigateToActivityTrackingScreen(
                    activityId: _activity!.id),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restartPreviousTracking();
    });
  }
}

class DurationGraphWidget extends StatelessWidget {
  final Activity activity;
  final DateTimeRange dateTimeRange;

  const DurationGraphWidget(
      {super.key, required this.activity, required this.dateTimeRange});

  @override
  Widget build(BuildContext context) {
    final durationsInMilliseconds = activity
        .historyWhere(range: dateTimeRange.endInclusive())
        .map((timePeriod) =>
            timePeriod.end.difference(timePeriod.start).inMilliseconds)
        .toList();

    return SfSparkLineChart(
      marker: const SparkChartMarker(
          displayMode: SparkChartMarkerDisplayMode.all,
          color: Colors.black,
          borderWidth: 2,
          shape: SparkChartMarkerShape.circle),
      color: Colors.white,
      width: 5,
      data: durationsInMilliseconds.length > 1
          ? durationsInMilliseconds
          : <int>[
              1,
              1,
            ],
    );
  }
}

class DurationOverviewWidget extends StatelessWidget {
  final Activity activity;
  final DateTimeRange dateTimeRange;

  const DurationOverviewWidget(
      {super.key, required this.activity, required this.dateTimeRange});

  @override
  Widget build(BuildContext context) {
    final durations = activity
        .historyWhere(range: dateTimeRange.endInclusive())
        .map((timePeriod) => timePeriod.end.difference(timePeriod.start))
        .toList();

    Duration minDuration = const Duration();
    Duration averageDuration = const Duration();
    Duration maxDuration = const Duration();

    if (durations.isNotEmpty) {
      minDuration = durations
          .reduce((value, element) => value < element ? value : element);

      // Find the maximum duration
      maxDuration = durations
          .reduce((value, element) => value > element ? value : element);

      // Find the average duration
      Duration totalDuration =
          durations.reduce((value, element) => value + element);
      averageDuration = Duration(
          milliseconds: totalDuration.inMilliseconds ~/ durations.length);
    }

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
          style: GoogleFonts.poppins(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          label.toString(),
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
      ],
    );
  }
}

class DateFromAndToWidget extends StatelessWidget {
  final DateTime start;
  final DateTime end;

  const DateFromAndToWidget(
      {super.key, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    final timeTextStyle = GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);

    return Row(
      children: [
        Text(start.formattedMonth(), style: timeTextStyle),
        const SizedBox(
          width: 5,
        ),
        const Icon(
          Icons.arrow_circle_right_outlined,
          size: 14,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(end.formattedMonth(), style: timeTextStyle)
      ],
    );
  }
}
