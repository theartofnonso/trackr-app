import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';
import 'package:tracker_app/widgets/routine/preview/activity_log_widget.dart';

import '../../controllers/activity_log_controller.dart';
import '../../utils/dialog_utils.dart';

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
        backgroundColor: sapphireDark80,
        title: Text("$month Activities".toUpperCase(),
            style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: Navigator.of(context).pop),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
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
                              Divider(color: Colors.white70.withOpacity(0.1)),
                          itemCount: logs.length),
                    )
                  : const NoListEmptyState(message: "It might feel quiet now, but your logged activities will soon appear here."),
            ],
          ),
        ),
      ),
    );
  }
}
