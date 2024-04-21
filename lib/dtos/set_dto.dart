
import 'dart:convert';

class SetDto {
  final num value1;
  final num value2;
  final bool checked;
  final int heartRate;

  const SetDto(this.value1, this.value2, this.checked, {this.heartRate = 0});

  SetDto copyWith({num? value1, num? value2, bool? checked, int? heartRate}) {
    return SetDto(value1 ?? this.value1, value2 ?? this.value2, checked ?? this.checked, heartRate: heartRate ?? this.heartRate);
  }

  String toJson() {
    return jsonEncode({"value1": value1, "value2": value2, "checked": checked, "heartRate": heartRate});
  }

  factory SetDto.fromJson(Map<String, dynamic> json) {
    final value1 = json["value1"];
    final value2 = json["value2"];
    final checked = json["checked"];
    final heartRate = json["heartRate"] ?? 0;
    return SetDto(value1, value2, checked, heartRate: heartRate);
  }

  bool isEmpty() {
    return value1 + value2 == 0;
  }

  bool isNotEmpty() {
    return value1 + value2 > 0;
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetDto &&
          runtimeType == other.runtimeType &&
          value1 == other.value1 &&
          value2 == other.value2 &&
          checked == other.checked;

  @override
  int get hashCode => value1.hashCode ^ value2.hashCode ^ checked.hashCode;

  @override
  String toString() {
    return 'SetDto{value1: $value1, value2: $value2, checked: $checked}, heartRate: $heartRate';
  }
}
