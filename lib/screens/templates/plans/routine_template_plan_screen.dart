import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/appsync/routine_template_plan_dto.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/routine_utils.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../../widgets/empty_states/routine_empty_state.dart';
import '../../../widgets/routine/preview/routine_template_grid_item_widget.dart';
import '../../empty_state_screens/not_found.dart';

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

  bool _minimized = true;

  List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen, messages: _messages);

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

    final templates = templatePlan.templates
        .map((template) => RoutineTemplateGridItemWidget(
            template: template, scheduleSummary: scheduledDaysSummary(template: template)))
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
                                "${templatePlan.templates.length} ${pluralize(word: "Workouts/Week", count: templatePlan.templates.length)}",
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
                templatePlan.templates.isNotEmpty
                    ? Expanded(
                        child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            children: templates),
                      )
                    : const RoutineEmptyState(
                        message: "It might feel quiet now, but your workouts will soon appear here."),
              ],
            ),
          ),
        ));
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  void _loadData() {
    // final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    // _templatePlan = exerciseAndRoutineController.templateWhere(id: widget.id);
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

    final routineTemplates = Provider.of<ExerciseAndRoutineController>(context, listen: false).templates;

    _templatePlan = RoutineTemplatePlanDto(
        id: "",
        name: "4-Week Muscle Mummy",
        notes: "This is a 4-wek plan focusing on your upper and lowe body to build muscle in all areas.",
        templates: routineTemplates,
        owner: SharedPrefs().userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
}
