import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/graph/chart_point_dto.dart';
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

  const LineChartWidget(
      {super.key,
      required this.chartPoints,
      required this.dateTimes,
      required this.unit,
      this.extraLinesData, this.maxY});

  static const List<Color> gradientColors = [
    Colors.white,
    vibrantBlue,
  ];

  @override
  Widget build(BuildContext context) {

    final isWeight = unit == ChartUnit.kg || unit == ChartUnit.lbs;

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
                        interval: 10,
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
                          return FlSpot(point.x, isWeight ? weightWithConversion(value: point.y) : point.y);
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
        : const Center(child: FaIcon(FontAwesomeIcons.chartSimple, color: sapphireLighter, size: 120));
  }

  double _interval() {
    final points = chartPoints.map((point) => point.y).toList();
    final min = points.min;
    final max = points.max;
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
      child: Text(_weightTitle(chartUnit: unit, value: value), style: style),
    );
  }

  String _weightTitle({required ChartUnit chartUnit, required double value}) {
      if (chartUnit == ChartUnit.kg || chartUnit == ChartUnit.lbs) {
        return volumeInKOrM(value);
      }

    return "${value.toInt()} ${unit.label}";
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
