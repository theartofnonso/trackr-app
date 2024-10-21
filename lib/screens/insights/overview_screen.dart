import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/activity_log_dto.dart';
import 'package:tracker_app/dtos/viewmodels/past_routine_log_arguments.dart';
import 'package:tracker_app/extensions/activity_log_extension.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/interface/log_interface.dart';
import '../../dtos/routine_log_dto.dart';
import '../../dtos/routine_template_dto.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../enums/activity_type_enums.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_text_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/calendar/calendar_navigator.dart';
import '../../widgets/label_divider.dart';
import '../../widgets/monitors/overview_monitor.dart';
import '../../widgets/routine/preview/activity_log_widget.dart';
import '../../widgets/routine/preview/routine_log_widget.dart';
import '../AI/trkr_coach_chat_screen.dart';
import 'monthly_insights_screen.dart';

class OverviewScreen extends StatefulWidget {
  final ScrollController? scrollController;

  static const routeName = '/overview_screen';

  const OverviewScreen({super.key, this.scrollController});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  Map<DateTimeRange, List<RoutineLogDto>>? _monthlyRoutineLogs;
  Map<DateTimeRange, List<ActivityLogDto>>? _monthlyActivityLogs;

  late DateTime _selectedDateTime;

  late DateTimeRange _monthDateTimeRange;

  bool _loading = false;

  TextEditingController? _textEditingController;

  void _logEmptyRoutine() async {
    final log = Provider.of<RoutineLogController>(context, listen: false).cachedLog();
    if (log == null) {
      final log = RoutineLogDto(
          id: "",
          templateId: "",
          name: "${timeOfDay()} Session",
          exerciseLogs: [],
          notes: "",
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          owner: "",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      final arguments = RoutineLogArguments(log: log, editorMode: RoutineEditorMode.log);
      navigateToRoutineLogEditor(context: context, arguments: arguments);
    } else {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline_rounded), message: "${log.name} is running");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    /// Routine Logs
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    Map<DateTimeRange, List<RoutineLogDto>> monthlyRoutineLogs =
        _monthlyRoutineLogs ?? routineLogController.monthlyLogs;

    final routineLogsForTheYear = monthlyRoutineLogs.values.expand((logs) => logs);

    /// Activity Logs
    final activityLogController = Provider.of<ActivityLogController>(context, listen: true);

    Map<DateTimeRange, List<ActivityLogDto>> monthlyActivityLogs =
        _monthlyActivityLogs ?? activityLogController.monthlyLogs;

    final activityLogsForTheYear = monthlyActivityLogs.values.expand((logs) => logs);

    return Scaffold(
      floatingActionButton: _loading
          ? null
          : FloatingActionButton(
              heroTag: "fab_overview_screen",
              onPressed: _showBottomSheet,
              backgroundColor: sapphireDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 24),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(
                    onPressed: null,
                    icon: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Image.asset(
                        'icons/dumbbells.png',
                        fit: BoxFit.contain,
                        height: 24, // Adjust the height as needed
                      ),
                      const SizedBox(width: 4),
                      Text("${routineLogsForTheYear.length}",
                          style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                    ]),
                  ),
                  CalendarNavigator(
                    onYearChange: _onYearChange,
                    onMonthChange: _onMonthChange,
                  ),
                  IconButton(
                    onPressed: null,
                    icon: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      const FaIcon(FontAwesomeIcons.personWalking, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text("${activityLogsForTheYear.length}",
                          style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                    ]),
                  ),
                ]),
                Expanded(
                  child: SingleChildScrollView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.only(bottom: 150),
                      child: Column(children: [
                        const SizedBox(height: 12),
                        OverviewMonitor(range: _monthDateTimeRange),
                        const SizedBox(height: 16),
                        Calendar(
                          onSelectDate: _onChangedDateTime,
                          selectedDateRange: _monthDateTimeRange,
                        ),
                        const SizedBox(height: 10),
                        _LogsListView(
                          dateTime: _selectedDateTime,
                        ),
                        const SizedBox(height: 12),
                        MonthlyInsightsScreen(dateTimeRange: _monthDateTimeRange),
                      ])),
                )
                // Add more widgets here for exercise insights
              ],
            )),
      ),
    );
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  void _showBottomSheet() {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.play, size: 18),
              horizontalTitleGap: 6,
              title: Text("Log new session",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                context.pop();
                _showLogNewSessionBottomSheet();
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 18),
              horizontalTitleGap: 6,
              title: Text("Log past session",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                showDatetimeRangePicker(
                    context: context,
                    onChangedDateTimeRange: (DateTimeRange datetimeRange) {
                      Navigator.pop(context);
                      final logName = "${timeOfDay(datetime: datetimeRange.start)} Session";
                      final log = RoutineLogDto(
                          id: "",
                          templateId: '',
                          name: logName,
                          exerciseLogs: [],
                          notes: "",
                          startTime: datetimeRange.start,
                          endTime: datetimeRange.end,
                          owner: "",
                          createdAt: datetimeRange.start,
                          updatedAt: datetimeRange.end);
                      final routineLogArguments = PastRoutineLogArguments(log: log);
                      navigateToPastRoutineLogEditor(context: context, arguments: routineLogArguments);
                    });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const LabelDivider(
              label: "Log non-resistance training",
              labelColor: Colors.white70,
              dividerColor: sapphireLighter,
            ),
            const SizedBox(
              height: 6,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(
                FontAwesomeIcons.circlePlus,
                size: 18,
                color: vibrantGreen,
              ),
              horizontalTitleGap: 6,
              title: Text("Add Activity",
                  style: GoogleFonts.ubuntu(color: vibrantGreen, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                showActivityPicker(
                    context: context,
                    onChangedActivity: (ActivityType activity, DateTimeRange datetimeRange) {
                      Navigator.pop(context);
                      final activityLog = ActivityLogDto(
                          id: "id",
                          name: activity.name,
                          notes: "",
                          startTime: datetimeRange.start,
                          endTime: datetimeRange.end,
                          createdAt: datetimeRange.end,
                          updatedAt: datetimeRange.end);
                      Provider.of<ActivityLogController>(context, listen: false).saveLog(logDto: activityLog);
                    });
              },
            ),
          ]),
        ));
  }

  void _showLogNewSessionBottomSheet() {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.play, size: 18),
              horizontalTitleGap: 6,
              title: Text("Log new session",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                context.pop();
                _logEmptyRoutine();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const LabelDivider(
              label: "Don't know what to train?",
              labelColor: Colors.white70,
              dividerColor: sapphireLighter,
            ),
            const SizedBox(
              height: 6,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const TRKRCoachWidget(),
              horizontalTitleGap: 10,
              title: TRKRCoachTextWidget("Describe your workout",
                  style: GoogleFonts.ubuntu(color: vibrantGreen, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _switchToAIContext();
              },
            ),
          ]),
        ));
  }

  void _switchToAIContext() async {
    final result =
        await navigateWithSlideTransition(context: context, child: const TRKRCoachChatScreen()) as RoutineTemplateDto?;
    if (result != null) {
      if (context.mounted) {
        final arguments = RoutineLogArguments(log: result.log(), editorMode: RoutineEditorMode.log);
        if (mounted) {
          navigateToRoutineLogEditor(context: context, arguments: arguments);
        }
      }
    }
  }

  void _onChangedDateTime(DateTime date) {
    setState(() {
      _selectedDateTime = date;
    });
  }

  void _onYearChange(DateTimeRange range) {
    _showLoadingScreen();

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);
    final activityLogController = Provider.of<ActivityLogController>(context, listen: false);

    routineLogController.fetchLogsCloud(range: range.start.dateTimeRange()).then((logs) {
      setState(() {
        final dtos = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
        _monthlyRoutineLogs = groupRoutineLogsByMonth(routineLogs: dtos);
      });
    });

    activityLogController.fetchLogsCloud(range: range.start.dateTimeRange()).then((logs) {
      setState(() {
        final dtos = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
        _monthlyActivityLogs = groupActivityLogsByMonth(activityLogs: dtos);
      });
    });

    _hideLoadingScreen();
  }

  void _onMonthChange(DateTimeRange range) {
    setState(() {
      _monthDateTimeRange = range;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _monthDateTimeRange = thisMonthDateRange();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }
}

class _LogsListView extends StatelessWidget {
  final DateTime dateTime;

  const _LogsListView({required this.dateTime});

  @override
  Widget build(BuildContext context) {
    /// Routine Logs
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);
    final routineLogsForCurrentDate = routineLogController.logsWhereDate(dateTime: dateTime).toList();

    /// Activity Logs
    final activityLogController = Provider.of<ActivityLogController>(context, listen: true);
    final activityLogsForCurrentDate = activityLogController.logsWhereDate(dateTime: dateTime).toList();

    /// Aggregates
    final allLogsForCurrentDate = [...routineLogsForCurrentDate, ...activityLogsForCurrentDate]
        .sorted((a, b) => a.createdAt.compareTo(b.createdAt))
        .toList();

    final children = allLogsForCurrentDate.map((log) {
      Widget widget;

      if (log.type == LogType.routine) {
        final routineLog = log as RoutineLogDto;
        widget = RoutineLogWidget(log: routineLog, trailing: routineLog.duration().hmsAnalog(), color: sapphireDark80);
      } else {
        final activityLog = log as ActivityLogDto;
        widget = ActivityLogWidget(
          activity: activityLog,
          trailing: activityLog.duration().hmsAnalog(),
          onTap: () {
            showActivityBottomSheet(context: context, activity: activityLog);
          },
          color: sapphireDark80,
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: widget,
      );
    }).toList();

    return Column(children: children);
  }
}
