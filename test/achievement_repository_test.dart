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
      "${plankExercise.id}${lyingLegCurlExercise.id}",
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
      "${plankExercise.id}${lyingLegCurlExercise.id}",
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

  final coreAndLegDayRoutineLog = RoutineLogDto(
      id: "routineLogId1",
      templateId: "templateId1",
      name: "Core And Leg Day",
      exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1],
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
  
  group("Achievement Type Time To Go", () {
    
    test("AchievementType.fiveMinutesToGo", () {
      final achievementRepository = AchievementRepository();

      final initialRoutineLogs = List.filled(4, coreDayRoutineLog);

      achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

      expect(achievementRepository.achievements.firstWhere((achievement) => achievement.type == AchievementType.fiveMinutesToGo).progress.dates, {});

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

    test("AchievementType.tenMinutesToGo", () {
      final achievementRepository = AchievementRepository();

      final initialRoutineLogs = List.filled(4, coreDayRoutineLog);

      achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

      expect(achievementRepository.achievements.firstWhere((achievement) => achievement.type == AchievementType.tenMinutesToGo).progress.dates, {});

      final plankExerciseLog2 = ExerciseLogDto(
          plankExercise.id,
          "routineLogId1",
          "superSetId",
          plankExercise,
          "notes",
          [
            const SetDto(600000, 0, true)
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

      final recentRoutineLogs = List.filled(10, coreDay1RoutineLog);

      final achievements = achievementRepository.calculateNewLogAchievements(routineLogs: recentRoutineLogs);

      expect(achievements.firstWhere((achievement) => achievement.type == AchievementType.tenMinutesToGo).progress.remainder, 0);
    });

    test("AchievementType.fifteenMinutesToGo", () {
      final achievementRepository = AchievementRepository();

      final initialRoutineLogs = List.filled(14, coreDayRoutineLog);

      achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

      expect(achievementRepository.achievements.firstWhere((achievement) => achievement.type == AchievementType.fifteenMinutesToGo).progress.dates, {});

      final plankExerciseLog2 = ExerciseLogDto(
          plankExercise.id,
          "routineLogId1",
          "superSetId",
          plankExercise,
          "notes",
          [
            const SetDto(900000, 0, true)
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

      final recentRoutineLogs = List.filled(15, coreDay1RoutineLog);

      final achievements = achievementRepository.calculateNewLogAchievements(routineLogs: recentRoutineLogs);

      expect(achievements.firstWhere((achievement) => achievement.type == AchievementType.fifteenMinutesToGo).progress.remainder, 0);
    });
  });
  
  test("AchievementType.supersetSpecialist", () {
    final achievementRepository = AchievementRepository();

    final initialRoutineLogs = List.filled(49, coreAndLegDayRoutineLog);

    achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

    final recentRoutineLogs = List.filled(50, coreAndLegDayRoutineLog);

    final achievements = achievementRepository.calculateNewLogAchievements(routineLogs: recentRoutineLogs);

    expect(achievements.firstWhere((achievement) => achievement.type == AchievementType.supersetSpecialist).progress.remainder, 0);

  });

  test("AchievementType.obsessed", () {
    final achievementRepository = AchievementRepository();

    final next15Weeks = _generateWeeklyDateTimes(15);

    final initialRoutineLogs = List.generate(next15Weeks.length, (index) {

      return RoutineLogDto(
          id: "routineLogId1",
          templateId: "templateId1",
          name: "Leg Day",
          exerciseLogs: [lyingLegCurlExerciseLog1],
          notes: "notes",
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          createdAt: next15Weeks[index],
          updatedAt: next15Weeks[index]);
    });

    achievementRepository.loadAchievements(routineLogs: initialRoutineLogs);

    // print("initialRoutineLogs: ${initialRoutineLogs.map((e) => e.createdAt)}");
    //
    // print("dates: ${achievementRepository.achievements.firstWhere((achievement) => achievement.type == AchievementType.obsessed).progress.dates}");

    final next16Weeks = _generateWeeklyDateTimes(16);

    final recentRoutineLogs = List.generate(next16Weeks.length, (index) => RoutineLogDto(
        id: "routineLogId1",
        templateId: "templateId1",
        name: "Core And Leg Day",
        exerciseLogs: [lyingLegCurlExerciseLog1],
        notes: "notes",
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        createdAt: next16Weeks[index],
        updatedAt: next16Weeks[index]));

    final achievements = achievementRepository.calculateNewLogAchievements(routineLogs: recentRoutineLogs);

    expect(achievements.firstWhere((achievement) => achievement.type == AchievementType.obsessed).progress.remainder, 0);

  });
}

List<DateTime> _generateWeeklyDateTimes(int n) {
  List<DateTime> dateTimes = [];
  DateTime baseDate = DateTime.now();

  for (int i = 0; i < n; i++) {
    // Add 7 days for each week
    DateTime nextDate = baseDate.add(Duration(days: 7 * i));
    dateTimes.add(nextDate);
  }

  return dateTimes;
}

