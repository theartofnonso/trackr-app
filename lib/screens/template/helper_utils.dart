import 'package:flutter/material.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../dtos/routine_template_dto.dart';
import '../../utils/navigation_utils.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';

void logRoutine({required BuildContext context, required RoutineTemplateDto template}) async {
  final log = cachedRoutineLog();
  if (log == null) {
    navigateToRoutineLogEditor(context: context, log: template.log());
  } else {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline_rounded), message: "${log.name} is running");
  }
}
