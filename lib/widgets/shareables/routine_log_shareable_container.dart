import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_one.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_three.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_two.dart';

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

  @override
  Widget build(BuildContext context) {
    List<Widget> pbShareables = [];
    final pbShareableKeys = [];

    for (final exerciseLog in widget.log.exerciseLogs) {
      final setAndPBs =
          calculatePBs(context: context, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
      for (final setAndPB in setAndPBs.entries) {
        final pbs = setAndPB.value;
        for (final pb in pbs) {
          final key = GlobalKey();
          final shareable = RoutineLogShareableThree(set: setAndPB.key, pbDto: pb, globalKey: key);
          pbShareables.add(shareable);
          pbShareableKeys.add(key);
        }
      }
    }

    final pages = [
      ...pbShareables,
      RoutineLogShareableOne(log: widget.log, frequencyData: widget.frequencyData),
      RoutineLogShareableTwo(log: widget.log, frequencyData: widget.frequencyData),
    ];

    final pagesKeys = [
      ...pbShareableKeys,
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
            onPressed: () async {
              await captureImage(key: pagesKeys[_controller.page!.toInt()], pixelRatio: 3.5);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            label: "Share",
            buttonColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            buttonBorderColor: Colors.transparent)
      ],
    );
  }
}
