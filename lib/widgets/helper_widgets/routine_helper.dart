
import 'package:collection/collection.dart';

import '../../dtos/procedure_dto.dart';

ProcedureDto? whereOtherSuperSetProcedure({required ProcedureDto firstProcedure, required List<ProcedureDto> procedures}) {
  return procedures.firstWhereOrNull((procedure) =>
  procedure.superSetId.isNotEmpty &&
      procedure.superSetId == firstProcedure.superSetId &&
      procedure.exercise.id != firstProcedure.exercise.id);
}