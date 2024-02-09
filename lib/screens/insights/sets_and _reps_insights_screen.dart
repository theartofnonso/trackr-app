import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../dtos/routine_log_dto.dart';
import '../../widgets/chart/bar_chart.dart';

class SetsAndRepsInsightsScreen extends StatelessWidget {

  final List<RoutineLogDto>? monthAndLogs;

  const SetsAndRepsInsightsScreen({super.key, this.monthAndLogs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(10),
        child: Column(children: [
          BarChartSample6()
        ],),
      ),
    );
  }
}
