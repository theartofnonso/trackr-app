import 'package:flutter/material.dart';
import 'package:tracker_app/extensions/routine_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/snackbar_utils.dart';

void logRoutine({required BuildContext context, required Routine routine}) async {
  final log = await cachedRoutineLog();
  if(context.mounted) {
    if (log == null) {
      navigateToRoutineLogEditor(context: context, log: routine.log());
    } else {
      showSnackbar(
          context: context,
          icon: const Icon(Icons.info_outline_rounded),
          message: "${log.name} is running");
    }
  }
}