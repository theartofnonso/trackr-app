import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../empty_states/no_list_empty_state.dart';
import '../routine/preview/activity_log_widget.dart';

class ActivitiesWidget extends StatelessWidget {
  final List<ActivityLogDto> thisMonthsActivities;
  final List<ActivityLogDto> lastMonthsActivities;

  const ActivitiesWidget({super.key, required this.thisMonthsActivities, required this.lastMonthsActivities});

  @override
  Widget build(BuildContext context) {
    final thisMonthCount = thisMonthsActivities.length;
    final lastMonthCount = lastMonthsActivities.length;

    final improved = thisMonthCount > lastMonthCount;

    return ListTile(
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
                Text("$thisMonthCount", style: Theme.of(context).textTheme.titleMedium),
                Text("$lastMonthCount", style: Theme.of(context).textTheme.titleSmall)
              ],
            ),
            const SizedBox(width: 4),
            FaIcon(
              improved ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
              color: improved ? vibrantGreen : Colors.deepOrange,
              size: 12,
            )
          ],
        ));
  }

  void _showActivityLogs({required BuildContext context}) {
    navigateWithSlideTransition(
        context: context,
        child: _LogsScreen(
          activities: thisMonthsActivities,
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
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(color: Colors.white70.withOpacity(0.1)),
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
