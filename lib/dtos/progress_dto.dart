class ProgressDto {
  final double value;
  final int remainder;
  final Map<int, List<DateTime>> dates;

  ProgressDto({required this.value, required this.remainder, required this.dates});

  @override
  String toString() {
    return 'ProgressDto{value: $value, remainder: $remainder, dates: $dates}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressDto && runtimeType == other.runtimeType && value == other.value && remainder == other.remainder;

  @override
  int get hashCode => value.hashCode ^ remainder.hashCode;
}