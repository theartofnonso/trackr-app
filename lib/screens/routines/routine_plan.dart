import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../utils/general_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/chip_one.dart';
import '../../widgets/routine/preview/routine_template_grid_item.dart';

class RoutinePlanScreen extends StatefulWidget {
  static const routeName = '/routine_plan_screen';

  final String id;

  const RoutinePlanScreen({super.key, required this.id});

  @override
  State<RoutinePlanScreen> createState() => _RoutinePlanScreenState();
}

class _RoutinePlanScreenState extends State<RoutinePlanScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final plans = exerciseAndRoutineController.plans;

    final plan = plans[0];

    final children = plan.routineTemplates
        .mapIndexed(
          (index, template) => RoutineTemplateGridItemWidget(
              template: template.copyWith(
                  notes:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")),
        )
        .toList();

    final exercises = plan.routineTemplates.expand((routineTemplate) => routineTemplate.exerciseTemplates);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
            onPressed: context.pop,
          ),
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
                        label:
                            '${plan.routineTemplates.length} ${pluralize(word: "Session", count: plan.routineTemplates.length)}',
                        color: Colors.deepOrange,
                        child: FaIcon(
                          FontAwesomeIcons.calendarDay,
                          color: Colors.deepOrange,
                          size: 14,
                        )),
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
                    crossAxisCount: 1,
                    childAspectRatio: 2,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    children: children),
              ]),
            ),
          ),
        ));
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}
