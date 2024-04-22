import 'package:tracker_app/pigeon_build/pigeon.g.dart';

class DataFlutterImpl extends DataFlutterApi {

  @override
  void heartRate(int bpm) {
    print("Flutter Heart Rate: $bpm");
  }

  @override
  void velocity(double speed) {
    print("Flutter Velocity: $speed");
  }

}