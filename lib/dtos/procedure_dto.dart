import 'package:tracker_app/dtos/warm_up_procedure_dto.dart';

import 'exercise_dto.dart';

class Procedure {
  final Exercise exercise;
  final WarmUpProcedure? warmUpProcedure;
  final int repCount;
  final int setCount;
  final int weight;

  Procedure(this.exercise, this.warmUpProcedure, this.repCount, this.setCount, this.weight);
}