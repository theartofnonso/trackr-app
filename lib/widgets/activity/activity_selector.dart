import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../search_bar.dart';

class ActivitySelectorScreen extends StatelessWidget {
  const ActivitySelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // All, Strain, Recovery, Sleep
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
            onPressed: context.pop,
          ),
          title: Text("Select Activity".toUpperCase(),
              style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
          bottom: TabBar(
            isScrollable: true,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                  child: Text("All",
                      style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              Tab(
                  child: Text("Ball Sports",
                      style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              Tab(
                  child: Text("Martial Arts",
                      style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              Tab(
                  child: Text("Recreational",
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
          child: Stack(children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12),
                    child: CSearchBar(
                        hintText: "Search for activity",
                        onChanged: (_) => (),
                        onClear: () {},
                        controller: TextEditingController()),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ActivityListView(),
                        Center(child: Text('Strain Activities')),
                        Center(child: Text('Recovery Activities')),
                        Center(child: Text('Sleep Activities')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class ActivityListView extends StatelessWidget {
  final List<String> activities = [
    "Cycling",
    "Air Compression",
    "Air Compression (Normatec)",
    "Assault Bike",
    "Australian Rules Football",
    "Babywearing",
    "Badminton",
    "Barre",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.directions_bike), // Placeholder icon
          title: Text(activities[index]),
          onTap: () {
            // Handle tap event
          },
        );
      },
    );
  }
}