import 'package:tracker_app/dtos/procedure_dto.dart';

extension ProcedureDtoExtension on ProcedureDto {

  ProcedureDto refreshSets() {
    return copyWith(sets: sets.map((set) => set.copyWith(checked: false)).toList());
  }
}