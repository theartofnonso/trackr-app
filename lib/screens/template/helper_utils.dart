import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/routine_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../../providers/routine_log_provider.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/snackbar_utils.dart';

void logRoutine({required BuildContext context, required Routine routine}) async {
  final log = Provider.of<RoutineLogProvider>(context, listen: false).cachedRoutineLog;
  if (log == null) {
    navigateToRoutineLogEditor(context: context, log: routine.log());
  } else {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline_rounded), message: "${log.name} is running");
  }
}
