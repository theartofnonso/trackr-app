import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';

import 'exercise_provider.dart';

class AppProviders {

  static void resetProviders(BuildContext context) {
    Provider.of<ExerciseProvider>(context, listen: false).reset();
    Provider.of<RoutineTemplateProvider>(context, listen: false).reset();
    Provider.of<RoutineLogProvider>(context, listen: false).reset();
  }
}
