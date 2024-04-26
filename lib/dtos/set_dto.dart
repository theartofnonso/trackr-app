import 'dart:convert';

class SetDto {
  final num value1;
  final num value2;
  final bool checked;
  final int bpm;
  final int speed;

  const SetDto({this.value1 = 0.0, this.value2 = 0, this.checked = false, this.bpm = 0, this.speed = 0});

  SetDto copyWith({num? value1, num? value2, bool? checked, int? bpm, int? speed}) {
    return SetDto(
      value1: value1 ?? this.value1,
      value2: value2 ?? this.value2,
      checked: checked ?? this.checked,
      bpm: bpm ?? this.bpm,
      speed: speed ?? this.speed,
    );
  }

  String toJson() {
    return jsonEncode({
      "value1": value1,
      "value2": value2,
      "checked": checked,
      'bpm': bpm,
      'speed': speed,
    });
  }

  factory SetDto.fromJson(Map<String, dynamic> json) {
    return SetDto(
      value1: json['value1'] as num,
      value2: json['value2'] as num,
      checked: json['checked'] as bool,
      bpm: json['bpm'] ?? 0,
      speed: json['speed'] ?? 0,
    );
  }

  bool isEmpty() {
    return value1 + value2 == 0;
  }

  bool isNotEmpty() {
    return value1 + value2 > 0;
  }

  bool hasIntensity() {
    return bpm > 0 && speed > 0;
  }

  double volume() {
    return (value1 * value2).toDouble();
  }

  double weightValue() {
    return value1.toDouble();
  }

  int durationValue() {
    return value1.toInt();
  }

  int repsValue() {
    return value2.toInt();
  }

  @override
  String toString() {
    return 'SetDto{value1: $value1, value2: $value2, checked: $checked, bpm: $bpm, speed: $speed}';
  }
}
