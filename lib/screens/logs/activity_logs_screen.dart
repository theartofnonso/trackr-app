import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';
import 'package:tracker_app/widgets/routine/preview/activity_log_widget.dart';

import '../../controllers/activity_log_controller.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';

class ActivityLogsScreen extends StatelessWidget {
  static const routeName = '/activity_logs_screen';

  final DateTime dateTime;

  const ActivityLogsScreen({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final activityLogsForMonth =
        Provider.of<ActivityLogController>(context, listen: true).whereLogsIsSameMonth(dateTime: dateTime);

    final logs = activityLogsForMonth.sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    final month = dateTime.formattedFullMonth();

    return Scaffold(
      appBar: AppBar(
        title: Text("$month Activities".toUpperCase()),
        centerTitle: true,
        leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28), onPressed: Navigator.of(context).pop),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          bottom: false,
          minimum: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              logs.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 150),
                          itemBuilder: (BuildContext context, int index) {
                            final log = logs[index];
                            return ActivityLogWidget(
                                activity: log,
                                trailing: log.createdAt.durationSinceOrDate(),
                                color: Colors.transparent,
                                onTap: () {
                                  showActivityBottomSheet(context: context, activity: log);
                                });
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(color: Colors.white70.withValues(alpha:0.1)),
                          itemCount: logs.length),
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
