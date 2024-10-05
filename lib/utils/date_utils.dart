
import 'package:flutter/material.dart';

DateTimeRange yearToDateTimeRange({DateTime? datetime}) {
  final now = datetime ?? DateTime.now();
  final start = DateTime(now.year, 1);
  final nextMonth = DateTime(start.year, start.month + 1, 1);
  final end = nextMonth.subtract(const Duration(days: 1));
  return DateTimeRange(start: start, end: end);
}