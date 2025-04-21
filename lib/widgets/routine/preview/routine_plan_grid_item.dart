import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../colors.dart';
import '../../../dtos/appsync/routine_plan_dto.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/string_utils.dart';

class RoutinePlanGridItemWidget extends StatelessWidget {
  final RoutinePlanDto plan;

  const RoutinePlanGridItemWidget({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineTemplates = plan.routineTemplates;
    final exerciseTemplates = routineTemplates.expand((routineTemplate) => routineTemplate.exerciseTemplates);
    return GestureDetector(
      onTap: () => navigateToRoutinePlanPreview(context: context, plan: plan),
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, borderRadius: BorderRadius.circular(5)),
          child: Column(spacing: 8, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              plan.name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(plan.notes,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: GoogleFonts.ubuntu(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                    height: 1.5,
                    fontWeight: FontWeight.w400)),
            const Spacer(),
            Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: vibrantGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Image.asset(
                        'icons/dumbbells.png',
                        fit: BoxFit.contain,
                        height: 14,
                        color: vibrantGreen, // Adjust the height as needed
                      ),
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
                    Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: vibrantBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.hashtag,
                          color: vibrantBlue,
                          size: 11,
                        ),
                      ),
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
