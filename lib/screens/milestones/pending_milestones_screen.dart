import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/milestones/milestone_dto.dart';

import '../../utils/general_utils.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import '../../widgets/milestones/milestone_grid_item.dart';

class PendingMilestonesScreen extends StatelessWidget {
  final List<Milestone> milestones;

  const PendingMilestonesScreen({super.key, required this.milestones});

  @override
  Widget build(BuildContext context) {
    final children = milestones.map((milestone) => MilestoneGridItem(milestone: milestone)).toList();

    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
              minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                BackgroundInformationContainer(
                    image: 'images/man_woman.jpg',
                    containerColor: Colors.orange.shade900,
                    content: "Power up your weekly training sessions with fun challenges that fuel your motivation.",
                    textStyle: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha:0.9),
                    )),
                const SizedBox(height: 20),
                children.isNotEmpty
                    ? Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      children: children),
                )
                    : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: NoListEmptyState(
                        message:
                        "Hurray, you have successfully completed all milestones for ${DateTime.now().year}."),
                  ),
                )
              ])),
        ));
  }
}
