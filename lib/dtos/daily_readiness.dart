import '../utils/readiness_utils.dart';

enum ReadinessEnum {
  maxPositive(5),
  minPositive(1),
  none(0);

  const ReadinessEnum(this.value);

  final int value;
}

class DailyReadiness {
  final int perceivedFatigue;
  final int muscleSoreness;
  final int sleepDuration;

  DailyReadiness({
    required this.perceivedFatigue,
    required this.muscleSoreness,
    required this.sleepDuration,
  });

  DailyReadiness.empty({this.perceivedFatigue = 0, this.muscleSoreness = 0, this.sleepDuration = 0});

  /// Returns the description for the given perceived fatigue rating.
  String get perceivedFatigueDescription =>
      perceivedFatigueScale[perceivedFatigue] ?? 'Unknown rating';

  /// Returns the description for the given muscle soreness rating.
  String get muscleSorenessDescription =>
      muscleSorenessScale[muscleSoreness] ?? 'Unknown rating';

  /// Returns the description for the given sleep duration rating.
  String get sleepDurationDescription =>
      sleepDurationScale[sleepDuration] ?? 'Unknown rating';
}