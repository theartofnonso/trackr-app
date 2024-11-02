import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../controllers/challenge_log_controller.dart';
import 'active_challenges_screen.dart';
import 'challenges_screen.dart';

class ChallengesHomeScreen extends StatelessWidget {
  const ChallengesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final challenges = Provider.of<ChallengeLogController>(context, listen: true).logs;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: sapphireDark80,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                    child: Text("Challenges",
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                Tab(
                    child: Text("Active",
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
                children: [
                  const SizedBox(height: 22),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ChallengesScreen(challenges: challenges),
                        ActiveChallengesScreen(challenges: challenges)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
