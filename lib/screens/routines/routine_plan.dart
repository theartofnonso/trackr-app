import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/db/routine_plan_dto.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/calendar/calendar_logs.dart';
import '../../widgets/chip_one.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/empty_states/not_found.dart';
import '../../widgets/icons/custom_icon.dart';
import '../../widgets/routine/preview/routine_template_grid_item.dart';

class RoutinePlanScreen extends StatefulWidget {
  static const routeName = '/routine_plan_screen';

  final String id;
  final RoutinePlanDto? plan;

  const RoutinePlanScreen({super.key, required this.id}) : plan = null;

  const RoutinePlanScreen.withPlan({super.key, required this.plan}) : id = "";

  @override
  State<RoutinePlanScreen> createState() => _RoutinePlanScreenState();
}

class _RoutinePlanScreenState extends State<RoutinePlanScreen> {
  bool _loading = false;

  DateTime? _selectedCalendarDate;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    // Use plan provided directly or fallback to loaded plan
    final plan = widget.plan;

    if (plan == null) return const NotFound();

    final exerciseAndRoutineController =
        Provider.of<ExerciseAndRoutineController>(context, listen: true);

    final routineTemplates = plan.templates;

    final logs = routineTemplates
        .map((template) => exerciseAndRoutineController.whereLogsWithTemplateId(
            templateId: template.id))
        .expand((logs) => logs)
        .toList();

    final children = routineTemplates
        .mapIndexed(
          (index, template) => RoutineTemplateGridItemWidget(
              template: template.copyWith(notes: template.notes),
              onTap: () => navigateToRoutineTemplatePreview(
                  context: context, template: template)),
        )
        .toList();

    final exercises = routineTemplates
        .expand((routineTemplate) => routineTemplate.exerciseTemplates);

    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? darkBackground : Colors.white,
          ),
          child: SafeArea(
            minimum: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              right: 10,
              left: 10,
            ),
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name,
                        style: GoogleFonts.ubuntu(
                            fontSize: 20,
                            height: 1.5,
                            fontWeight: FontWeight.w900)),
                    Row(spacing: 12, children: [
                      ChipOne(
                        label:
                            '${exercises.length} ${pluralize(word: "Exercise", count: exercises.length)}',
                        child: CustomIcon(FontAwesomeIcons.personWalking,
                            color: vibrantGreen),
                      ),
                      ChipOne(
                          label:
                              '${routineTemplates.length} ${pluralize(word: "Session", count: routineTemplates.length)}',
                          child: CustomIcon(FontAwesomeIcons.hashtag,
                              color: vibrantBlue)),
                    ]),
                    Text(plan.notes.isNotEmpty ? plan.notes : "No notes",
                        style: GoogleFonts.ubuntu(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.black,
                            height: 1.8,
                            fontWeight: FontWeight.w400)),
                    Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Calendar(
                          onSelectDate: (date) =>
                              _onSelectCalendarDateTime(date: date),
                          logs: logs,
                        ),
                        CalendarLogs(
                            dateTime: _selectedCalendarDate ?? DateTime.now()),
                      ],
                    ),
                    routineTemplates.isNotEmpty
                        ? GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            children: children)
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 50.0),
                            child: const NoListEmptyState(
                                message:
                                    "It might feel quiet now, but your workout templates will soon appear here."),
                          ),
                  ]),
            ),
          ),
        ),
        // Overlay close button
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? darkSurface.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.squareXmark,
                size: 20,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    ));
  }

  void _hideLoadingScreen() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onSelectCalendarDateTime({required DateTime date}) {
    setState(() {
      _selectedCalendarDate = date;
    });
  }
}
