import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/graph/chart_point_dto.dart';

enum ChartUnitType {
  kg, lbs, reps, min, hrs
}

class LineChartWidget extends StatelessWidget {
  final List<ChartPointDto> chartPoints;
  final List<String> dateTimes;
  final ChartUnitType unit;

  const LineChartWidget({super.key, required this.chartPoints, required this.dateTimes, required this.unit});

  static const List<Color> gradientColors = [
    Colors.blue,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  interval: 500,
                  getTitlesWidget: leftTitleWidgets,
                  reservedSize: 50,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            // minY: 0,
            // maxY: 3.0,
            lineBarsData: [
              LineChartBarData(
                  spots: chartPoints.map((point) => FlSpot(point.x, point.y)).toList(),
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
    );
  }


  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );
   // print(value);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text("$value ${unit.name}", style: style),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(dateTimes[value.toInt()], style: style),
    );
  }
}
