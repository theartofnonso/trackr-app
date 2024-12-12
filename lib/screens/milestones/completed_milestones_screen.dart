import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/widgets/milestones/milestone_grid_item.dart';

import '../../dtos/milestones/milestone_dto.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';

class CompletedMilestonesScreen extends StatelessWidget {
  final List<Milestone> milestones;

  const CompletedMilestonesScreen({super.key, required this.milestones});

  @override
  Widget build(BuildContext context) {
    final children = milestones.map((milestone) => MilestoneGridItem(milestone: milestone)).toList();

    return Scaffold(
        backgroundColor: Colors.transparent,
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
              minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                BackgroundInformationContainer(
                    image: 'images/woman_barbell.jpg',
                    containerColor: Colors.green.shade900,
                    content: "Crush your goals, one challenge at a time! Stay consistent, and unlock your best self!",
                    textStyle: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
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
                          child: const NoListEmptyState(
                              icon: FaIcon(
                                FontAwesomeIcons.trophy,
                                color: Colors.white12,
                                size: 48,
                              ),
                              message: "It might feel quiet now, but your completed milestones will soon appear here."),
                        ),
                      )
              ])),
        ));
  }
}
