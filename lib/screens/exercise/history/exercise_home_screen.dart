import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/screens/exercise/history/exercise_chart_screen.dart';
import 'package:tracker_app/screens/exercise/history/history_screen.dart';

import '../../../dtos/exercise_dto.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../widgets/buttons/opacity_button_widget.dart';
import '../../../widgets/pickers/exercise/exercise_configurations_picker.dart';
import '../../empty_state_screens/not_found.dart';

class ExerciseHomeScreen extends StatefulWidget {
  static const routeName = "/exercise_home_screen";

  final String id;

  const ExerciseHomeScreen({super.key, required this.id});

  @override
  State<ExerciseHomeScreen> createState() => _ExerciseHomeScreenState();
}

class _ExerciseHomeScreenState extends State<ExerciseHomeScreen> {
  List<ExerciseLogDTO> _exerciseLogs = [];
  List<ExerciseLogDTO> _filteredExerciseLogs = [];

  late Map<String, dynamic> _selectedConfigurations;

  @override
  Widget build(BuildContext context) {
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final exercise = exerciseAndRoutineController.whereExercise(id: widget.id);

    if (exercise == null) return const NotFound();

    final completedExerciseLogs = completedExercises(exerciseLogs: _filteredExerciseLogs);

    final heaviestSetVolumeRecord = heaviestSetVolume(exerciseLogs: completedExerciseLogs);

    final heaviestWeightRecord = heaviestWeight(exerciseLogs: completedExerciseLogs);

    final longestDurationRecord = longestDuration(exerciseLogs: completedExerciseLogs);

    final mostRepsSetRecord = mostRepsInSet(exerciseLogs: completedExerciseLogs);

    final mostRepsSessionRecord = mostRepsInSession(exerciseLogs: completedExerciseLogs);

    final firstVariant =
        _filteredExerciseLogs.isNotEmpty ? _filteredExerciseLogs.first.exerciseVariant : exercise.defaultVariant();

    final configurationOptionsWidgets = exercise.configurationOptions.keys.map((String configKey) => OpacityButtonWidget(
      label: configKey.toUpperCase(),
      buttonColor: Colors.redAccent,
      padding: EdgeInsets.symmetric(horizontal: 0),
      textStyle:
      GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
      onPressed: () => _showConfigurationPicker(configKey: configKey, baseExercise: exercise),
    )).toList() ?? [];

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: sapphireDark80,
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: context.pop,
            ),
            title: Text(exercise.name,
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
                    child: Wrap(
                        runSpacing: 8,
                        spacing: 8,
                        children: configurationOptionsWidgets),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ExerciseChartScreen(
                          heaviestWeight: heaviestWeightRecord,
                          heaviestSet: heaviestSetVolumeRecord,
                          longestDuration: longestDurationRecord,
                          mostRepsSet: mostRepsSetRecord,
                          mostRepsSession: mostRepsSessionRecord,
                          exerciseVariant: firstVariant,
                          // to BE FIXED
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

  void _showConfigurationPicker({required String configKey, required ExerciseDTO baseExercise}) {
    final options = baseExercise.configurationOptions[configKey]!;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ExerciseConfigurationsPicker<dynamic>(
          label: configKey,
          initialConfig: _selectedConfigurations[configKey],
          configurationOptions: options,
          onSelect: (configuration) {
            Navigator.of(context).pop();
            setState(() {
              _selectedConfigurations[configKey] = configuration;
            });
          }, // Provide descriptions if available
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    _exerciseLogs = exerciseAndRoutineController.exerciseLogsById[widget.id] ?? [];
   // _selectedConfigurations = Map<String, dynamic>.from(widget..exerciseVariant.configurations);

  }
}
