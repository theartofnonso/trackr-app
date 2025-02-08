enum Trend { up, down, stable, none }

class TrendSummary {
  final Trend trend;
  final num average;
  final String summary;

  TrendSummary({required this.trend, this.average = 0, required this.summary});
}

Trend detectTrend(List<num> values, {double trendThreshold = 5.0}) {
  if (values.length == 2) {
    final change = values.last - values.first;
    if (change.abs() < _percentageToAbsolute(trendThreshold, values.first)) {
      return Trend.stable;
    }
    return change > 0 ? Trend.up : Trend.down;
  }

  final regression = _calculateRegression(values);
  if (regression.slope.abs() < _percentageToAbsolute(trendThreshold, regression.average)) {
    return Trend.stable;
  }
  return regression.slope > 0 ? Trend.up : Trend.down;
}

double _percentageToAbsolute(double percentage, num base) => base * percentage / 100;

_RegressionResult _calculateRegression(List<num> values) {
  double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
  final n = values.length.toDouble();

  for (var i = 0; i < values.length; i++) {
    sumX += i.toDouble();
    sumY += values[i];
    sumXY += i * values[i];
    sumXX += i * i;
  }

  final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  return _RegressionResult(slope, sumY / n);
}

class _RegressionResult {
  final double slope;
  final double average;

  _RegressionResult(this.slope, this.average);
}