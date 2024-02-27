import 'dart:math';

double epley(double weight, int reps) {
  return weight * (1 + reps / 30);
}

double brzycki(double weight, int reps) {
  return weight / (1.0278 - 0.0278 * reps);
}

double wathan(double weight, int reps) {
  return 100 * weight / (48.8 + 53.8 * exp(-0.075 * reps));
}

double lombardi(double weight, int reps) {
  return weight * pow(reps, 0.10);
}

double mayhew(double weight, int reps) {
  return 100 * weight / (52.2 + 41.9 * exp(-0.055 * reps));
}

double average1RM(double weight, int reps) {
  double sum = epley(weight, reps) +
      brzycki(weight, reps) +
      wathan(weight, reps) +
      lombardi(weight, reps) +
      mayhew(weight, reps);
  return sum / 5;
}
