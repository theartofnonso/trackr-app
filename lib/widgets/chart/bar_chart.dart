import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../../dtos/graph/chart_point_dto.dart';
import '../../enums/chart_unit_enum.dart';
import '../../utils/string_utils.dart';

class CustomBarChart extends StatelessWidget {
  final List<ChartPointDto> chartPoints;
  final List<String> periods;
  final ExtraLinesData? extraLinesData;
  final ChartUnit unit;
  final bool minify;

  const CustomBarChart({super.key, required this.chartPoints, required this.periods, this.extraLinesData, required this.unit, required this.minify});

  @override
  Widget build(BuildContext context) {
    return chartPoints.isNotEmpty
        ? BarChart(
            BarChartData(
              minY: 0,
              barTouchData: barTouchData,
              titlesData: titlesData,
              borderData: borderData,
              barGroups: barGroups,
              gridData: const FlGridData(show: false),
              alignment: BarChartAlignment.spaceEvenly,
              extraLinesData: extraLinesData,
            ),
            swapAnimationDuration: Duration.zero,
          )
        : const Center(child: FaIcon(FontAwesomeIcons.chartSimple, color: sapphireDark, size: 120));
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: minify ? 2 : 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: minify,
            reservedSize: 40,
            getTitlesWidget: _leftTitleWidgets,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          Colors.white54,
          Colors.white,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> get barGroups => chartPoints.map((point) {
        return BarChartGroupData(
          x: point.x.toInt(),
          barRods: [
            BarChartRodData(
              borderRadius: BorderRadius.circular(2),
              width: 16,
              toY: point.y.toDouble(),
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: minify ? null : [0],
        );
      }).toList();

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
    }
    return "${value.toInt()}";
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final modifiedDateTimes = periods.length == 1 ? [...periods, ...periods] : periods;
    final style = GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      fontSize: 10,
      color: Colors.white70,
    );
    return SideTitleWidget(
      fitInside: SideTitleFitInsideData.disable(),
      axisSide: meta.axisSide,
      child: value % meta.appliedInterval == 0 ? Text(modifiedDateTimes[value.toInt()], style: style) : const SizedBox.shrink(),
    );
  }
}
