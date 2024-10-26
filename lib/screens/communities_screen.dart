import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {

  @override
  Widget build(BuildContext context) {

     return const _EmptyState();

  }

  @override
  void initState() {
    super.initState();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            minimum: const EdgeInsets.all(10.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const FaIcon(
                FontAwesomeIcons.trophy,
                color: Colors.white12,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text("It might feel quiet now, but new fun challenges and activities from TRKR will soon appear here.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                      color: Colors.white38, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600))
            ])),
      ),
    );
  }
}
