class ProcedureDto {
  int repCount;
  int weight;

  ProcedureDto({this.repCount = 0, this.weight = 0});

  @override
  String toString() {
    return 'ProcedureDto{repCount: $repCount, weight: $weight}';
  }
}
