import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../utils/general_utils.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import '../../widgets/routine/preview/routine_template_grid_item.dart';

class RoutinePlansScreen extends StatelessWidget {
  static const routeName = '/routine_plans_screen';

  const RoutinePlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final templates = exerciseAndRoutineController.templates.sublist(0, 4);

    final children = templates
        .mapIndexed(
          (index, template) => RoutineTemplateGridItemWidget(
              template: template.copyWith(
                  notes:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")),
        )
        .toList();

    return Scaffold(
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
            GestureDetector(
              onTap: () {},
              child: BackgroundInformationContainer(
                image: 'images/lace.jpg',
                containerColor: Colors.green.shade800,
                content: "Pathways are journeys designed to guide you toward a fitness goal.",
                textStyle: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                ctaContent: 'Generate training pathways',
              ),
            ),
            Text("Functional Fitness Pathway",
                style: GoogleFonts.ubuntu(fontSize: 26, height: 1.5, fontWeight: FontWeight.w900)),
            SingleChildScrollView(
              child: Row(spacing: 12, children: [
                _Chip(
                    label: '6 Weeks',
                    color: Colors.yellow,
                    child: FaIcon(
                      FontAwesomeIcons.calendarWeek,
                      color: Colors.yellow,
                      size: 14,
                    )),
                _Chip(
                    label: '4 Sessions',
                    color: Colors.deepOrange,
                    child: FaIcon(
                      FontAwesomeIcons.calendarDay,
                      color: Colors.deepOrange,
                      size: 14,
                    )),
                _Chip(
                  label: '4 Exercises',
                  color: vibrantGreen,
                  child: Image.asset(
                    'icons/dumbbells.png',
                    fit: BoxFit.contain,
                    height: 16,
                    color: vibrantGreen, // Adjust the height as needed
                  ),
                )
              ]),
            ),
            Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                style: GoogleFonts.ubuntu(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    height: 1.5,
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
}

class _Chip extends StatelessWidget {
  final String label;
  final Widget child;
  final Color color;

  const _Chip({required this.label, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: child,
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
