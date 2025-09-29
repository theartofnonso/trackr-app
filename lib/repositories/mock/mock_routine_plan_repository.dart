import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/appsync/routine_plan_dto.dart';

class MockRoutinePlanRepository {
  List<RoutinePlanDto> _plans = [];

  UnmodifiableListView<RoutinePlanDto> get plans =>
      UnmodifiableListView(_plans);

  void loadPlans({required List<RoutinePlanDto> plans}) {
    _plans = plans;
  }

  Future<RoutinePlanDto> savePlan({required RoutinePlanDto planDto}) async {
    final id = planDto.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : planDto.id;
    final created = planDto.copyWith(
        id: id, createdAt: DateTime.now(), updatedAt: DateTime.now());
    _plans = [created, ..._plans];
    return created;
  }

  Future<void> updatePlan({required RoutinePlanDto plan}) async {
    _plans = _plans
        .map((p) =>
            p.id == plan.id ? plan.copyWith(updatedAt: DateTime.now()) : p)
        .toList();
  }

  Future<void> removePlan({required RoutinePlanDto plan}) async {
    _plans = _plans.where((p) => p.id != plan.id).toList();
  }

  RoutinePlanDto? planWhere({required String id}) {
    return _plans.firstWhereOrNull((dto) => dto.id == id);
  }

  void clear() {
    _plans.clear();
  }
}
