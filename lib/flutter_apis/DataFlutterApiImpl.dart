import 'package:tracker_app/pigeon_build/data_pigeon.g.dart';

class DataFlutterApiImpl extends DataFlutterApi {

  @override
  void heartRate(int bpm) {
    print("Flutter Heart Rate: $bpm");
  }

  @override
  void velocity(double speed) {
    print("Flutter Velocity: $speed");
  }

}