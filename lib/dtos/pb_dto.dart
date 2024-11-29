import 'package:tracker_app/dtos/set_dtos/set_dto.dart';

import '../enums/pb_enums.dart';
import 'appsync/exercise_dto.dart';

class PBDto {
  final SetDto set;
  final ExerciseDto exercise;
  final PBType pb;

  PBDto({required this.set, required this.exercise, required this.pb});

  @override
  String toString() {
    return 'PBDto{set: $set, exercise: $exercise, pb: $pb}';
  }
}