import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';
import 'package:tracker_app/urls.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_plan_dto.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../enums/routine_preview_type_enum.dart';
import '../../models/RoutinePlan.dart';
import '../../shared_prefs.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/https_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/chip_one.dart';
import '../../widgets/empty_states/not_found.dart';
import '../../widgets/routine/preview/routine_template_grid_item.dart';

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

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    if (exerciseAndRoutineController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: exerciseAndRoutineController.errorMessage);
      });
    }

    final plan = _plan;

    if (plan == null) return const NotFound();

    final routineTemplates =
        exerciseAndRoutineController.templates.where((template) => template.planId == plan.id).toList();

    final children = routineTemplates
        .mapIndexed(
          (index, template) => RoutineTemplateGridItemWidget(template: template.copyWith(notes: template.notes)),
        )
        .toList();

    final exercises = routineTemplates.expand((routineTemplate) => routineTemplate.exerciseTemplates);

    final menuActions = [
      MenuItemButton(
          onPressed: () {},
          leadingIcon: FaIcon(FontAwesomeIcons.solidPenToSquare, size: 16),
          child: Text("Edit", style: GoogleFonts.ubuntu())),
      MenuItemButton(
          leadingIcon: FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: 16),
          onPressed: () => _showShareBottomSheet(templates: routineTemplates),
          child: Text("Share", style: GoogleFonts.ubuntu())),
      MenuItemButton(
        onPressed: () {
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
        },
        leadingIcon: FaIcon(
          FontAwesomeIcons.trash,
          size: 16,
          color: Colors.redAccent,
        ),
        child: Text("Delete", style: GoogleFonts.ubuntu(color: Colors.redAccent)),
      )
    ];

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
            onPressed: context.pop,
          ),
          actions: [
            plan.owner == SharedPrefs().userId
                ? MenuAnchor(
                    builder: (BuildContext context, MenuController controller, Widget? child) {
                      return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          size: 24,
                        ),
                        tooltip: 'Show menu',
                      );
                    },
                    menuChildren: menuActions,
                  )
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
                SingleChildScrollView(
                  child: Row(spacing: 12, children: [
                    ChipOne(
                      label: '${exercises.length} ${pluralize(word: "Exercise", count: exercises.length)}',
                      color: vibrantGreen,
                      child: Image.asset(
                        'icons/dumbbells.png',
                        fit: BoxFit.contain,
                        height: 16,
                        color: vibrantGreen, // Adjust the height as needed
                      ),
                    ),
                    ChipOne(
                        label:
                            '${routineTemplates.length} ${pluralize(word: "Session", count: routineTemplates.length)}',
                        color: vibrantBlue,
                        child: FaIcon(
                          FontAwesomeIcons.hashtag,
                          color: vibrantBlue,
                          size: 14,
                        )),
                  ]),
                ),
                Text(plan.notes,
                    style: GoogleFonts.ubuntu(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black,
                        height: 1.8,
                        fontWeight: FontWeight.w400)),
                SingleChildScrollView(
                  child: Row(
                    spacing: 8,
                    children: [
                      OpacityButtonWidget(
                          label: "Week 1",
                          trailing: FaIcon(
                            FontAwesomeIcons.solidSquareCheck,
                            size: 14,
                          )),
                      OpacityButtonWidget(
                          label: "Week 2",
                          trailing: FaIcon(
                            FontAwesomeIcons.solidSquareCheck,
                            size: 14,
                          )),
                      OpacityButtonWidget(
                          label: "Week 3",
                          trailing: FaIcon(
                            FontAwesomeIcons.solidSquareCheck,
                            size: 14,
                          )),
                    ],
                  ),
                ),
                Calendar(
                  onSelectDate: (_) {},
                  dateTime: DateTime.now(),
                ),
                GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    children: children),
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

  void _deleteRoutinePlan({required RoutinePlanDto plan}) async {
    try {
      await Provider.of<ExerciseAndRoutineController>(context, listen: false).removePlan(planDto: plan);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Unable to remove plan");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
    });
  }

  void _showShareBottomSheet({required List<RoutineTemplateDto> templates}) {
    final plan = _plan;

    if (plan != null) {
      final workoutPlanLink = "$shareableRoutinePlanUrl/${plan.id}";

      StringBuffer routinePlanText = StringBuffer();

      routinePlanText.writeln(plan.name);

      if (plan.notes.isNotEmpty) {
        routinePlanText.writeln("\n Notes: ${plan.notes}");
      }

      for (final routineTemplate in templates) {
        final routineTemplateText = copyRoutineAsText(
            routineType: RoutinePreviewType.template,
            name: routineTemplate.name,
            notes: routineTemplate.notes,
            exerciseLogs: routineTemplate.exerciseTemplates);

        routinePlanText.writeln(routineTemplateText);
      }

      displayBottomSheet(
          context: context,
          isScrollControlled: true,
          child: SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const FaIcon(
                  FontAwesomeIcons.link,
                  size: 18,
                ),
                horizontalTitleGap: 10,
                title: Text(
                  "Copy as Link",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                  maxLines: 1,
                ),
                subtitle: Text(workoutPlanLink),
                onTap: () {
                  Posthog().capture(eventName: PostHogAnalyticsEvent.shareRoutineTemplateAsLink.displayName);
                  HapticFeedback.heavyImpact();
                  final data = ClipboardData(text: workoutPlanLink);
                  Clipboard.setData(data).then((_) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      showSnackbar(
                          context: context,
                          icon: const FaIcon(FontAwesomeIcons.solidSquareCheck),
                          message: "Plan link copied");
                    }
                  });
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const FaIcon(
                  FontAwesomeIcons.copy,
                  size: 18,
                ),
                horizontalTitleGap: 6,
                title: Text("Copy as Text", style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text("${plan.name}..."),
                onTap: () {
                  Posthog().capture(eventName: PostHogAnalyticsEvent.shareRoutinePlanAsText.displayName);
                  HapticFeedback.heavyImpact();
                  final data = ClipboardData(text: routinePlanText.toString());
                  Clipboard.setData(data).then((_) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      showSnackbar(
                          context: context,
                          icon: const FaIcon(FontAwesomeIcons.solidSquareCheck),
                          message: "Plan copied");
                    }
                  });
                },
              ),
            ]),
          ));
    }
  }

  void _loadData() {
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    _plan = exerciseAndRoutineController.planWhere(id: widget.id);
    if (_plan == null) {
      _loading = true;
      getAPI(endpoint: "/routine-plans/${widget.id}").then((data) {
        if (data.isNotEmpty) {
          final json = jsonDecode(data);
          final body = json["data"];
          final routinePlan = body["getRoutinePlan"];
          if (routinePlan != null) {
            final plan = RoutinePlan.fromJson(routinePlan);
            setState(() {
              _loading = false;
              _plan = RoutinePlanDto.toDto(plan);
            });
          } else {
            setState(() {
              _loading = false;
            });
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}
