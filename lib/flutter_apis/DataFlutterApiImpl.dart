import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/pigeon_build/data_pigeon.g.dart';

import '../controllers/exercise_log_controller.dart';

class DataFlutterApiImpl extends DataFlutterApi {

  final BuildContext context;

  DataFlutterApiImpl(this.context);

  @override
  void bpmAndSpeed(String exerciseLogId, int setIndex, int bpm, int speed) {
    print("Receiving intensity for set index: $setIndex");
    Provider.of<ExerciseLogController>(context, listen: false).updateSetIntensity(exerciseLogId: exerciseLogId, index: setIndex, bpm: bpm, speed: speed);
  }
}