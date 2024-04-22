import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/pigeon_build/data_pigeon.g.dart',
  dartOptions: DartOptions(),
  swiftOut: 'ios/Runner/PigeonBuild/DataPigeon.g.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'tracker_app',
))

@HostApi()
abstract class DataHostApi {
  void getHeartRate();
  void getVelocity();
}

@FlutterApi()
abstract class DataFlutterApi {
  void heartRate(int bpm);
  void velocity(double speed);
}