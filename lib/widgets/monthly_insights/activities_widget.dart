import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../controllers/activity_log_controller.dart';
import '../../utils/data_trend_utils.dart';
import '../../utils/date_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../empty_states/no_list_empty_state.dart';
import '../list_tile.dart';
import '../routine/preview/activity_log_widget.dart';

class ActivitiesWidget extends StatelessWidget {
  final DateTimeRange dateTimeRange;

  const ActivitiesWidget({super.key, required this.dateTimeRange});

  @override
  Widget build(BuildContext context) {
    final dateRange = DateTimeRange(start: theLastYearDateTimeRange().start, end: dateTimeRange.end);

    final activitiesController = Provider.of<ActivityLogController>(context, listen: true);

    final logs = activitiesController.whereLogsIsWithinRange(range: dateRange).toList();

    final monthsInLastYear = generateMonthsInRange(range: dateRange);

    List<int> numberOfLoggedActivities = [];
    for (final month in monthsInLastYear) {
      final startOfMonth = month.start;
      final endOfMonth = month.end;
      final logsForTheMonth = logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfMonth, to: endOfMonth));
      numberOfLoggedActivities.add(logsForTheMonth.length);
    }

    final previousActivities = numberOfLoggedActivities.sublist(0, numberOfLoggedActivities.length - 1);
    final averageOfPrevious = (previousActivities.reduce((a, b) => a + b) / previousActivities.length).round();

    // 4. Identify the most recent activities
    final lastMonthActivities = numberOfLoggedActivities.last;

    final difference = lastMonthActivities - averageOfPrevious;

    final bool averageIsZero = (averageOfPrevious == 0);
    final double percentageChange = averageIsZero ? 100.0 : (difference / averageOfPrevious) * 100;

    // 6. Decide the trend
    const threshold = 5; // ±5% threshold
    late final Trend trend;
    if (percentageChange > threshold) {
      trend = Trend.up;
    } else if (percentageChange < -threshold) {
      trend = Trend.down;
    } else {
      trend = Trend.stable;
    }

    return ThemeListTile(
      child: ListTile(
          onTap: () => _showActivityLogs(context: context),
          leading: const FaIcon(FontAwesomeIcons.personWalking),
          title: Text("Activities".toUpperCase()),
          subtitle: Text("All activities outside your training"),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$lastMonthActivities", style: Theme.of(context).textTheme.titleMedium),
                  Text("$averageOfPrevious", style: Theme.of(context).textTheme.titleSmall)
                ],
              ),
              const SizedBox(width: 4),
              trend == Trend.up
                  ? FaIcon(
                      trend == Trend.up ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                      color: trend == Trend.up ? vibrantGreen : Colors.deepOrange,
                      size: 12,
                    )
                  : const SizedBox.shrink()
            ],
          )),
    );
  }

  void _showActivityLogs({required BuildContext context}) {
    final activitiesController = Provider.of<ActivityLogController>(context, listen: false);

    /// Activity Logs
    final thisMonthsActivityLogs = activitiesController
        .whereLogsIsSameMonth(dateTime: dateTimeRange.start)
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    navigateWithSlideTransition(
        context: context,
        child: _LogsScreen(
          activities: thisMonthsActivityLogs,
        ));
  }
}

class _LogsScreen extends StatelessWidget {
  final List<ActivityLogDto> activities;

  const _LogsScreen({
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${DateTime.now().formattedFullMonth()} Activities".toUpperCase()),
        centerTitle: true,
        leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28), onPressed: Navigator.of(context).pop),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              activities.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 150),
                          itemBuilder: (BuildContext context, int index) {
                            final log = activities[index];
                            return ActivityLogWidget(
                                activity: log,
                                trailing: log.createdAt.durationSinceOrDate(),
                                color: Colors.transparent,
                                onTap: () {
                                  showActivityBottomSheet(context: context, activity: log);
                                });
                          },
                          separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.transparent),
                          itemCount: activities.length),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: const NoListEmptyState(
                            message: "It might feel quiet now, but your logged activities will soon appear here."),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
