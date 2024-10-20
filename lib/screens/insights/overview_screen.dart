import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/activity_log_dto.dart';
import 'package:tracker_app/dtos/viewmodels/past_routine_log_arguments.dart';
import 'package:tracker_app/enums/share_content_type_enum.dart';
import 'package:tracker_app/extensions/activity_log_extension.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/datetime_range_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/calendar/calendar_months_navigator.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/interface/log_interface.dart';
import '../../dtos/routine_log_dto.dart';
import '../../dtos/routine_template_dto.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../enums/activity_type_enums.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/app_analytics.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/routine_utils.dart';
import '../../utils/shareables_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_text_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/calendar/calendar.dart';
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
  late DateTimeRange _selectedDateTimeRange;
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

    final routineLogsForTheMonth =
        _monthlyRoutineLogs?[_selectedDateTimeRange] ?? routineLogController.monthlyLogs[_selectedDateTimeRange] ?? [];

    Map<DateTimeRange, List<RoutineLogDto>> monthlyRoutineLogs =
        _monthlyRoutineLogs ?? routineLogController.monthlyLogs;

    final routineLogsForTheYear = monthlyRoutineLogs.values.expand((logs) => logs);

    final routineLogsForCurrentDate = routineLogController.logsWhereDate(dateTime: _selectedDateTime).toList();

    /// Activity Logs
    final activityLogController = Provider.of<ActivityLogController>(context, listen: true);

    final activityLogsForTheMonth = _monthlyActivityLogs?[_selectedDateTimeRange] ??
        activityLogController.monthlyLogs[_selectedDateTimeRange] ??
        [];

    Map<DateTimeRange, List<ActivityLogDto>> monthlyActivityLogs =
        _monthlyActivityLogs ?? activityLogController.monthlyLogs;

    final activityLogsForTheYear = monthlyActivityLogs.values.expand((logs) => logs);

    final activityLogsForCurrentDate = activityLogController.logsWhereDate(dateTime: _selectedDateTime).toList();

    /// Aggregates
    final allActivitiesForCurrentDate = [...routineLogsForCurrentDate, ...activityLogsForCurrentDate];

    final allActivitiesForTheYear = routineLogsForTheYear.length + activityLogsForTheYear.length;

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
                      const FaIcon(FontAwesomeIcons.fire, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text("$allActivitiesForTheYear",
                          style:
                          GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                    ]),
                  ),
                  CalendarMonthsNavigator(onChangedDateTimeRange: _onChangedDateTimeRange),
                  IconButton(
                      onPressed: _showShareBottomSheet,
                      icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 20)),
                ]),
                Expanded(
                  child: SingleChildScrollView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.only(bottom: 150),
                      child: Column(children: [
                        const SizedBox(height: 12),
                        OverviewMonitor(
                          range: _selectedDateTimeRange,
                          routineLogs: routineLogsForTheMonth,
                        ),
                        const SizedBox(height: 16),
                        Calendar(
                          onSelectDate: _onChangedDateTime,
                          selectedDateRange: _selectedDateTimeRange,
                        ),
                        const SizedBox(height: 10),
                        _LogsListView(
                          logs: allActivitiesForCurrentDate,
                        ),
                        const SizedBox(height: 12),
                        MonthlyInsightsScreen(
                          logsForTheMonth: routineLogsForTheMonth,
                          daysInMonth: _selectedDateTimeRange.datesToNow.length,
                          dateTimeRange: _selectedDateTimeRange,
                          monthlyLogsAndDate: monthlyRoutineLogs,
                          activityLogsForTheMonth: activityLogsForTheMonth,
                        ),
                      ])),
                )
                // Add more widgets here for exercise insights
              ],
            )),
      ),
    );
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  void _showShareBottomSheet() {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(Icons.monitor, size: 18),
              horizontalTitleGap: 6,
              title: Text("Share Streak and Muscle Monitor",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                _onShareMonitor();
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.calendar, size: 18),
              horizontalTitleGap: 6,
              title: Text("Share Log Calendar",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                _onShareCalendar();
              },
            ),
          ]),
        ));
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
    final result = await navigateWithSlideTransition(context: context, child: const TRKRCoachChatScreen())
        as RoutineTemplateDto?;
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

  void _onChangedDateTimeRange(DateTimeRange? range) {
    if (range == null) return;

    final isDifferentYear = !_selectedDateTimeRange.start.isSameYear(range.start);

    setState(() {
      _loading = isDifferentYear;
    });

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);
    final activityLogController = Provider.of<ActivityLogController>(context, listen: false);

    if (isDifferentYear) {
      routineLogController.fetchLogsCloud(range: range.start.dateTimeRange()).then((logs) {
        setState(() {
          _loading = false;
          final dtos = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
          _monthlyRoutineLogs = groupRoutineLogsByMonth(routineLogs: dtos);
        });
      });
      activityLogController.fetchLogsCloud(range: range.start.dateTimeRange()).then((logs) {
        setState(() {
          _loading = false;
          final dtos = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
          _monthlyActivityLogs = groupActivityLogsByMonth(activityLogs: dtos);
        });
      });
    }

    setState(() {
      _selectedDateTimeRange = range;
    });
  }

  void _onShareMonitor() {

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final routineLogsForTheMonth =
        _monthlyRoutineLogs?[_selectedDateTimeRange] ?? routineLogController.monthlyLogs[_selectedDateTimeRange] ?? [];

    displayBottomSheet(context: context, child: Column(
      children: [
        RepaintBoundary(
          key: monitorKey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: OverviewMonitor(
                range: _selectedDateTimeRange,
                routineLogs: routineLogsForTheMonth,
                showInfo: false,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        OpacityButtonWidget(
            onPressed: () {
              captureImage(key: monitorKey, pixelRatio: 5);
              contentShared(contentType: ShareContentType.monitor);
              Navigator.of(context).pop();
            },
            label: "Share",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14))
      ],
    ),);
  }

  void _onShareCalendar() {
    displayBottomSheet(
        context: context,
        isScrollControlled: true,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RepaintBoundary(
                  key: calendarKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
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
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(_selectedDateTimeRange.start.formattedMonthAndYear(),
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                            ),
                            Calendar(selectedDateRange: _selectedDateTimeRange),
                            const SizedBox(height: 12),
                            Image.asset(
                              'images/trkr.png',
                              fit: BoxFit.contain,
                              height: 8, // Adjust the height as needed
                            ),
                          ],
                        )),
                  )),
              const SizedBox(height: 20),
              OpacityButtonWidget(
                  onPressed: () {
                    captureImage(key: calendarKey, pixelRatio: 5);
                    contentShared(contentType: ShareContentType.calender);
                    Navigator.of(context).pop();
                  },
                  label: "Share",
                  buttonColor: vibrantGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14))
            ]));
  }

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _selectedDateTimeRange = thisMonthDateRange();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }
}

class _LogsListView extends StatelessWidget {
  final List<Log> logs;

  const _LogsListView({required this.logs});

  @override
  Widget build(BuildContext context) {
    final descendingLogs = logs.sorted((a, b) => a.createdAt.compareTo(b.createdAt)).toList();

    final children = descendingLogs.map((log) {
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
