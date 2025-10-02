import 'package:tracker_app/dtos/set_dtos/set_dto.dart';

import '../enums/exercise_type_enums.dart';
import '../enums/pb_enums.dart';
import 'db/exercise_dto.dart';

class PBDto {
  final SetDto set;
  final ExerciseDto exercise;
  final PBType pb;

  PBDto({required this.set, required this.exercise, required this.pb});

  Map<String, dynamic> toJson() {
    return {
      'set': set.toJson(),
      'exercise': exercise.toJson(),
      'pb': pb.name,
    };
  }

  factory PBDto.fromJson(Map<String, dynamic> json) {
    return PBDto(
      set: SetDto.fromJson(
        json['set'] as Map<String, dynamic>,
        exerciseType:
            ExerciseType.fromString(json['exercise']['type'] as String),
        datetime: DateTime.now(),
      ),
      exercise: ExerciseDto.fromJson(json['exercise'] as Map<String, dynamic>),
      pb: PBType.values.firstWhere((e) => e.name == json['pb']),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PBDto &&
        other.set == set &&
        other.exercise == exercise &&
        other.pb == pb;
  }

  @override
  int get hashCode => Object.hash(set, exercise, pb);

  @override
  String toString() {
    return 'PBDto{set: $set, exercise: $exercise, pb: $pb}';
  }
}
