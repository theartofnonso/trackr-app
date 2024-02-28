import 'dart:math';

double epley({required double weight, required int reps}) {
  return weight * (1 + reps / 30);
}

double brzycki({required double weight, required int reps}) {
  return weight / (1.0278 - 0.0278 * reps);
}

double wathan({required double weight, required int reps}) {
  return 100 * weight / (48.8 + 53.8 * exp(-0.075 * reps));
}

double lombardi({required double weight, required int reps}) {
  return weight * pow(reps, 0.10);
}

double mayhew({required double weight, required int reps}) {
  return 100 * weight / (52.2 + 41.9 * exp(-0.055 * reps));
}

double average1RM({required double weight, required int reps}) {
  double sum = epley(weight: weight, reps: reps) +
      brzycki(weight: weight, reps: reps) +
      wathan(weight: weight, reps: reps) +
      lombardi(weight: weight, reps: reps) +
      mayhew(weight: weight, reps: reps);
  return sum / 5;
}
