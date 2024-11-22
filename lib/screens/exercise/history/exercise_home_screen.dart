import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/screens/exercise/history/exercise_chart_screen.dart';
import 'package:tracker_app/screens/exercise/history/history_screen.dart';

import '../../../dtos/abstract_class/exercise_dto.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../../enums/exercise/exercise_configuration_key.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../widgets/buttons/opacity_button_widget.dart';
import '../../../widgets/pickers/exercise_configurations_picker.dart';

class ExerciseHomeScreen extends StatefulWidget {
  static const routeName = "/exercise_home_screen";

  final String id;

  const ExerciseHomeScreen({super.key, required this.id});

  @override
  State<ExerciseHomeScreen> createState() => _ExerciseHomeScreenState();
}

class _ExerciseHomeScreenState extends State<ExerciseHomeScreen> {
  List<ExerciseLogDTO> _exerciseLogs = [];

  late Map<ExerciseConfigurationKey, ExerciseConfigValue> _selectedConfigurations;

  late ExerciseDTO _baseExercise;

  late ExerciseAndRoutineController _exerciseAndRoutineController;

  @override
  Widget build(BuildContext context) {

    final completedExerciseLogs = completedExercises(exerciseLogs: _exerciseLogs);

    final firstVariant =
        _exerciseLogs.isNotEmpty ? _exerciseLogs.first.exerciseVariant : _baseExercise.defaultVariant();

    final configurationOptionsWidgets = _baseExercise.configurationOptions.keys.where((configKey) {
      final configOptions = _baseExercise.configurationOptions[configKey]!;
      return configOptions.length > 1;
    }).map((ExerciseConfigurationKey configKey) {
      final configValue = firstVariant.configurations[configKey]!;
      return OpacityButtonWidget(
        label: configValue.displayName.toLowerCase(),
        buttonColor: vibrantGreen,
        padding: EdgeInsets.symmetric(horizontal: 0),
        textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 12, color: vibrantGreen),
        onPressed: () => _showConfigurationPicker(configKey: configKey, baseExercise: _baseExercise),
      );
    }).toList();

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: sapphireDark80,
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: context.pop,
            ),
            title: Text(_baseExercise.name,
                style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            bottom: TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                    child: Text("Summary",
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                Tab(
                    child: Text("History",
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sapphireDark80,
                  sapphireDark,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 18.0),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Makes the background transparent
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: sapphireLighter, // Border color
                        width: 1.0, // Border width
                      ), // Adjust the radius as needed
                    ),
                    child: Wrap(runSpacing: 8, spacing: 8, children: configurationOptionsWidgets),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ExerciseChartScreen(
                          exerciseVariant: firstVariant,
                          exerciseLogs: completedExerciseLogs,
                        ),
                        HistoryScreen(exerciseLogs: completedExerciseLogs),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _showConfigurationPicker({required ExerciseConfigurationKey configKey, required ExerciseDTO baseExercise}) {
    final options = baseExercise.configurationOptions[configKey]!;
    displayBottomSheet(
      context: context,
      height: 300,
      child: ExerciseConfigurationsPicker<dynamic>(
        configurationKey: configKey,
        initialConfig: _selectedConfigurations[configKey],
        configurationOptions: options,
        onSelect: (configuration) {
          Navigator.of(context).pop();
          setState(() {
            _selectedConfigurations[configKey] = configuration;
            _exerciseLogs = _exerciseAndRoutineController.filterExerciseLogsByIdAndConfigurations(exerciseId: widget.id, configurations: _selectedConfigurations);
          });
        }, // Provide descriptions if available
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    _baseExercise = _exerciseAndRoutineController.whereExercise(id: widget.id);

    _selectedConfigurations = _baseExercise.defaultVariant().configurations;

    _exerciseLogs = _exerciseAndRoutineController.filterExerciseLogsByIdAndConfigurations(exerciseId: widget.id, configurations: _selectedConfigurations);

  }
}
