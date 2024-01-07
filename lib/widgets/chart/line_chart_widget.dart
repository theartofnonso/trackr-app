import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/graph/chart_point_dto.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../app_constants.dart';

enum ChartUnitLabel {
  kg, lbs, reps, mins, hrs, yd, mi,
}

class LineChartWidget extends StatelessWidget {
  final List<ChartPointDto> chartPoints;
  final List<String> dateTimes;
  final ChartUnitLabel unit;

  const LineChartWidget({super.key, required this.chartPoints, required this.dateTimes, required this.unit});

  static const List<Color> gradientColors = [
    Colors.blue,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {

    return chartPoints.isNotEmpty ? Center(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: LineChart(LineChartData(
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _leftTitleWidgets,
                  reservedSize: 50,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: _bottomTitleWidgets,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            lineBarsData: [
              LineChartBarData(
                  spots: chartPoints.map((point) => FlSpot(point.x, weightWithConversion(value: point.y))).toList(),
                  gradient: const LinearGradient(
                    colors: gradientColors,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                    ),
                  ),
                  isCurved: true)
            ])),
      ),
    ) : const Center(child: FaIcon(FontAwesomeIcons.chartSimple, color: tealBlueLighter, size: 120));
  }

  double _interval() {
    final points = chartPoints.map((point) => point.y).toList();
    final min = points.min;
    final max = points.max;
    double interval = max - min;
    if(interval >= 1000) {
      interval = 1000;
    } else if(interval >= 500) {
      interval = 500;
    } else if(interval >= 100) {
      interval = 100;
    } else if(interval >= 50) {
      interval = 50;
    } else {
      interval = 10;
    }
    return interval;
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      fontSize: 9,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text("${value.toInt()} ${unit.name}", style: style),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final modifiedDateTimes = dateTimes.length == 1 ? [...dateTimes, ...dateTimes] : dateTimes;
    final style = GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(modifiedDateTimes[value.toInt()], style: style),
    );
  }
}
