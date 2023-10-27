import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/weightPoint.dart';

class LineChartWidget extends StatelessWidget {
  final List<WeightPoint> volumePoints;
  final List<String> dates;
  final List<int> weights;

  const LineChartWidget({super.key, required this.volumePoints, required this.dates, required this.weights});

  static const List<Color> gradientColors = [
    Colors.blue,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 2,
        child: LineChart(LineChartData(
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              // leftTitles: AxisTitles(
              //   sideTitles: SideTitles(
              //     showTitles: true,
              //     interval: 1,
              //     getTitlesWidget: leftTitleWidgets,
              //     reservedSize: 4
              //   ),
              // ),
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
            // maxY: 10,
            lineBarsData: [
              LineChartBarData(
                  spots: volumePoints.map((point) => FlSpot(point.x, point.y)).toList(),
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
    print(value.toInt());
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text("${weights[value.toInt()]}", style: style),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(dates[value.toInt()], style: style),
    );
  }
}
