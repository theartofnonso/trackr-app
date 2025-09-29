import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/appsync/routine_plan_dto.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/string_utils.dart';
import '../../icons/custom_icon.dart';

class RoutinePlanGridItemWidget extends StatelessWidget {
  final RoutinePlanDto plan;

  const RoutinePlanGridItemWidget({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exerciseAndRoutineController =
        Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final routineTemplates = exerciseAndRoutineController.templates
        .where((template) => template.planId == plan.id)
        .toList();

    final exerciseTemplates = routineTemplates
        .expand((routineTemplate) => routineTemplate.exerciseTemplates);
    return GestureDetector(
      onTap: () => navigateToRoutinePlanPreview(context: context, plan: plan),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12)),
          child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  plan.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                Column(
                  spacing: 6,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        CustomIcon(
                          FontAwesomeIcons.personWalking,
                          color: vibrantGreen,
                          width: 20,
                          height: 20,
                          iconSize: 10.5,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          "${exerciseTemplates.length} ${pluralize(word: "Exercise", count: exerciseTemplates.length)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        CustomIcon(
                          FontAwesomeIcons.hashtag,
                          color: vibrantBlue,
                          width: 20,
                          height: 20,
                          iconSize: 10.5,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          "${routineTemplates.length} ${pluralize(word: "Session", count: routineTemplates.length)}",
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ],
                )
              ])),
    );
  }
}
