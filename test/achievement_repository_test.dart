import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/achievement_type_enums.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/repositories/achievement_repository.dart';

void main() {
  final lyingLegCurlExercise = ExerciseDto(
      id: "id_lyingLegCurlExercise",
      name: "Lying Leg Curl",
      primaryMuscleGroup: MuscleGroup.legs,
      type: ExerciseType.weights,
      owner: false);

  final plankExercise = ExerciseDto(
      id: "id_plankExercise",
      name: "Plank",
      primaryMuscleGroup: MuscleGroup.abs,
      type: ExerciseType.duration,
      owner: false);

  final lyingLegCurlExerciseLog1 = ExerciseLogDto(
      lyingLegCurlExercise.id,
      "routineLogId1",
      "superSetId",
      lyingLegCurlExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      DateTime(2023, 12, 1));

  final plankExerciseLog1 = ExerciseLogDto(
      plankExercise.id,
      "routineLogId1",
      "superSetId",
      plankExercise,
      "notes",
      [
        const SetDto(120000, 0, true),
        const SetDto(180000, 0, true),
        const SetDto(150000, 0, true),
      ],
      DateTime.now());

  final legDayRoutineLog = RoutineLogDto(
      id: "routineLogId1",
      templateId: "templateId1",
      name: "Leg Day",
      exerciseLogs: [lyingLegCurlExerciseLog1],
      notes: "notes",
      startTime: DateTime(2024, 12, 1),
      endTime: DateTime(2024, 12, 1),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1));

  final coreDayRoutineLog = RoutineLogDto(
      id: "routineLogId1",
      templateId: "templateId1",
      name: "Core Day",
      exerciseLogs: [plankExerciseLog1],
      notes: "notes",
      startTime: DateTime(2024, 12, 1),
      endTime: DateTime(2024, 12, 1),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1));


  group("Achievement Type Days Logged", () {
    test("AchievementType.days12", () {
      final achievementRepository = AchievementRepository();

      final initialRoutineLogs = List.filled(11, legDayRoutineLog);

      achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

      final recentRoutineLogs = List.filled(12, legDayRoutineLog);

      final achievements = achievementRepository.calculateNewLogAchievements(routineLogs: recentRoutineLogs);

      expect(achievements.firstWhere((achievement) => achievement.type == AchievementType.days12).progress.remainder, 0);
    });

    test("AchievementType.days30", () {
      final achievementRepository = AchievementRepository();

      final initialRoutineLogs = List.filled(29, legDayRoutineLog);

      achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

      final recentRoutineLogs = List.filled(30, legDayRoutineLog);

      final achievements = achievementRepository.calculateNewLogAchievements(routineLogs: recentRoutineLogs);

      expect(achievements.firstWhere((achievement) => achievement.type == AchievementType.days30).progress.remainder, 0);
    });

    test("AchievementType.days75", () {
      final achievementRepository = AchievementRepository();

      final initialRoutineLogs = List.filled(74, legDayRoutineLog);

      achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

      final recentRoutineLogs = List.filled(75, legDayRoutineLog);

      final achievements = achievementRepository.calculateNewLogAchievements(routineLogs: recentRoutineLogs);

      expect(achievements.firstWhere((achievement) => achievement.type == AchievementType.days75).progress.remainder, 0);
    });

    test("AchievementType.days100", () {
      final achievementRepository = AchievementRepository();

      final initialRoutineLogs = List.filled(99, legDayRoutineLog);

      achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

      final recentRoutineLogs = List.filled(100, legDayRoutineLog);

      final achievements = achievementRepository.calculateNewLogAchievements(routineLogs: recentRoutineLogs);

      expect(achievements.firstWhere((achievement) => achievement.type == AchievementType.days100).progress.remainder, 0);
    });
  });

  test("AchievementType.fiveMinutesToGo", () {
    final achievementRepository = AchievementRepository();

    final initialRoutineLogs = List.filled(4, coreDayRoutineLog);

    achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

    final plankExerciseLog2 = ExerciseLogDto(
        plankExercise.id,
        "routineLogId1",
        "superSetId",
        plankExercise,
        "notes",
        [
          const SetDto(300000, 0, true)
        ],
        DateTime(2024, 2, 1));

    final coreDay1RoutineLog = RoutineLogDto(
        id: "routineLogId1",
        templateId: "templateId1",
        name: "Core Day",
        exerciseLogs: [plankExerciseLog2],
        notes: "notes",
        startTime: DateTime(2024, 12, 1),
        endTime: DateTime(2024, 12, 1),
        createdAt: DateTime(2024, 2, 1),
        updatedAt: DateTime(2024, 1, 1));

    final recentRoutineLogs = List.filled(5, coreDay1RoutineLog);

    final achievements = achievementRepository.calculateNewLogAchievements(routineLogs: recentRoutineLogs);

    expect(achievements.firstWhere((achievement) => achievement.type == AchievementType.fiveMinutesToGo).progress.remainder, 0);
  });
}
