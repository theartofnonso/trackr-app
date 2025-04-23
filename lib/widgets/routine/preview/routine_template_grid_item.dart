import 'package:flutter/material.dart';

import '../../../colors.dart';
import '../../../dtos/appsync/routine_template_dto.dart';
import '../../../utils/string_utils.dart';

class RoutineTemplateGridItemWidget extends StatelessWidget {
  final RoutineTemplateDto template;
  final void Function()? onTap;

  const RoutineTemplateGridItemWidget({super.key, required this.template, this.onTap});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final exercises = template.exerciseTemplates;

    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
          child: Column(spacing: 14, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Spacer(),
            Text(
              template.name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
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
                  "${exercises.length} ${pluralize(word: "Exercise", count: exercises.length)}",
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ])),
    );
  }
}
