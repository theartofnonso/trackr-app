import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

import '../../colors.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../calender_heatmaps/calendar_heatmap.dart';
import '../routine/editors/set_headers/weight_reps_set_header.dart';

class CalendarHeatMapEmptyState extends StatelessWidget {
  final List<DateTime> dates;
  const CalendarHeatMapEmptyState({super.key, required this.dates});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 1,
        childAspectRatio: 1.2,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: [
          CalendarHeatMap(dates: [DateTime.now()], spacing: 4)
        ]);
  }
}
