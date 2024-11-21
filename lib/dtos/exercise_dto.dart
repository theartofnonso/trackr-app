import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/exercise/set_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../enums/exercise/exercise_equipment_enum.dart';

abstract class ExerciseConfig {
  String get name;
  String get displayName;
  String get description;

  Map<String, dynamic> toJson();

  static ExerciseConfig fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'ExerciseEquipment':
        return ExerciseEquipment.fromJson(json);
      case 'SetType':
        return SetType.fromJson(json);
      default:
        throw ArgumentError('Unknown ExerciseConfig type: ${json['type']}');
    }
  }
}

abstract class ExerciseDTO {
  String get id;
  String get name;
  String get description;
  List<MuscleGroup> get primaryMuscleGroups;
  List<MuscleGroup> get secondaryMuscleGroups;
  Map<String, List<ExerciseConfig>> get configurationOptions;


  ExerciseVariantDTO createVariant({required Map<String, dynamic> configurations});

  ExerciseVariantDTO defaultVariant();

  @override
  String toString() {
    return 'ExerciseDTO{id: $id, name: $name, description: $description, configurationOptions: $configurationOptions}';
  }
}
