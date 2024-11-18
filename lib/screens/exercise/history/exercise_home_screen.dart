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
import '../../../dtos/exercise_variant_dto.dart';
import '../../../enums/exercise/core_movements_enum.dart';
import '../../../enums/exercise/exercise_equipment_enum.dart';
import '../../../enums/exercise/exercise_metrics_enums.dart';
import '../../../enums/exercise/exercise_modality_enum.dart';
import '../../../enums/exercise/exercise_movement_enum.dart';
import '../../../enums/exercise/exercise_position_enum.dart';
import '../../../enums/exercise/exercise_stance_enum.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/exercise_utils.dart';
import '../../../widgets/buttons/opacity_button_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final exercise = exerciseAndRoutineController.whereExercise(id: widget.id);

    if (exercise == null) return const NotFound();

    final completedExerciseLogs = completedExercises(exerciseLogs: _exerciseLogs);

    final heaviestSetVolumeRecord = heaviestSetVolume(exerciseLogs: completedExerciseLogs);

    final heaviestWeightRecord = heaviestWeight(exerciseLogs: completedExerciseLogs);

    final longestDurationRecord = longestDuration(exerciseLogs: completedExerciseLogs);

    final mostRepsSetRecord = mostRepsInSet(exerciseLogs: completedExerciseLogs);

    final mostRepsSessionRecord = mostRepsInSession(exerciseLogs: completedExerciseLogs);

    final firstVariant = _exerciseLogs.isNotEmpty ? _exerciseLogs.first.exerciseVariant : exercise.defaultVariant();

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
                        width: 1.0,         // Border width
                      ),// Adjust the radius as needed
                    ),
                    child: Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      children: [
                        OpacityButtonWidget(
                          label: firstVariant.equipment.name.toUpperCase(),
                          buttonColor: vibrantGreen,
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: vibrantGreen),
                          onPressed: () => _showExerciseEquipmentPicker(equipment: exercise.equipment, exerciseVariant: firstVariant),
                        ),
                        if (exercise.modes.length > 1)
                          OpacityButtonWidget(
                            label: firstVariant.mode.name.toUpperCase(),
                            buttonColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            textStyle:
                            GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent),
                            onPressed: () => _showExerciseModalityPicker(modes: exercise.modes, exerciseVariant: firstVariant),
                          ),
                        if (exercise.metrics.length > 1)
                          OpacityButtonWidget(
                            label: firstVariant.metric.name.toUpperCase(),
                            buttonColor: vibrantBlue,
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            textStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: vibrantBlue),
                            onPressed: () => _showExerciseMetricPicker(metrics: exercise.metrics, exerciseVariant: firstVariant),
                          ),
                        if (exercise.positions.length > 1 &&
                            (firstVariant.coreMovement == CoreMovement.push ||
                                firstVariant.coreMovement == CoreMovement.pull))
                          OpacityButtonWidget(
                            label: firstVariant.position.name.toUpperCase(),
                            buttonColor: Colors.cyanAccent,
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            textStyle:
                            GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.cyanAccent),
                            onPressed: () => _showExercisePositionPicker(positions: exercise.positions, exerciseVariant: firstVariant),
                          ),
                        if (exercise.stances.length > 1)
                          OpacityButtonWidget(
                            label: firstVariant.stance.name.toUpperCase(),
                            buttonColor: Colors.purpleAccent,
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            textStyle:
                            GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.purpleAccent),
                            onPressed: () => _showExerciseStancePicker(stances: exercise.stances, exerciseVariant: firstVariant),
                          ),
                        if (exercise.movements.length > 1)
                          OpacityButtonWidget(
                            label: firstVariant.movement.name.toUpperCase(),
                            buttonColor: Colors.orange,
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            textStyle:
                            GoogleFonts.ubuntu(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange),
                            onPressed: () => _showExerciseMovementPicker(movements: exercise.movements, exerciseVariant: firstVariant),
                          ),
                      ],
                    ),
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

  void _showExerciseEquipmentPicker({required List<ExerciseEquipment> equipment, required ExerciseVariantDTO exerciseVariant}) {
    showExerciseEquipmentPicker(
        context: context,
        initialEquipment: exerciseVariant.equipment,
        equipment: equipment,
        onSelect: (newEquipment) {});
  }

  void _showExerciseModalityPicker({required List<ExerciseModality> modes, required ExerciseVariantDTO exerciseVariant}) {
    showExerciseModalityPicker(
        context: context,
        initialModality: exerciseVariant.mode,
        modes: modes,
        onSelect: (newMode) {});
  }

  void _showExerciseMetricPicker({required List<ExerciseMetric> metrics, required ExerciseVariantDTO exerciseVariant}) {
    showExerciseMetricPicker(
        context: context,
        initialMetric: exerciseVariant.metric,
        metrics: metrics,
        onSelect: (newMetric) {});
  }

  void _showExercisePositionPicker({required List<ExercisePosition> positions, required ExerciseVariantDTO exerciseVariant}) {
    showExercisePositionPicker(
        context: context,
        initialPosition: exerciseVariant.position,
        positions: positions,
        onSelect: (newPosition) {});
  }

  void _showExerciseStancePicker({required List<ExerciseStance> stances, required ExerciseVariantDTO exerciseVariant}) {
    showExerciseStancePicker(
        context: context,
        initialStance: exerciseVariant.stance,
        stances: stances,
        onSelect: (newStance) {});
  }

  void _showExerciseMovementPicker({required List<ExerciseMovement> movements, required ExerciseVariantDTO exerciseVariant}) {
    showExerciseMovementPicker(
        context: context,
        initialMovement: exerciseVariant.movement,
        movements: movements,
        onSelect: (newMovement) {});
  }
}
