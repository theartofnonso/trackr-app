import 'package:tracker_app/dtos/db/routine_plan_dto.dart';

abstract class RoutinePlanRepository {
  Future<List<RoutinePlanDto>> getPlans();
  Future<RoutinePlanDto?> getPlanById(String id);
  Future<RoutinePlanDto?> savePlan({required RoutinePlanDto planDto});
  Future<RoutinePlanDto?> updatePlan({required RoutinePlanDto plan});
  Future<bool> removePlan({required RoutinePlanDto plan});
}
