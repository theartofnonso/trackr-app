import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../utils/dialog_utils.dart';
import '../../utils/navigation_utils.dart';
import '../empty_states/routine_log_empty_state.dart';
import '../routine/preview/activity_log_widget.dart';

class ActivitiesWidget extends StatelessWidget {
  final List<ActivityLogDto> activities;

  const ActivitiesWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: sapphireDark80,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        onTap: () => _showActivityLogs(context: context),
        tileColor: sapphireDark80,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        leading: const FaIcon(FontAwesomeIcons.personWalking, color: Colors.white70),
        title: Text("Activities".toUpperCase(),
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text("All activities outside your training",
            style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400)),
        trailing: Text("${activities.length}",
            style: GoogleFonts.ubuntu(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w900, fontSize: 20)),
      ),
    );
  }

  void _showActivityLogs({required BuildContext context}) {
    navigateWithSlideTransition(
        context: context,
        child: _LogsScreen(
          activities: activities,
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
        backgroundColor: sapphireDark80,
        title: Text("Activities".toUpperCase(),
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
                  : const RoutineLogEmptyState(),
            ],
          ),
        ),
      ),
    );
  }
}
