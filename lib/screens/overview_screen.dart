// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../controllers/exercise_and_routine_controller.dart';
import '../utils/date_utils.dart';
import '../utils/navigation_utils.dart';
import '../widgets/backgrounds/trkr_loading_screen.dart';
import '../widgets/calendar/calendar.dart';
import '../widgets/calendar/calendar_logs.dart';
import '../widgets/chat/coach_chat_widget.dart';

enum TrainingAndVolume {
  training,
  volume;
}

class OverviewScreen extends StatefulWidget {
  static const routeName = '/overview_screen';

  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _loading = false;

  DateTime? _selectedCalendarDate;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    /// Be notified of changes
    final exerciseAndRoutineController =
        Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final logsForCurrentDay = exerciseAndRoutineController
        .whereLogsIsSameDay(dateTime: DateTime.now().withoutTime())
        .toList();

    final templates = exerciseAndRoutineController.templates;

    final lastQuarter = lastQuarterDateTimeRange();

    final logsInLastQuarter =
        exerciseAndRoutineController.whereLogsIsWithinRange(range: lastQuarter);

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping anywhere on the screen
        FocusScope.of(context).unfocus();
      },
      onPanStart: (_) {
        // Dismiss keyboard when starting to scroll/pan
        FocusScope.of(context).unfocus();
      },
      child: Column(children: [
        Calendar(
            onSelectDate: _onSelectCalendarDateTime,
            onMonthChanged: _onMonthChanged),
        CalendarLogs(dateTime: _selectedCalendarDate ?? DateTime.now()),
        StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: GestureDetector(
                onTap: () => navigateToRoutineTemplatesHome(context: context),
                child: _TemplatesTile(),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: GestureDetector(
                onTap: () => navigateToRoutinePlansHome(context: context),
                child: _PlansTile(),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: GestureDetector(
                onTap: () => navigateToSettings(context: context),
                child: _SettingsTile(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const CoachChatWidget(),
      ]),
    );
  }

  void _hideLoadingScreen() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onSelectCalendarDateTime(DateTime date) {
    setState(() {
      _selectedCalendarDate = date;
    });
  }

  void _onMonthChanged(DateTimeRange dateRange) {
    // Calendar month changed - can be used for future functionality
  }
}

class _TemplatesTile extends StatelessWidget {
  const _TemplatesTile();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      width: 25,
      height: 25,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: isDarkMode
              ? darkSurfaceContainer
              : Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(radiusMD)),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.personWalking,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PlansTile extends StatelessWidget {
  const _PlansTile();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      width: 25,
      height: 25,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: isDarkMode
              ? darkSurfaceContainer
              : Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(radiusMD)),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.solidFolderOpen,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
        width: 25,
        height: 25,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: isDarkMode
                ? darkSurfaceContainer
                : Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(radiusMD)),
        child: Center(
            child: Center(
          child: FaIcon(
            FontAwesomeIcons.gear,
            size: 28,
            color: Colors.white,
          ),
        )));
  }
}
