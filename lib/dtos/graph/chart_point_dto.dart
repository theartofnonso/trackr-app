class ChartPointDto {
  final num x;
  final num y;

  ChartPointDto({required this.x, required this.y});

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  factory ChartPointDto.fromJson(Map<String, dynamic> json) {
    return ChartPointDto(
      x: json['x'] as num,
      y: json['y'] as num,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChartPointDto && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() {
    return 'ChartPointDto{x: $x, y: $y}';
  }
}
