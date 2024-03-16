import 'package:health/health.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';

void syncWorkoutWithAppleHealth({required RoutineLogDto log}) async {
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  await health.writeWorkoutData(HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING, log.startTime, log.endTime);
}

Future<bool> connectAppleHealth() async {
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  const types = [HealthDataType.WORKOUT];

  const permissions = [HealthDataAccess.WRITE];

  return await health.requestAuthorization(types, permissions: permissions);
}

Future<bool> checkAppleHealthConnectivity() async {
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  const types = [HealthDataType.WORKOUT];

  const permissions = [HealthDataAccess.WRITE];

  return await health.hasPermissions(types, permissions: permissions) ?? false;
}
