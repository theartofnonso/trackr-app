import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/widgets/shareables/achievement_share.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_four.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_one.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_three.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_two.dart';

import '../../controllers/routine_log_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../../enums/muscle_group_enums.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/shareables_utils.dart';
import '../buttons/text_button_widget.dart';

class RoutineLogShareableContainer extends StatefulWidget {
  final RoutineLogDto log;
  final Map<MuscleGroupFamily, double> frequencyData;

  const RoutineLogShareableContainer({super.key, required this.log, required this.frequencyData});

  @override
  State<RoutineLogShareableContainer> createState() => _RoutineLogShareableContainerState();
}

class _RoutineLogShareableContainerState extends State<RoutineLogShareableContainer> {
  final _controller = PageController();

  bool isMultipleOfFive(int number) {
    return number % 5 == 0;
  }

  @override
  Widget build(BuildContext context) {

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final allLogs = routineLogController.routineLogs;

    final achievements = routineLogController.calculateLogAchievements();

    List<Widget> achievementsShareAssets = [];
    final achievementsShareAssetsKeys = [];

    for (final achievement in achievements) {
      final key = GlobalKey();
      final shareable = AchievementShare(globalKey: key, achievementDto: achievement, width: MediaQuery.of(context).size.width - 20);
      achievementsShareAssets.add(shareable);
      achievementsShareAssetsKeys.add(key);
    }

    List<Widget> pbShareAssets = [];
    final pbShareAssetsKeys = [];

    for (final exerciseLog in widget.log.exerciseLogs) {
      final pbs = calculatePBs(context: context, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
      final setAndPBs = groupBy(pbs, (pb) => pb.set);
      for (final setAndPB in setAndPBs.entries) {
        final pbs = setAndPB.value;
        for (final pb in pbs) {
          final key = GlobalKey();
          final shareable = RoutineLogShareableThree(set: setAndPB.key, pbDto: pb, globalKey: key);
          pbShareAssets.add(shareable);
          pbShareAssetsKeys.add(key);
        }
      }
    }

    final pages = [
      ...achievementsShareAssets,
      if(isMultipleOfFive(allLogs.length)) RoutineLogShareableFour(label: "${allLogs.length}th"),
      ...pbShareAssets,
      RoutineLogShareableOne(log: widget.log, frequencyData: widget.frequencyData),
      RoutineLogShareableTwo(log: widget.log, frequencyData: widget.frequencyData),
    ];

    final pagesKeys = [
      ...achievementsShareAssetsKeys,
      routineLogShareableFourKey,
      ...pbShareAssetsKeys,
      routineLogShareableOneKey,
      routineLogShareableTwoKey,
      routineLogShareableThreeKey
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SingleChildScrollView(controller: _controller, scrollDirection: Axis.horizontal, child: Row(children: pages)),
        const SizedBox(height: 20),
        SmoothPageIndicator(
          controller: _controller,
          count: pages.length,
          effect: const ExpandingDotsEffect(activeDotColor: Colors.green),
        ),
        const SizedBox(height: 30),
        CTextButton(
            onPressed: () {
              captureImage(key: pagesKeys[_controller.page!.toInt()], pixelRatio: 3.5);
              Navigator.of(context).pop();
            },
            label: "Share",
            buttonColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            buttonBorderColor: Colors.transparent)
      ],
    );
  }
}
