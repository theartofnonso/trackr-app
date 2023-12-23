import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../screens/muscle_insights_screen.dart';

class PieChartWidget extends StatelessWidget {
  final List<MapEntry<MuscleGroupFamily, int>> segments;

  const PieChartWidget({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    final isSegmentsNotEmpty = segments.any((entry) => entry.value > 0);

    return isSegmentsNotEmpty
        ? AspectRatio(
            aspectRatio: 1.8,
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 35,
                sections: showingSections(),
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.only(top: 22.0),
            child: const FaIcon(FontAwesomeIcons.chartPie, color: tealBlueLighter, size: 120),
          );
  }

  List<PieChartSectionData> showingSections() {
    final textStyle = GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: [const Shadow(color: Colors.white60, blurRadius: 1)],
    );

    return List.generate(5, (index) {
      switch (index) {
        case 0:
          return PieChartSectionData(
            color: generateDecoration(index: index),
            value: segments[0].value.toDouble(),
            title: '${segments[0].value}',
            radius: 70,
            titleStyle: textStyle,
          );
        case 1:
          return PieChartSectionData(
            color: generateDecoration(index: index),
            value: segments[1].value.toDouble(),
            title: '${segments[1].value}',
            radius: 60,
            titleStyle: textStyle,
          );
        case 2:
          return PieChartSectionData(
            color: generateDecoration(index: index),
            value: segments[2].value.toDouble(),
            title: '${segments[2].value}',
            radius: 50,
            titleStyle: textStyle,
          );
        case 3:
          return PieChartSectionData(
            color: generateDecoration(index: index),
            value: segments[3].value.toDouble(),
            title: '${segments[3].value}',
            radius: 40,
            titleStyle: textStyle,
          );
        case 4:
          return PieChartSectionData(
            color: generateDecoration(index: index),
            value: segments[4].value.toDouble(),
            title: '${segments[4].value}',
            radius: 30,
            titleStyle: textStyle,
          );
        default:
          throw Error();
      }
    });
  }
}
