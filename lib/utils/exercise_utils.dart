import 'package:flutter/cupertino.dart';

import '../enums/exercise/exercise_equipment_enum.dart';
import '../enums/exercise/exercise_metrics_enums.dart';
import '../enums/exercise/exercise_modality_enum.dart';
import '../enums/exercise/exercise_movement_enum.dart';
import '../enums/exercise/exercise_position_enum.dart';
import '../enums/exercise/exercise_stance_enum.dart';
import '../widgets/pickers/exercise/exercise_equipment_picker.dart';
import '../widgets/pickers/exercise/exercise_metric_picker.dart';
import '../widgets/pickers/exercise/exercise_modality_picker.dart';
import '../widgets/pickers/exercise/exercise_movement_picker.dart';
import '../widgets/pickers/exercise/exercise_position_picker.dart';
import '../widgets/pickers/exercise/exercise_stance_picker.dart';
import 'dialog_utils.dart';

void showExerciseEquipmentPicker(
    {required BuildContext context,
      ExerciseEquipment? initialEquipment,
    required List<ExerciseEquipment> equipment,
    required Function(ExerciseEquipment object) onSelect}) {
  displayBottomSheet(
      height: 300,
      context: context,
      child: ExerciseEquipmentPicker(
          initialEquipment: initialEquipment, equipment: equipment, onSelect: onSelect));
}

void showExerciseModalityPicker(
    {required BuildContext context,
      ExerciseModality? initialModality,
    required List<ExerciseModality> modes,
    required Function(ExerciseModality object) onSelect}) {
  displayBottomSheet(
      height: 300,
      context: context,
      child: ExerciseModalityPicker(initialModality: initialModality, modes: modes, onSelect: onSelect));
}

void showExerciseMetricPicker(
    {required BuildContext context,
      ExerciseMetric? initialMetric,
    required List<ExerciseMetric> metrics,
    required Function(ExerciseMetric object) onSelect}) {
  displayBottomSheet(
      height: 300,
      context: context,
      child: ExerciseMetricPicker(initialMetric: initialMetric, metrics: metrics, onSelect: onSelect));
}

void showExercisePositionPicker(
    {required BuildContext context,
      ExercisePosition? initialPosition,
    required List<ExercisePosition> positions,
    required Function(ExercisePosition object) onSelect}) {
  displayBottomSheet(
      height: 300,
      context: context,
      child:
          ExercisePositionPicker(initialPosition: initialPosition, positions: positions, onSelect: onSelect));
}

void showExerciseStancePicker(
    {required BuildContext context,
      ExerciseStance? initialStance,
    required List<ExerciseStance> stances,
    required Function(ExerciseStance object) onSelect}) {
  displayBottomSheet(
      height: 300,
      context: context,
      child: ExerciseStancePicker(initialStance: initialStance, stances: stances, onSelect: onSelect));
}

void showExerciseMovementPicker(
    {required BuildContext context,
    ExerciseMovement? initialMovement,
    required List<ExerciseMovement> movements,
    required Function(ExerciseMovement object) onSelect}) {
  displayBottomSheet(
      height: 300,
      context: context,
      child:
          ExerciseMovementPicker(initialMovement: initialMovement, movements: movements, onSelect: onSelect));
}
