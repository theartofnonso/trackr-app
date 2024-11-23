import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/strings/loading_screen_messages.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/appsync/routine_template_plan_dto.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/routine_utils.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../../widgets/empty_states/not_found.dart';
import '../../../widgets/routine/preview/routine_template_grid_item_widget.dart';
import '../../../widgets/empty_states/no_list_empty_state.dart';

class RoutineTemplatePlanScreen extends StatefulWidget {
  static const routeName = '/routine_template_plan_screen';

  final String id;

  const RoutineTemplatePlanScreen({super.key, required this.id});

  @override
  State<RoutineTemplatePlanScreen> createState() => _RoutineTemplatePlanScreenState();
}

class _RoutineTemplatePlanScreenState extends State<RoutineTemplatePlanScreen> {
  RoutineTemplatePlanDto? _templatePlan;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen, messages: loadingTRKRCoachRoutineMessages);

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    if (exerciseAndRoutineController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: exerciseAndRoutineController.errorMessage);
      });
    }

    final templatePlan = _templatePlan;

    if (templatePlan == null) return const NotFound();

    final menuActions = [
      MenuItemButton(
        onPressed: _deleteRoutineTemplatePlan,
        leadingIcon: FaIcon(
          FontAwesomeIcons.trash,
          size: 16,
          color: Colors.redAccent,
        ),
        child: Text("Delete", style: GoogleFonts.ubuntu(color: Colors.redAccent)),
      )
    ];

    final templates = templatePlan.templates
        ?.map((template) => RoutineTemplateGridItemWidget(
            template: template, scheduleSummary: scheduledDaysSummary(template: template), templatePlanId: templatePlan.id))
        .toList();

    return Scaffold(
        floatingActionButton: templatePlan.owner == SharedPrefs().userId
            ? FloatingActionButton(
                heroTag: UniqueKey,
                onPressed: () {},
                backgroundColor: sapphireDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 24))
            : null,
        backgroundColor: sapphireDark,
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: context.pop,
          ),
          centerTitle: true,
          title: Text(templatePlan.name,
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
          actions: [
            MenuAnchor(
              style: MenuStyle(
                backgroundColor: WidgetStateProperty.all(sapphireDark80),
                surfaceTintColor: WidgetStateProperty.all(sapphireDark),
              ),
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
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Show menu',
                );
              },
              menuChildren: menuActions,
            )
          ],
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
                if (templatePlan.notes.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('"${templatePlan.notes}"',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                              color: Colors.white70,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),

                /// Keep this spacing for when notes isn't available
                if (templatePlan.notes.isEmpty)
                  const SizedBox(
                    height: 20,
                  ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5), // Use BorderRadius.circular for a rounded container
                    color: sapphireDark.withOpacity(0.4), // Set the background color
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Table(
                    border: const TableBorder.symmetric(inside: BorderSide(color: sapphireLighter, width: 2)),
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(
                            child: Text(
                                "${templatePlan.templates?.length ?? 0} ${pluralize(word: "Workout", count: templatePlan.templates?.length ?? 0)} | Week",
                                style:
                                    GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(
                            child: Text("4 Weeks",
                                style:
                                    GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                templatePlan.templates?.isNotEmpty ?? false
                    ? Expanded(
                        child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            children: templates ?? []),
                      )
                    : const NoListEmptyState(icon: FaIcon(FontAwesomeIcons.solidLightbulb, color: Colors.white70,), message: "It might feel quiet now, but your workouts will soon appear here.",),
              ],
            ),
          ),
        ));
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  void _deleteRoutineTemplatePlan() {
    final templatePlan = _templatePlan;
    if (templatePlan != null) {
      showBottomSheetWithMultiActions(
          context: context,
          title: "Delete workout plan?",
          description: "Are you sure you want to delete this workout plan?",
          leftAction: Navigator.of(context).pop,
          rightAction: () {
            context.pop();
            _showLoadingScreen();
            _deleteTemplate();
          },
          leftActionLabel: 'Cancel',
          rightActionLabel: 'Delete',
          isRightActionDestructive: true);
    }
  }

  void _deleteTemplate() async {
    final templatePlan = _templatePlan;
    if (templatePlan != null) {
      try {
        await Provider.of<ExerciseAndRoutineController>(context, listen: false).removeTemplatePlan(
            templatePlan: templatePlan);
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          showSnackbar(
              context: context, icon: const Icon(Icons.info_outline), message: "Unable to delete workout plan");
        }
      } finally {
        _hideLoadingScreen();
      }
    }
  }

  void _loadData() {
    final controller = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    _templatePlan = controller.templatePlanWhere(id: widget.id);
    // if (_templatePlan == null) {
    //   _loading = true;
    //   getAPI(endpoint: "/routine-template-plans/${widget.id}").then((data) {
    //     if (data.isNotEmpty) {
    //       final json = jsonDecode(data);
    //       final body = json["data"];
    //       final routineTemplate = body["getRoutineTemplate"];
    //       if (routineTemplate != null) {
    //         final routineTemplateDto = RoutineTemplate.fromJson(routineTemplate);
    //         setState(() {
    //           _loading = false;
    //           _templatePlan = routineTemplateDto.dto();
    //           _messages = [
    //             "Just a moment",
    //             "Loading workout, one set at a time",
    //             "Analyzing workout sets and reps",
    //             "Just a moment, loading workout"
    //           ];
    //         });
    //       } else {
    //         setState(() {
    //           _loading = false;
    //         });
    //       }
    //     }
    //   });
    // }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}
