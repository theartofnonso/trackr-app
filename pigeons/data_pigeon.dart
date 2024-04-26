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
  bool isWatchSynced();
  void syncSession({required String sessionName});
  void unSyncSession();
  void getBpmAndSpeed({required String exerciseLogId, required int setIndex});
}

@FlutterApi()
abstract class DataFlutterApi {
  void bpmAndSpeed(String exerciseLogId, int setIndex, int bpm, int speed);
}