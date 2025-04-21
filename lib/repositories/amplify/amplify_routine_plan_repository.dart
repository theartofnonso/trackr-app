import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../dtos/appsync/routine_plan_dto.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../logger.dart';

class AmplifyRoutinePlanRepository {
  final logger = getLogger(className: "AmplifyRoutinePlanRepository");

  List<RoutinePlanDto> _plans = [];

  UnmodifiableListView<RoutinePlanDto> get plans => UnmodifiableListView(_plans);

  void loadPlansStream({required List<RoutinePlan> plans}) {
    _plans = plans.map((plan) => RoutinePlanDto.toDto(plan)).toList();
  }

  Future<RoutinePlanDto> savePlan({required RoutinePlanDto planDto}) async {
    final now = TemporalDateTime.now();

    final planToCreate =
        RoutinePlan(data: jsonEncode(planDto), createdAt: now, updatedAt: now, owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutinePlan>(planToCreate);

    Posthog().capture(eventName: PostHogAnalyticsEvent.createRoutineTemplate.displayName, properties: planDto.toJson());

    logger.i("save plan: $planDto");

    final updatedWithId = planDto.copyWith(id: planToCreate.id);

    return updatedWithId;
  }

  Future<void> updatePlan({required RoutinePlanDto plan}) async {
    final result = (await Amplify.DataStore.query(
      RoutinePlan.classType,
      where: RoutinePlan.ID.eq(plan.id),
    ));

    if (result.isNotEmpty) {
      final oldPlan = result.first;
      final newPlan = oldPlan.copyWith(data: jsonEncode(plan));
      await Amplify.DataStore.save<RoutinePlan>(newPlan);
      logger.i("update plan: $plan");
    }
  }

  Future<void> removePlan({required RoutinePlanDto plan}) async {
    final result = (await Amplify.DataStore.query(
      RoutinePlan.classType,
      where: RoutinePlan.ID.eq(plan.id),
    ));

    if (result.isNotEmpty) {
      final oldPlan = result.first;
      await Amplify.DataStore.delete<RoutinePlan>(oldPlan);
      logger.i("remove plan: $plan");
    }
  }

  /// Helper methods

  RoutinePlanDto? planWhere({required String id}) {
    return _plans.firstWhereOrNull((dto) => dto.id == id);
  }

  void clear() {
    _plans.clear();
  }
}
