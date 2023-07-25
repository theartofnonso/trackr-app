import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/activity_provider.dart';

import '../models/Activity.dart';
import '../models/ActivityDuration.dart';
import '../utils/activity_utils.dart';
import '../utils/datetime_utils.dart';
import '../widgets/buttons/button_wrapper_widget.dart';

class ActivityHistoryScreen extends StatefulWidget {
  final Activity activity;
  final DateTimeRange dateTimeRange;

  const ActivityHistoryScreen(
      {super.key, required this.activity, required this.dateTimeRange});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {

  late ActivityProvider _activityProvider;
  List<ActivityDuration> _activityDurations = [];

  void _goBack({required BuildContext context}) {
    Navigator.of(context).pop();
  }

  List<ListTile> _activityDurationsToButtons() {
    final activityDurations = activityDurationsWhere(range: widget.dateTimeRange.endInclusive(), activityDurations: _activityDurations);
    activityDurations.sort((a, b) => b.startTime.getDateTimeInUtc().compareTo(a.startTime.getDateTimeInUtc()));
    return activityDurations.map((timePeriod) {
      return ListTile(
        title: Text(timePeriod.startTime.getDateTimeInUtc().formattedDate()),
        subtitle: TimeFromAndToWidget(
          start: timePeriod.startTime.getDateTimeInUtc(),
          end: timePeriod.endTime.getDateTimeInUtc(),
        ),
        trailing: Text(
          "${timePeriod.duration().inHours} hours",
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CButtonWrapperWidget(
                    onPressed: () =>
                        _goBack(context: context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ))
              ],
            ),
            Expanded(
              child: ListView(
                children: [..._activityDurationsToButtons()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _activityProvider = Provider.of<ActivityProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activityProvider.listActivityDurationsWhere(activityId: widget.activity.id).then((activityDurations) {
        setState(() {
          _activityDurations = activityDurations;
        });
      });
    });
  }
}

class TimeFromAndToWidget extends StatelessWidget {
  final DateTime start;
  final DateTime end;

  const TimeFromAndToWidget(
      {super.key, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    final timeTextStyle = GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey);

    return Row(
      children: [
        Text(start.formattedTime(), style: timeTextStyle),
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
        Text(end.formattedTime(), style: timeTextStyle)
      ],
    );
  }
}
