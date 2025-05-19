import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_plan_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/viewmodels/routine_plan_arguments.dart';
import '../../dtos/viewmodels/routine_template_arguments.dart';
import '../../shared_prefs.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/calendar/calendar_logs.dart';
import '../../widgets/chip_one.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/empty_states/not_found.dart';
import '../../widgets/icons/custom_icon.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import '../../widgets/routine/preview/routine_template_grid_item.dart';
import '../AI/trkr_coach_chat_screen.dart';

class RoutinePlanScreen extends StatefulWidget {
  static const routeName = '/routine_plan_screen';

  final String id;

  const RoutinePlanScreen({super.key, required this.id});

  @override
  State<RoutinePlanScreen> createState() => _RoutinePlanScreenState();
}

class _RoutinePlanScreenState extends State<RoutinePlanScreen> {
  RoutinePlanDto? _plan;

  bool _loading = false;

  DateTime? _selectedCalendarDate;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final plan = _plan;

    if (plan == null) return const NotFound();

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    if (exerciseAndRoutineController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(context: context, message: exerciseAndRoutineController.errorMessage);
      });
    }

    final routineTemplates =
        exerciseAndRoutineController.templates.where((template) => template.planId == plan.id).toList();

    final logs = routineTemplates
        .map((template) => exerciseAndRoutineController.whereLogsWithTemplateId(templateId: template.id))
        .expand((logs) => logs)
        .toList();

    final children = routineTemplates
        .mapIndexed(
          (index, template) => RoutineTemplateGridItemWidget(
              template: template.copyWith(notes: template.notes),
              onTap: () => navigateToRoutineTemplatePreview(context: context, template: template)),
        )
        .toList();

    final exercises = routineTemplates.expand((routineTemplate) => routineTemplate.exerciseTemplates);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
            onPressed: context.pop,
          ),
          actions: [
            plan.owner == SharedPrefs().userId
                ? IconButton(onPressed: _showMenuBottomSheet, icon: FaIcon(Icons.more_vert_rounded))
                : const SizedBox.shrink()
          ],
        ),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 10, right: 10, left: 10),
            bottom: false,
            child: SingleChildScrollView(
              child: Column(spacing: 16, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(plan.name, style: GoogleFonts.ubuntu(fontSize: 20, height: 1.5, fontWeight: FontWeight.w900)),
                Row(spacing: 12, children: [
                  ChipOne(
                    label: '${exercises.length} ${pluralize(word: "Exercise", count: exercises.length)}',
                    child: CustomIcon(FontAwesomeIcons.personWalking, color: vibrantGreen),
                  ),
                  ChipOne(
                      label: '${routineTemplates.length} ${pluralize(word: "Session", count: routineTemplates.length)}',
                      child: CustomIcon(FontAwesomeIcons.hashtag, color: vibrantBlue)),
                ]),
                Text(plan.notes.isNotEmpty ? plan.notes : "No notes",
                    style: GoogleFonts.ubuntu(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black,
                        height: 1.8,
                        fontWeight: FontWeight.w400)),
                Calendar(
                  onSelectDate: (date) => _onSelectCalendarDateTime(date: date),
                  logs: logs,
                ),
                CalendarLogs(dateTime: _selectedCalendarDate ?? DateTime.now()),
                InformationContainerWithBackgroundImage(
                  image: 'images/man_pushup.PNG',
                  color: Colors.black,
                  subtitle: "Need a head start on what to train? We’ve got you covered. Tap to describe your workout.",
                  onTap: _switchToAIContext,
                  alignmentGeometry: Alignment.center,
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
                          message: "It might feel quiet now, but your workout templates will soon appear here."),
                    ),
              ]),
            ),
          ),
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

  void _deleteRoutinePlan({required RoutinePlanDto plan}) async {
    try {
      final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

      final routineTemplates =
          exerciseAndRoutineController.templates.where((template) => template.planId == plan.id).toList();

      await exerciseAndRoutineController.removePlan(planDto: plan);

      for (final template in routineTemplates) {
        final templateWithoutPlanId = template.copyWith(planId: "");
        await exerciseAndRoutineController.updateTemplate(template: templateWithoutPlanId);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context: context, message: "Unable to remove plan");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _navigateToRoutinePlanEditor() async {
    final plan = _plan;
    if (plan != null) {
      final copyOfPlan = plan.copyWith();
      final arguments = RoutinePlanArguments(plan: copyOfPlan);
      final updatedPlan = await navigateToRoutinePlanEditor(context: context, arguments: arguments);
      if (updatedPlan != null) {
        setState(() {
          _plan = updatedPlan;
        });
      }
    }
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

  void _showMenuBottomSheet() {
    final plan = _plan;

    displayBottomSheet(
        context: context,
        isScrollControlled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(
                FontAwesomeIcons.solidSquarePlus,
                size: 18,
              ),
              horizontalTitleGap: 6,
              title: Text("Add new workout", style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.of(context).pop();
                final arguments = RoutineTemplateArguments(planId: plan?.id ?? "");
                navigateToRoutineTemplateEditor(context: context, arguments: arguments);
              }),
          if (plan?.id != defaultPlanId)
            ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const FaIcon(
                  FontAwesomeIcons.penToSquare,
                  size: 18,
                ),
                horizontalTitleGap: 6,
                title: Text("Edit", style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToRoutinePlanEditor();
                }),
          if (plan?.id != defaultPlanId)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(
                FontAwesomeIcons.trash,
                size: 16,
                color: Colors.redAccent,
              ),
              horizontalTitleGap: 6,
              title: Text("Delete", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();

                if (plan != null) {
                  showBottomSheetWithMultiActions(
                      context: context,
                      title: "Delete plan?",
                      description: "Are you sure you want to delete this plan?",
                      leftAction: Navigator.of(context).pop,
                      rightAction: () {
                        context.pop();
                        _toggleLoadingState();
                        _deleteRoutinePlan(plan: plan);
                      },
                      leftActionLabel: 'Cancel',
                      rightActionLabel: 'Delete',
                      isRightActionDestructive: true);
                }
              },
            )
        ]));
  }

  void _switchToAIContext() async {
    final result =
        await navigateWithSlideTransition(context: context, child: const TRKRCoachChatScreen()) as RoutineTemplateDto?;
    if (result != null) {
      if (mounted) {
        _saveTemplate(context: context, template: result);
      }
    }
  }

  void _saveTemplate({required BuildContext context, required RoutineTemplateDto template}) async {
    final routineTemplate = template;
    final templateController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    await templateController.saveTemplate(templateDto: routineTemplate);
  }

  void _loadData() {
    if (widget.id == defaultPlanId) {
      _plan = RoutinePlanDto.defaultPlan;
    } else {
      final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
      _plan = exerciseAndRoutineController.planWhere(id: widget.id);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}
