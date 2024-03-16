import 'package:health/health.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';

Future<void> syncWorkoutWithAppleHealth({required RoutineLogDto log}) async {
  // create a HealthFactory for use in the app, choose if HealthConnect should be used or not
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  const types = [HealthDataType.WORKOUT];

  var permissions = [HealthDataAccess.READ_WRITE];

  final success = await health.hasPermissions(types, permissions: permissions);
  if (success != null) {
    if (!success) {
      await health.requestAuthorization(types, permissions: permissions);
    }
  }
  await health.writeWorkoutData(HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING, log.startTime, log.endTime);
}

Future<bool> connectWithAppleHealth() async {
  // create a HealthFactory for use in the app, choose if HealthConnect should be used or not
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  const types = [HealthDataType.WORKOUT];

  var permissions = [HealthDataAccess.READ_WRITE];

  bool success = await health.hasPermissions(types, permissions: permissions) ?? false;
  if (!success) {
    success = await health.requestAuthorization(types, permissions: permissions);
  }
  return success;
}

Future<bool> checkAppleHealthConnectivity() async {
  // create a HealthFactory for use in the app, choose if HealthConnect should be used or not
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  const types = [HealthDataType.WORKOUT];

  var permissions = [HealthDataAccess.READ_WRITE];

  return await health.hasPermissions(types, permissions: permissions) ?? false;
}
