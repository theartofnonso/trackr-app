import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/graph/chart_point_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../colors.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/string_utils.dart';

class LineChartWidget extends StatelessWidget {
  final List<ChartPointDto> chartPoints;
  final ExtraLinesData? extraLinesData;
  final List<String> periods;
  final ChartUnit unit;
  final double interval;
  final double? aspectRation;
  final List<Color> colors;
  final double reservedSize;

  const LineChartWidget(
      {super.key,
      required this.chartPoints,
      required this.periods,
      required this.unit,
      this.extraLinesData,
      this.interval = 10,
      this.aspectRation, this.colors = const [], this.reservedSize = 40});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return chartPoints.isNotEmpty
        ? Center(
            child: AspectRatio(
              aspectRatio: aspectRation ?? 1.5,
              child: LineChart(
                  duration: Duration(milliseconds: 500),
                  LineChartData(
                  gridData: FlGridData(drawVerticalLine: false),
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
                        reservedSize: reservedSize,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        getTitlesWidget: periods.isNotEmpty ? _bottomTitleWidgets : (_, __) => SizedBox.shrink(),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  extraLinesData: extraLinesData,
                  lineBarsData: [
                    LineChartBarData(
                        spots: chartPoints.map((point) {
                          return FlSpot(point.x.toDouble(), point.y.toDouble());
                        }).toList(),
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        gradient: colors.isNotEmpty ? LinearGradient(colors: colors) : null,
                        isCurved: true)
                  ])),
            ),
          )
        : const Center(child: FaIcon(FontAwesomeIcons.chartSimple, color: sapphireDark, size: 120));
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    final style = GoogleFonts.ubuntu(
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
    if (unit == ChartUnit.weight || unit == ChartUnit.numberBig) {
      return volumeInKOrM(value, showLessThan1k: false);
    } else if (unit == ChartUnit.duration) {
      return Duration(milliseconds: value.toInt()).msDigital();
    }

    return "${value.toInt()}";
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final modifiedDateTimes = periods.length == 1 ? [...periods, ...periods] : periods;
    final style = GoogleFonts.ubuntu(
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
