import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/graph/chart_point_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../colors.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/string_utils.dart';

class LineChartWidget extends StatelessWidget {
  final List<ChartPointDto> chartPoints;
  final ExtraLinesData? extraLinesData;
  final List<String> dateTimes;
  final ChartUnit unit;
  final double? maxY;
  final double interval;

  const LineChartWidget(
      {super.key,
      required this.chartPoints,
      required this.dateTimes,
      required this.unit,
      this.extraLinesData, this.maxY, this.interval = 10});

  static const List<Color> gradientColors = [
    Colors.white,
    vibrantBlue,
  ];

  @override
  Widget build(BuildContext context) {

    return chartPoints.isNotEmpty
        ? Center(
            child: AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(LineChartData(
                maxY: maxY,
                  minY: 0,
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
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        getTitlesWidget: _bottomTitleWidgets,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  extraLinesData: extraLinesData,
                  lineBarsData: [
                    LineChartBarData(
                        isStepLineChart: true,
                        spots: chartPoints.map((point) {
                          return FlSpot(point.x.toDouble(), unit == ChartUnit.weight ? weightWithConversion(value: point.y) : point.y.toDouble());
                        }).toList(),
                        gradient: const LinearGradient(
                          colors: gradientColors,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [gradientColors[0].withOpacity(0.1), gradientColors[1].withOpacity(0.2)],
                          ),
                        ),
                        isCurved: true)
                  ])),
            ),
          )
        : const Center(child: FaIcon(FontAwesomeIcons.chartSimple, color: sapphireDark, size: 120));
  }

  double _interval() {
    final points = chartPoints.map((point) => point.y).toList();
    final min = points.min.toDouble();
    final max = points.max.toDouble();
    double interval = max - min;
    if (interval >= 1000) {
      interval = 1000;
    } else if (interval >= 500) {
      interval = 500;
    } else if (interval >= 100) {
      interval = 100;
    } else if (interval >= 50) {
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
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta, enabled: false),
      axisSide: meta.axisSide,
      child: Text(_weightTitle(value: value), style: style),
    );
  }

  String _weightTitle({required double value}) {
      if (unit == ChartUnit.weight) {
        return volumeInKOrM(value);
      } else if (unit == ChartUnit.duration) {
        return Duration(milliseconds: value.toInt()).msDigital();
      }

    return "${value.toInt()}";
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final modifiedDateTimes = dateTimes.length == 1 ? [...dateTimes, ...dateTimes] : dateTimes;
    final style = GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      fontSize: 10,
    );
    return SideTitleWidget(
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      axisSide: meta.axisSide,
      child: Text(modifiedDateTimes[value.toInt()], style: style),
    );
  }
}
