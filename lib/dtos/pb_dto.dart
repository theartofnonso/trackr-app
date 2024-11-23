import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/dtos/sets_dtos/set_dto.dart';

import '../enums/pb_enums.dart';

class PBDto {
  final SetDTO set;
  final ExerciseVariantDTO exerciseVariant;
  final PBType pb;

  PBDto({required this.set, required this.exerciseVariant, required this.pb});

  @override
  String toString() {
    return 'PBDto{set: $set, exercise: $exerciseVariant, pb: $pb}';
  }
}