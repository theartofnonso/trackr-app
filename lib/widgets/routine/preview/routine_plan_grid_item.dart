import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../colors.dart';
import '../../../dtos/db/routine_plan_dto.dart';
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

    final exerciseTemplates = plan.templates
        .expand((routineTemplate) => routineTemplate.exerciseTemplates);
    return GestureDetector(
      onTap: () => navigateToRoutinePlanPreview(context: context, plan: plan),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDarkMode ? darkSurfaceContainer : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(radiusMD)),
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
                          "${plan.templates.length} ${pluralize(word: "Session", count: plan.templates.length)}",
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
