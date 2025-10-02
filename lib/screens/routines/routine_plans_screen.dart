// ignore_for_file: unused_element

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/db/exercise_dto.dart';
import '../../dtos/db/routine_plan_dto.dart';
import '../../dtos/db/routine_template_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../utils/dialog_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/routine/preview/routine_plan_grid_item.dart';

class RoutinePlansScreen extends StatefulWidget {
  static const routeName = '/routine_plans_screen';

  const RoutinePlansScreen({super.key});

  @override
  State<RoutinePlansScreen> createState() => _RoutinePlansScreenState();
}

class _RoutinePlansScreenState extends State<RoutinePlansScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    return Consumer<ExerciseAndRoutineController>(builder: (_, provider, __) {
      final plans = List<RoutinePlanDto>.from(provider.plans);

      final children =
          plans.map((plan) => RoutinePlanGridItemWidget(plan: plan)).toList();

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
              color: isDarkMode ? darkBackground : Colors.white,
            ),
            child: SafeArea(
              minimum: const EdgeInsets.only(top: 10, right: 10, left: 10),
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
                                      "It might feel quiet now, but plans created will appear here."),
                            ),
                          ),
                  ]),
            ),
          ));
    });
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

  void _showSnackbar(String message, {Widget? icon}) {
    showSnackbar(context: context, message: message);
  }

  void _handleError() {
    _hideLoadingScreen();
    _showSnackbar(
      "Oops, I can only assist you with workout plans.",
      icon: TRKRCoachWidget(),
    );
  }

  Future<RoutinePlanDto?> _savePlan(
      {required BuildContext context, required RoutinePlanDto plan}) async {
    final planController =
        Provider.of<ExerciseAndRoutineController>(context, listen: false);
    final createdPlan = await planController.savePlan(planDto: plan);
    return createdPlan;
  }

  void _saveTemplate(
      {required BuildContext context,
      required RoutineTemplateDto template}) async {
    final templateController =
        Provider.of<ExerciseAndRoutineController>(context, listen: false);
    await templateController.saveTemplate(templateDto: template);
  }

  List<ExerciseLogDto> _createExerciseTemplates(
      List<String> exerciseIds, List<ExerciseDto> exercises) {
    return exerciseIds
        .map((exerciseId) {
          final exerciseInLibrary = exercises
              .firstWhereOrNull((exercise) => exercise.id == exerciseId);
          if (exerciseInLibrary == null) return null;
          return ExerciseLogDto(
              id: exerciseInLibrary.id,
              routineLogId: "",
              superSetId: "",
              exercise: exerciseInLibrary,
              notes: exerciseInLibrary.description ?? "",
              sets: [SetDto.newType(type: exerciseInLibrary.type)],
              createdAt: DateTime.now());
        })
        .whereType<ExerciseLogDto>()
        .toList();
  }
}
