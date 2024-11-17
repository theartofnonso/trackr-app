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
import '../../empty_state_screens/not_found.dart';

class ExerciseHomeScreen extends StatefulWidget {
  static const routeName = "/exercise_home_screen";

  final String exerciseName;

  const ExerciseHomeScreen({super.key, required this.exerciseName});

  @override
  State<ExerciseHomeScreen> createState() => _ExerciseHomeScreenState();
}

class _ExerciseHomeScreenState extends State<ExerciseHomeScreen> {
  ExerciseDTO? _exercise;

  Map<String, List<ExerciseLogDTO>>? _exerciseLogsByName;

  @override
  Widget build(BuildContext context) {
    final exercise = _exercise;

    if (exercise == null) return const NotFound();

    final exerciseLogs = _exerciseLogsByName?[exercise.name] ?? [];

    final completedExerciseLogs = completedExercises(exerciseLogs: exerciseLogs);

    final heaviestSetVolumeRecord = heaviestSetVolume(exerciseLogs: completedExerciseLogs);

    final heaviestWeightRecord = heaviestWeight(exerciseLogs: completedExerciseLogs);

    final longestDurationRecord = longestDuration(exerciseLogs: completedExerciseLogs);

    final mostRepsSetRecord = mostRepsInSet(exerciseLogs: completedExerciseLogs);

    final mostRepsSessionRecord = mostRepsInSession(exerciseLogs: completedExerciseLogs);

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
              child: TabBarView(
                children: [
                  ExerciseChartScreen(
                    heaviestWeight: heaviestWeightRecord,
                    heaviestSet: heaviestSetVolumeRecord,
                    longestDuration: longestDurationRecord,
                    mostRepsSet: mostRepsSetRecord,
                    mostRepsSession: mostRepsSessionRecord,
                    exerciseVariant: exercise.defaultVariant(), // to BE FIXED
                    exerciseLogs: completedExerciseLogs,
                  ),
                  HistoryScreen(exerciseLogs: completedExerciseLogs),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    _exerciseLogsByName = exerciseAndRoutineController.exerciseLogsByName;
    _exercise = exerciseAndRoutineController.whereExercise(name: widget.exerciseName) ;
  }
}
