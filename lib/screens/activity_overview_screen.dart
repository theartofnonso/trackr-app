import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:tracker_app/providers/activity_provider.dart';
import 'package:tracker_app/screens/activity_durations_screen.dart';
import 'package:tracker_app/screens/activity_selection_screen.dart';
import 'package:tracker_app/screens/activity_settings_screen.dart';
import 'package:tracker_app/screens/activity_tracking_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/button_wrapper_widget.dart';

import '../models/Activity.dart';
import '../models/ActivityDuration.dart';
import '../shared_prefs.dart';
import '../utils/activity_utils.dart';
import '../widgets/buttons/gradient_button_widget.dart';
import 'add_activity_screen.dart';

class ActivityOverviewScreen extends StatefulWidget {
  const ActivityOverviewScreen({super.key});

  @override
  State<ActivityOverviewScreen> createState() => _ActivityOverviewScreenState();
}

class _ActivityOverviewScreenState extends State<ActivityOverviewScreen> {
  late ActivityProvider _activityProvider;
  List<ActivityDuration> _activityDurations = [];

  Activity? _activity;

  DateTimeRange _dateTimeRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  void _navigateToActivityTrackingScreen(
      {required String activityId,
      required String activityLabel,
      DateTime? startDatetime}) async {
    await showDialog(
        context: context,
        builder: ((context) {
          return ActivityTrackingScreen(
            activityId: activityId,
            lastActivityStartDatetime: startDatetime,
            activityName: activityLabel,
          );
        }));
    _refreshAfterTracking();
  }

  void _navigateToActivitySelectionScreen() async {
    final selectedActivity = await showDialog(
        context: context,
        builder: ((context) {
          return const ActivitySelectionScreen();
        }));
    if (selectedActivity != null) {
      setState(() {
        _activity = selectedActivity;
      });
    }
  }

  void _navigateToActivitySettingsScreen() async {
    final selectedActivity = await showDialog(
        context: context,
        builder: ((context) {
          return ActivitySettingsScreen(activity: _activity!);
        }));
    if (selectedActivity != null) {
      setState(() {
        _activity = selectedActivity;
      });
    }
  }

  void _navigateToActivityHistoryScreen() {
    showDialog(
        context: context,
        builder: ((context) {
          return ActivityDurationsScreen(
            activity: _activity!,
            dateTimeRange: _dateTimeRange,
          );
        }));
  }

  void _navigateToAddNewActivityScreen() async {
    final newActivity = await showDialog(
        context: context,
        builder: ((context) {
          return const AddActivityScreen();
        }));
    if (newActivity != null) {
      setState(() {
        _activity = newActivity;
      });
      _refreshAfterTracking();
    }
  }

  void _refreshAfterTracking() {
    final activity = _activity;
    if (activity != null) {
      _activityProvider
          .listActivityDurationsWhere(activityId: activity.id)
          .then((activityDurations) {
        setState(() {
          _activityDurations = activityDurations;
        });
      });
    }
  }

  void _restartPreviousTracking() {
    final lastActivity = SharedPrefs().lastActivity;
    final lastActivityId = SharedPrefs().lastActivityId;
    final lastActivityStartDatetimeInMilli =
        SharedPrefs().lastActivityStartDatetime;
    if (lastActivity.isNotEmpty &&
        lastActivityId.isNotEmpty &&
        lastActivityStartDatetimeInMilli > 0) {
      final lastActivityStartDatetime =
          DateTime.fromMillisecondsSinceEpoch(lastActivityStartDatetimeInMilli);
      _navigateToActivityTrackingScreen(
          activityId: lastActivityId,
          startDatetime: lastActivityStartDatetime,
          activityLabel: lastActivity);
    }
  }

  /// Display Date picker
  Future<void> _showDatePicker() async {
    final activity = _activity;
    if (activity != null) {
      final activityHistory = activity.history;
      activityHistory?.sort((a, b) => a.startTime
          .getDateTimeInUtc()
          .compareTo(b.startTime.getDateTimeInUtc()));

      DateTime initialDate = DateTime.now();
      if (activityHistory != null) {
        if (activityHistory.isNotEmpty) {
          initialDate = activityHistory[0].startTime.getDateTimeInUtc();
        }
      }

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
                  GradientButton(
                    label: 'Track your first Activity',
                    onPressed: _navigateToAddNewActivityScreen,
                  )
                ],
              ),
            );
          }

          final initialDate = activity.history?[0].startTime.getDateTimeInUtc();
          _dateTimeRange = DateTimeRange(
              start: initialDate ?? DateTime.now(), end: DateTime.now());

          return Column(
            children: [
              Row(
                children: [
                  CButtonWrapperWidget(
                    onPressed: _navigateToActivitySelectionScreen,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            _activity!.name,
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
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
                dateTimeRange: _dateTimeRange,
                activityDurations: _activityDurations,
              ),
              const Spacer(),
              CButtonWrapperWidget(
                  onPressed: _navigateToActivityHistoryScreen,
                  child: DurationOverviewWidget(
                    dateTimeRange: _dateTimeRange,
                    activityDurations: _activityDurations,
                  )),
              const SizedBox(
                height: 50,
              ),
              GradientButton(
                onPressed: () => _navigateToActivityTrackingScreen(
                    activityId: _activity!.id, activityLabel: _activity!.name),
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
    _activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    _activityProvider.listActivities();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restartPreviousTracking();
    });
  }
}

class DurationGraphWidget extends StatefulWidget {
  final List<ActivityDuration> activityDurations;
  final DateTimeRange dateTimeRange;

  const DurationGraphWidget(
      {super.key,
      required this.dateTimeRange,
      required this.activityDurations});

  @override
  State<DurationGraphWidget> createState() => _DurationGraphWidgetState();
}

class _DurationGraphWidgetState extends State<DurationGraphWidget> {
  @override
  Widget build(BuildContext context) {
    final activityDurations = activityDurationsWhere(
        range: widget.dateTimeRange.endInclusive(),
        activityDurations: widget.activityDurations);

    final durationsInMilli = activityDurations
        .map((timePeriod) => timePeriod.endTime
            .getDateTimeInUtc()
            .difference(timePeriod.startTime.getDateTimeInUtc())
            .inMilliseconds)
        .toList();

    double averageDurationInMilliInSeconds = 0.0;
    if (durationsInMilli.isNotEmpty) {
      final totalDurationInMilliInSeconds =
          durationsInMilli.reduce((value, element) => value + element);
      averageDurationInMilliInSeconds =
          totalDurationInMilliInSeconds / durationsInMilli.length;
    }

    return SfSparkLineChart(
      axisLineDashArray: const [8, 8],
      axisLineWidth: 3,
      axisLineColor: Colors.grey.withOpacity(0.5),
      axisCrossesAt: averageDurationInMilliInSeconds,
      color: Colors.white,
      width: 5,
      data: durationsInMilli.length > 1
          ? durationsInMilli
          : <int>[
              1,
              1,
            ],
    );
  }
}

enum DurationOverviewType { low, average, high }

class DurationOverviewWidget extends StatefulWidget {
  final List<ActivityDuration> activityDurations;
  final DateTimeRange dateTimeRange;

  const DurationOverviewWidget(
      {super.key,
      required this.dateTimeRange,
      required this.activityDurations});

  @override
  State<DurationOverviewWidget> createState() => _DurationOverviewWidgetState();
}

class _DurationOverviewWidgetState extends State<DurationOverviewWidget> {
  @override
  Widget build(BuildContext context) {
    final activityDurations = activityDurationsWhere(
        range: widget.dateTimeRange.endInclusive(),
        activityDurations: widget.activityDurations);

    final durations = activityDurations
        .map((timePeriod) => timePeriod.endTime
            .getDateTimeInUtc()
            .difference(timePeriod.startTime.getDateTimeInUtc()))
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
          duration: minDuration,
          label: "Low",
          child: const Icon(Icons.arrow_drop_down),
        ),
        DurationOverviewItem(duration: averageDuration, label: "Avg"),
        DurationOverviewItem(
          duration: maxDuration,
          label: "High",
          child: const Icon(Icons.arrow_drop_up),
        )
      ],
    );
  }
}

class DurationOverviewItem extends StatelessWidget {
  final Duration duration;
  final String label;
  final Widget? child;

  const DurationOverviewItem(
      {super.key, required this.duration, required this.label, this.child});

  @override
  Widget build(BuildContext context) {
    final (durationValue: value, type: type) = duration.nearestDuration();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
            text: TextSpan(
                style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                children: [
              TextSpan(text: "$value"),
              const TextSpan(text: " "),
              TextSpan(
                  text: type.shortName,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600))
            ])),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            child ?? const SizedBox.shrink(),
            Text(
              label.toString(),
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            )
          ],
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
