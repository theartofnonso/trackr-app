import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../enums/exercise_type_enums.dart';
import 'chips/chip_1.dart';

class PBsScreen extends StatelessWidget {
  final void Function() onPressed;
  final List<PBViewModel> pbViewModels;

  const PBsScreen({super.key, required this.pbViewModels, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    int initialDelay = 0;
    final pbs = pbViewModels
        .map((pbViewModel) => Animate(
            effects: const [FadeEffect(), SlideEffect(begin: Offset(-0.5, 0), end: Offset.zero)],
            delay: Duration(milliseconds: initialDelay += 300),
            child: PBListTile(pbViewModel: pbViewModel)))
        .toList();

    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.85),
        body: SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Personal Bests",
                    style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 30),
                Expanded(
                    child: pbs.length > 1
                        ? ListView.separated(
                            padding: const EdgeInsets.only(bottom: 250),
                            itemBuilder: (BuildContext context, int index) => pbs[index],
                            separatorBuilder: (BuildContext context, int index) => const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Divider(
                                    thickness: 1.0,
                                    color: tealBlueLight,
                                  ),
                                ),
                            itemCount: pbs.length)
                        : Animate(
                            effects: const [FadeEffect(), ScaleEffect()],
                            delay: const Duration(milliseconds: 300),
                            child: PBListTile(pbViewModel: pbViewModels.first, single: true))),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: CTextButton(
                        onPressed: onPressed,
                        label: "Close",
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        buttonColor: Colors.transparent))
              ]),
        ));
  }
}

class PBListTile extends StatelessWidget {
  final PBViewModel pbViewModel;
  final bool single;

  const PBListTile({super.key, required this.pbViewModel, this.single = false});

  @override
  Widget build(BuildContext context) {
    final pbValue = switch (pbViewModel.exercise.type) {
      ExerciseType.weights => "${pbViewModel.set.value1}${weightLabel()} x ${pbViewModel.set.value2}",
      ExerciseType.duration => Duration(milliseconds: pbViewModel.set.value1.toInt()).secondsOrMinutesOrHours(),
      ExerciseType.bodyWeight => "x ${pbViewModel.set.value2}",
      ExerciseType.assistedBodyWeight => "-${pbViewModel.set.value1}${weightLabel()} x ${pbViewModel.set.value2}",
    };

    final pbs = pbViewModel.pbs
        .map((pb) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChipOne(color: tealBlueLight, label: pb.name),
            ))
        .toList();

    return Column(
        mainAxisAlignment: single ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: single ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(pbViewModel.exercise.name,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800), textAlign: single ? TextAlign.center : TextAlign.start),
          const SizedBox(height: 8),
          Text(pbValue, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: single ? MainAxisAlignment.center : MainAxisAlignment.start, children: pbs),
        ]);
  }
}
