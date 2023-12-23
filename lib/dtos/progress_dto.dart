class ProgressDto {
  final double value;
  final int remainder;
  final List<DateTime> dates;

  ProgressDto({required this.value, required this.remainder, required this.dates});

  @override
  String toString() {
    return 'ProgressDto{value: $value, remainder: $remainder, dates: $dates}';
  }
}