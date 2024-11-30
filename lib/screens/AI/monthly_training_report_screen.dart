import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';

import '../../dtos/open_ai_response_schema_dtos/monthly_training_report.dart';

class MonthlyTrainingReportScreen extends StatelessWidget {

  final MonthlyTrainingReport monthlyTrainingReport;
  final List<RoutineLogDto> routineLogs;
  final List<ActivityLogDto> activityLogs;

  const MonthlyTrainingReportScreen({super.key, required this.monthlyTrainingReport, required this.routineLogs, required this.activityLogs});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
