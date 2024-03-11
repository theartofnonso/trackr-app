import 'dart:convert';

import 'package:flutter/material.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../dtos/routine_log_dto.dart';
import '../../utils/https_utils.dart';

class LeaderBoardScreen extends StatefulWidget {
  static const routeName = '/leader-board';

  const LeaderBoardScreen({super.key});

  @override
  State<LeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Leader Board'),
        ),
        body: const Center(
          child: Text('Leader Board'),
        ));
  }

  @override
  void initState() {
    super.initState();
    getAPI(endpoint: '/routine-logs').then((response) {
      final json = jsonDecode(response);
      final data = json["data"];
      final logs = data["listRoutineLogs"];
      final items = logs["items"] as List<dynamic>;
      final dtos = items.map((item) => _dto(json: item)).toList();
    });
  }

  RoutineLogDto _dto({required dynamic json}) {
    final id = json["id"] ?? "";
    final data = json["data"];
    final dataJson = jsonDecode(data);
    final exerciseLogJsons = dataJson["exercises"] as List<dynamic>;
    final exerciseLogs = exerciseLogJsons
        .map((json) => ExerciseLogDto.fromJson(routineLogId: id, createdAt: DateTime.now(), json: jsonDecode(json)))
        .toList();
    return RoutineLogDto(
      id: id,
      templateId: "",
      name: "",
      exerciseLogs: exerciseLogs,
      notes: "",
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
