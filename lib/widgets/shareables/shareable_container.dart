import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/widgets/shareables/achievement_share.dart';
import 'package:tracker_app/widgets/shareables/log_milestone_shareable.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable.dart';
import 'package:tracker_app/widgets/shareables/pbs_shareable_shareable.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_lite.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../../enums/muscle_group_enums.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/shareables_utils.dart';
import '../buttons/text_button_widget.dart';

class ShareableContainer extends StatefulWidget {
  final RoutineLogDto log;
  final Map<MuscleGroupFamily, double> frequencyData;

  const ShareableContainer({super.key, required this.log, required this.frequencyData});

  @override
  State<ShareableContainer> createState() => _ShareableContainerState();
}

class _ShareableContainerState extends State<ShareableContainer> {
  final _controller = PageController(viewportFraction: 1);

  bool isMultipleOfFive(int number) {
    return number % 5 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final allLogs = routineLogController.routineLogs;

    final achievements = routineLogController.calculateNewLogAchievements();

    List<Widget> achievementsShareAssets = [];
    final achievementsShareAssetsKeys = [];

    for (final achievement in achievements) {
      final key = GlobalKey();
      final shareable =
          AchievementShare(globalKey: key, achievementDto: achievement, width: MediaQuery.of(context).size.width - 20);
      achievementsShareAssets.add(shareable);
      achievementsShareAssetsKeys.add(key);
    }

    List<Widget> pbShareAssets = [];
    final pbShareAssetsKeys = [];

    for (final exerciseLog in widget.log.exerciseLogs) {
      final pastExerciseLogs =
          routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);
      final pbs = calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
      final setAndPBs = groupBy(pbs, (pb) => pb.set);
      for (final setAndPB in setAndPBs.entries) {
        final pbs = setAndPB.value;
        for (final pb in pbs) {
          final key = GlobalKey();
          final shareable = PBsShareable(set: setAndPB.key, pbDto: pb, globalKey: key);
          pbShareAssets.add(shareable);
          pbShareAssetsKeys.add(key);
        }
      }
    }

    final pages = [
      ...achievementsShareAssets,
      if (isMultipleOfFive(allLogs.length)) LogMilestoneShareable(label: "${allLogs.length}th"),
      ...pbShareAssets,
      RoutineLogShareable(log: widget.log, frequencyData: widget.frequencyData),
      RoutineLogShareableLite(log: widget.log, frequencyData: widget.frequencyData),
    ];

    final pagesKeys = [
      ...achievementsShareAssetsKeys,
      if (isMultipleOfFive(allLogs.length)) logMilestoneShareableKey,
      ...pbShareAssetsKeys,
      routineLogShareableKey,
      routineLogShareableLiteKey,
    ];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: Container(
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
              const SizedBox(height: 30),
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  itemCount: pages.length,

                  itemBuilder: (_, index) {
                    return pages[index % pages.length];
                  },
                ),
              ),
              // Expanded(
              //   child: ListView.separated(
              //       shrinkWrap: true,
              //       scrollDirection: Axis.horizontal,
              //       physics: const PageScrollPhysics(),
              //       itemBuilder: (context, index) => pages[index],
              //       separatorBuilder: (context, index) => const SizedBox(width: 10),
              //       itemCount: pages.length),
              // ),
              // SingleChildScrollView(
              //     controller: _controller,
              //     scrollDirection: Axis.horizontal,
              //     physics: const PageScrollPhysics(),
              //     child: Row(children: pages)),
              const Spacer(),
              SmoothPageIndicator(
                controller: _controller,
                count: pages.length,
                effect: const ExpandingDotsEffect(activeDotColor: vibrantGreen),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CTextButton(
                    onPressed: () {
                      captureImage(key: pagesKeys[_controller.page!.toInt()], pixelRatio: 3.5);
                      Navigator.of(context).pop();
                    },
                    label: "Share",
                    buttonColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    buttonBorderColor: Colors.transparent),
              )
            ],
          ),
        ),
      ),
    );
  }
}
