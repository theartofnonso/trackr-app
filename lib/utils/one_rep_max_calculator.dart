import 'dart:math';

double _epley({required double weight, required int reps}) {
  return weight * (1 + reps / 30);
}

double _brzycki({required double weight, required int reps}) {
  return weight / (1.0278 - 0.0278 * reps);
}

double _wathan({required double weight, required int reps}) {
  return 100 * weight / (48.8 + 53.8 * exp(-0.075 * reps));
}

double _lombardi({required double weight, required int reps}) {
  return weight * pow(reps, 0.10);
}

double _mayhew({required double weight, required int reps}) {
  return 100 * weight / (52.2 + 41.9 * exp(-0.055 * reps));
}

double average1RM({required double weight, required int reps}) {
  double sum = _epley(weight: weight, reps: reps) +
      _brzycki(weight: weight, reps: reps) +
      _wathan(weight: weight, reps: reps) +
      _lombardi(weight: weight, reps: reps) +
      _mayhew(weight: weight, reps: reps);
  return sum / 5;
}
