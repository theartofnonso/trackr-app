// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/screens/editors/past_routine_log_editor_screen.dart';

import '../controllers/exercise_and_routine_controller.dart';
import '../dtos/appsync/routine_log_dto.dart';
import '../dtos/appsync/routine_template_dto.dart';
import '../dtos/viewmodels/routine_log_arguments.dart';
import '../enums/routine_editor_type_enums.dart';
import '../utils/date_utils.dart';
import '../utils/general_utils.dart';
import '../utils/navigation_utils.dart';
import '../widgets/ai_widgets/trkr_coach_text_widget.dart';
import '../widgets/backgrounds/trkr_loading_screen.dart';
import '../widgets/calendar/calendar.dart';
import '../widgets/calendar/calendar_logs.dart';
import '../widgets/dividers/label_divider.dart';
import 'AI/trkr_coach_chat_screen.dart';

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

    return SingleChildScrollView(
      child: Column(children: [
        Calendar(
            onSelectDate: _onSelectCalendarDateTime,
            onMonthChanged: _onMonthChanged),
        const SizedBox(height: 10),
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
                onTap: () => navigateToRoutineHome(context: context),
                child: _TemplatesTile(),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: GestureDetector(
                onTap: () => _showNewBottomSheet(),
                child: _SettingsTile(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _QuestionsForCoachSection(),
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

  void _showNewBottomSheet() {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    displayBottomSheet(
        context: context,
        child: Column(children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const FaIcon(FontAwesomeIcons.play, size: 18),
            horizontalTitleGap: 6,
            title: Text("Log new session",
                style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.of(context).pop();
              logEmptyRoutine(context: context);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 18),
            horizontalTitleGap: 6,
            title: Text("Log past session",
                style: Theme.of(context).textTheme.bodyLarge),
            onTap: () {
              Navigator.of(context).pop();
              showDatetimeRangePicker(
                  context: context,
                  onChangedDateTimeRange: (DateTimeRange datetimeRange) {
                    Navigator.of(context).pop();
                    final logName =
                        "${timeOfDay(datetime: datetimeRange.start)} Session";
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
                    navigateWithSlideTransition(
                        context: context,
                        child: PastRoutineLogEditorScreen(log: log));
                  });
            },
          ),
          const SizedBox(height: 10),
          LabelDivider(
            label: "Don't know what to train?",
            labelColor: isDarkMode ? darkOnSurfaceVariant : Colors.black,
            dividerColor: darkDivider,
          ),
          const SizedBox(height: 6),
          ListTile(
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 10,
            title: TRKRCoachTextWidget("Describe your workout",
                style: GoogleFonts.ubuntu(
                    color: vibrantGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
            onTap: () {
              Navigator.of(context).pop();
              _switchToAIContext();
            },
          ),
        ]));
  }

  void _switchToAIContext() async {
    final result = await navigateWithSlideTransition(
        context: context,
        child: const TRKRCoachChatScreen()) as RoutineTemplateDto?;
    if (result != null) {
      if (mounted) {
        final log = result.toLog();
        final arguments =
            RoutineLogArguments(log: log, editorMode: RoutineEditorMode.log);
        if (mounted) {
          navigateToRoutineLogEditor(context: context, arguments: arguments);
        }
      }
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

class _QuestionsForCoachSection extends StatelessWidget {
  const _QuestionsForCoachSection();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isDarkMode ? darkSurfaceContainer : Colors.grey.shade300,
                ),
                child: Icon(
                  Icons.person,
                  color:
                      isDarkMode ? darkOnSurfaceVariant : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Questions for your Coach",
                style: GoogleFonts.ubuntu(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? darkOnSurface : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _QuestionItem(
            question: "Should I take any supplements for muscle growth?",
            icon: FontAwesomeIcons.arrowRight,
            onTap: () {
              // Navigate to coach chat with this question
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TRKRCoachChatScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _QuestionItem(
            question: "How do I know if I'm progressing?",
            icon: FontAwesomeIcons.arrowRight,
            onTap: () {
              // Navigate to coach chat with this question
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TRKRCoachChatScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _QuestionItem(
            question:
                "Are free weights better than machines for building muscle?",
            icon: FontAwesomeIcons.arrowRight,
            onTap: () {
              // Navigate to coach chat with this question
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TRKRCoachChatScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _QuestionItem(
            question: "How can I improve my workout recovery?",
            icon: FontAwesomeIcons.arrowRight,
            onTap: () {
              // Navigate to coach chat with this question
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TRKRCoachChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuestionItem extends StatelessWidget {
  const _QuestionItem({
    required this.question,
    required this.icon,
    required this.onTap,
  });

  final String question;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? darkSurfaceVariant : Colors.white,
          borderRadius: BorderRadius.circular(radiusMD),
          border: Border.all(
            color: isDarkMode ? darkBorder : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question,
                style: GoogleFonts.ubuntu(
                  fontSize: 14,
                  color: isDarkMode ? darkOnSurface : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(
              icon,
              size: 12,
              color: isDarkMode ? darkOnSurfaceVariant : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
