// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/db/routine_template_dto.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/routine/preview/routine_template_grid_item.dart';

class RoutineTemplatesScreen extends StatefulWidget {
  static const routeName = '/routine_templates_screen';

  const RoutineTemplatesScreen({super.key});

  @override
  State<RoutineTemplatesScreen> createState() => _RoutineTemplatesScreenState();
}

class _RoutineTemplatesScreenState extends State<RoutineTemplatesScreen> {
  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Consumer<ExerciseAndRoutineController>(builder: (_, provider, __) {
      final templates = List<RoutineTemplateDto>.from(provider.templates);

      final children = templates
          .map((template) => RoutineTemplateGridItemWidget(template: template))
          .toList();

      return Scaffold(
          body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? darkBackground : Colors.white,
            ),
            child: SafeArea(
              minimum: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                right: 10,
                left: 10,
              ),
              bottom: false,
              child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    children.isNotEmpty
                        ? Expanded(
                            child: GridView.count(
                                crossAxisCount: 2,
                                childAspectRatio: 1,
                                mainAxisSpacing: 10.0,
                                crossAxisSpacing: 10.0,
                                children: children),
                          )
                        : Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: const NoListEmptyState(
                                  message:
                                      "It might feel quiet now, but templates created will appear here."),
                            ),
                          ),
                  ]),
            ),
          ),
          // Overlay close button
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? darkSurface.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.squareXmark,
                  size: 20,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ));
    });
  }
}
