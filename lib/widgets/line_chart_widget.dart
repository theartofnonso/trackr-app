import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/weightPoint.dart';

class LineChartWidget extends StatelessWidget {
  final List<WeightPoint> points;

  const LineChartWidget({super.key, required this.points});

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
            titlesData: const FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              // bottomTitles: AxisTitles(
              //   sideTitles: SideTitles(
              //     showTitles: true,
              //     reservedSize: 30,
              //     interval: 1,
              //     getTitlesWidget: bottomTitleWidgets,
              //   ),
              // ),
              // leftTitles: AxisTitles(
              //   sideTitles: SideTitles(
              //     showTitles: true,
              //     interval: 1,
              //     getTitlesWidget: leftTitleWidgets,
              //     reservedSize: 42,
              //   ),
              // ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            lineBarsData: [
          LineChartBarData(
            spots: points.map((point) => FlSpot(point.x, point.y)).toList(),
            gradient: const LinearGradient(
              colors: gradientColors,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
              ),
            ),
            isCurved: true
          )
        ])),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }
}
