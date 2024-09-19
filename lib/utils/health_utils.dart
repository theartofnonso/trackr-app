import 'package:health/health.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';

void syncWorkoutWithAppleHealth({required RoutineLogDto log}) async {
  Health().configure();
  Health().writeWorkoutData(
    title: log.name,
      activityType: HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING, start: log.startTime, end: log.endTime);
}

Future<bool> connectAppleHealth() async {
  Health().configure();

  const types = [HealthDataType.WORKOUT];

  const permissions = [HealthDataAccess.WRITE];

  return await Health().requestAuthorization(types, permissions: permissions);
}

Future<bool> checkAppleHealthConnectivity() async {
  Health().configure();

  const types = [HealthDataType.WORKOUT];

  const permissions = [HealthDataAccess.WRITE];

  return await Health().hasPermissions(types, permissions: permissions) ?? false;
}
