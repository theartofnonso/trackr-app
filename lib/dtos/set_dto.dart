
import 'dart:convert';

import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

class SetDto {
  final num value1;
  final num value2;
  final bool checked;

  const SetDto(this.value1, this.value2, this.checked);

  SetDto copyWith({num? value1, num? value2, bool? checked}) {
    return SetDto(value1 ?? this.value1, value2 ?? this.value2, checked ?? this.checked);
  }

  String toJson() {
    return jsonEncode({"value1": value1, "value2": value2, "checked": checked});
  }

  factory SetDto.fromJson(Map<String, dynamic> json) {
    final value1 = json["value1"];
    final value2 = json["value2"];
    final checked = json["checked"];
    return SetDto(value1, value2, checked);
  }

  bool isEmpty() {
    return value1 + value2 == 0;
  }

  bool isNotEmpty() {
    return value1 + value2 > 0;
  }

  double volume() {
    final convertedWeight = weightWithConversion(value: value1);
    return (convertedWeight * value2).toDouble();
  }

  double weight() {
    return weightWithConversion(value: value1.toDouble());
  }

  int duration() {
    return value1.toInt();
  }

  int reps() {
    return value2.toInt();
  }

  String weightsSummary() {
    return "${weight()}${weightLabel()} x ${reps()}";
  }

  String durationSummary() {
    final label = Duration(milliseconds: duration()).hmsAnalog();
    return label;
  }

  String repsSummary() {
    return "x${reps()}";
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
    return 'SetDto{value1: $value1, value2: $value2, checked: $checked}';
  }
}