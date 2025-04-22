import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/utils/dialog_utils.dart';

import '../../colors.dart';
import '../../dtos/appsync/routine_plan_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../utils/general_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/routine/preview/routine_template_grid_item.dart';

class RoutinePlanEditorScreen extends StatefulWidget {
  static const routeName = '/routine-plan-editor';

  final RoutinePlanDto? plan;

  const RoutinePlanEditorScreen({super.key, this.plan});

  @override
  State<RoutinePlanEditorScreen> createState() => _RoutinePlanEditorScreenState();
}

class _RoutinePlanEditorScreenState extends State<RoutinePlanEditorScreen> {
  late TextEditingController _planNameController;
  late TextEditingController _planNotesController;

  bool _validateRoutinePlanInputs() {
    final exerciseProviders = Provider.of<ExerciseLogController>(context, listen: false);
    final exercises = exerciseProviders.exerciseLogs;

    if (_planNameController.text.isEmpty) {
      _showSnackbar('Please provide a name for this plan');
      return false;
    }
    if (exercises.isEmpty) {
      _showSnackbar("Plan must have workout template(s)");
      return false;
    }
    return true;
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const FaIcon(FontAwesomeIcons.circleInfo), message: message);
  }

  void _createRoutinePlan() async {
    if (!_validateRoutinePlanInputs()) return;

    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
    final exercises = exerciseLogController.exerciseLogs;

    final template = RoutineTemplateDto(
        id: "",
        name: _planNameController.text,
        exerciseTemplates: exercises,
        notes: _planNotesController.text,
        owner: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

    await Provider.of<ExerciseAndRoutineController>(context, listen: false).saveTemplate(templateDto: template);
    _navigateBack();
  }

  void _updateRoutinePlan() {
    if (!_validateRoutinePlanInputs()) return;
    final template = widget.plan;
    if (template != null) {
      showBottomSheetWithMultiActions(
          context: context,
          description: "Do you want to update workout?",
          leftAction: _closeDialog,
          rightAction: () {
            _closeDialog();
            // final updatedTemplate = _getUpdatedRoutineTemplate(template: template);
            // _doUpdateRoutinePlan(updatedPlan: updatedTemplate);
            //_navigateBack(plan: updatedTemplate);
          },
          leftActionLabel: 'Cancel',
          rightActionLabel: 'Update',
          isRightActionDestructive: true,
          title: "Update plan");
    }
  }

  void _doUpdateRoutinePlan() async {
    final plan = widget.plan;

    if (plan != null) {
      final planProvider = Provider.of<ExerciseAndRoutineController>(context, listen: false);

      final planToBeUpdated = plan.copyWith(
          name: _planNameController.text.trim(), notes: _planNotesController.text.trim(), updatedAt: DateTime.now());

      await planProvider.updatePlan(planDto: planToBeUpdated);
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _navigateBack({RoutinePlanDto? plan}) {
    context.pop(plan);
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final plan = widget.plan;

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final routineTemplates =
        exerciseAndRoutineController.templates.where((template) => template.planId == plan?.id).toList();

    final children = routineTemplates
        .mapIndexed(
          (index, template) => RoutineTemplateGridItemWidget(template: template.copyWith(notes: template.notes)),
        )
        .toList();

    if (exerciseAndRoutineController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackbar(exerciseAndRoutineController.errorMessage);
      });
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: AppBar(
              leading: IconButton(icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28), onPressed: context.pop),
              actions: [
                IconButton(onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.solidSquarePlus)),
                if (routineTemplates.length > 1)
                  IconButton(onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.barsStaggered)),
              ]),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeGradient(context: context),
            ),
            child: SafeArea(
              bottom: false,
              minimum: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
              child: GestureDetector(
                onTap: _dismissKeyboard,
                child: Column(
                  spacing: 20,
                  children: [
                    Column(
                      spacing: 10,
                      children: [
                        TextField(
                          controller: _planNameController,
                          cursorColor: isDarkMode ? Colors.white : Colors.black,
                          decoration: InputDecoration(
                            hintText: "New plan",
                          ),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.w400,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 14),
                        ),
                        TextField(
                          controller: _planNotesController,
                          cursorColor: isDarkMode ? Colors.white : Colors.black,
                          decoration: InputDecoration(
                            hintText: "Notes",
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.w400,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 14),
                        ),
                      ],
                    ),
                    if (routineTemplates.isNotEmpty)
                      Expanded(
                        child: GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            children: children),
                      ),
                    if (routineTemplates.isNotEmpty)
                      SafeArea(
                        minimum: EdgeInsets.all(10),
                        child: SizedBox(
                            width: double.infinity,
                            child: OpacityButtonWidget(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                buttonColor: vibrantGreen,
                                label: plan != null ? "Update Plan" : "Create Plan",
                                onPressed: plan != null ? _updateRoutinePlan : _createRoutinePlan)),
                      ),
                    if (routineTemplates.isEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: const NoListEmptyState(
                              message: "Tap the + button to start adding workout templates to your plan"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    _planNameController = TextEditingController();
    _planNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _planNotesController.dispose();
    super.dispose();
  }
}
