import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/screens/preferences/routine_schedule_planner/routine_frequency_planner.dart';
import 'package:tracker_app/screens/preferences/routine_schedule_planner/routine_day_planner.dart';

import '../../../dtos/routine_template_dto.dart';


class RoutineSchedulePlannerHome extends StatefulWidget {

  final RoutineTemplateDto template;

  const RoutineSchedulePlannerHome({super.key, required this.template});

  @override
  State<RoutineSchedulePlannerHome> createState() => _RoutineSchedulePlannerHomeState();
}

class _RoutineSchedulePlannerHomeState extends State<RoutineSchedulePlannerHome> with TickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          dividerColor: Colors.transparent,
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(
                child: Text("Days",
                    style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
            Tab(
                child: Text("Frequency",
                    style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
    ]),
        const SizedBox(height: 30),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics().parent,
            controller: _tabController,
            children: [
              RoutineDayPlanner(template: widget.template),
              RoutineFrequencyPlanner(template: widget.template),
            ],
          ),
        )
      ],
    );
  }
}
