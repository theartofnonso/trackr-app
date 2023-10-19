import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/routine_log_provider.dart';

class RoutineLogsScreen extends StatelessWidget {
  const RoutineLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = Provider.of<RoutineLogProvider>(context, listen: true).logs;
    return const CupertinoPageScaffold(child: child);
  }
}
