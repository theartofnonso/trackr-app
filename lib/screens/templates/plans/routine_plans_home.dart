import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/appsync/routine_template_plan_dto.dart';
import 'package:tracker_app/screens/editors/routine_plan_editor_screen.dart';
import 'package:tracker_app/utils/navigation_utils.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/empty_states/routine_empty_state.dart';
import '../../../widgets/information_containers/information_container_with_background_image.dart';

class RoutinePlansHome extends StatelessWidget {
  const RoutinePlansHome({super.key});

  @override
  Widget build(BuildContext context) {
    final templatePlans = Provider.of<ExerciseAndRoutineController>(context, listen: true).templatePlans;

    final children = templatePlans.map((templatePlan) => _TemplatePlanWidget(templatePlanDto: templatePlan)).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_routine_plans_screen",
        onPressed: () {
          navigateWithSlideTransition(context: context, child: RoutinePlanEditorScreen());
        },
        backgroundColor: sapphireDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle, // Use BoxShape.circle for circular borders
            gradient: SweepGradient(
              colors: [vibrantGreen, vibrantBlue],
              stops: const [0, 1],
              center: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(child: const FaIcon(FontAwesomeIcons.plus, color: Colors.black, size: 24)),
        ),
      ),
      body: SafeArea(
          minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackgroundInformationContainer(
                  image: 'images/woman_leg_press.jpg',
                  content: "Ask TRKR Coach for a personalized plan for you, structured towards a specific goal.",
                  textStyle: GoogleFonts.ubuntu(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade800, Colors.blue.shade800, Colors.transparent],
                  )),
              const SizedBox(height: 16),
              templatePlans.isNotEmpty
                  ? Expanded(
                      child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          children: children),
                    )
                  : const RoutineEmptyState(message: '"Tap the + button to create workout program"'),
            ],
          )),
    );
  }
}

class _TemplatePlanWidget extends StatelessWidget {
  final RoutineTemplatePlanDto templatePlanDto;

  const _TemplatePlanWidget({required this.templatePlanDto});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToRoutineTemplatePlan(context: context, templatePlan: templatePlanDto),
      child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: sapphireDark80, borderRadius: BorderRadius.circular(10), boxShadow: [
            BoxShadow(color: sapphireDark.withOpacity(0.5), spreadRadius: 5, blurRadius: 7, offset: const Offset(0, 3))
          ]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              templatePlanDto.name,
              style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const Spacer(),
            Text(
              "${templatePlanDto.templates.length} ${pluralize(word: "Session", count: 3)} / Week",
              style: GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Divider(color: sapphireLighter, endIndent: 10),
            const SizedBox(height: 8),
            Text(
              "2 out of 4 weeks",
              style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
            ),
          ])),
    );
  }
}
