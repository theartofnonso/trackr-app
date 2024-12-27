import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:rive/src/rive_core/state_machine_controller.dart' as core;
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'controllers/exercise_and_routine_controller.dart';
import 'logger.dart';

class FireWidget extends StatefulWidget {
  const FireWidget({Key? key, required this.dateTimeRange}) : super(key: key);

  final DateTimeRange dateTimeRange;

  @override
  State<FireWidget> createState() => _FireStateMachineState();
}

class _FireStateMachineState extends State<FireWidget> {
  SMIBool? burningIntense, burning;

  final logger = getLogger(className: "FireStateMachineState");

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstSpark();
    });

    return Container(
      width: 50.0,  // Set the width of your icon
      height: 50.0,
        child: RiveAnimation.asset(
          'animations/flame.riv',
          fit: BoxFit.contain,
          alignment: Alignment.center,
          onInit: (artboard) {
            final controller = CustomStateMachineController.fromArtboard(
              artboard,
              'trkrstate',
              onInputChanged: (id, value) {
                print('callback id: $id');
              },
            );
            artboard.addController(controller!);

            controller.inputs.forEach((element) {
              if (element.name == 'burningIntense') {
                burningIntense = element as SMIBool;
              }
              if (element.name == 'burning') {
                burning = element as SMIBool;
              }
            });
            firstSpark();
          },
        ),
      );
  }

  void firstSpark() {
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    final routineLogs = exerciseAndRoutineController.whereLogsIsSameMonth(dateTime: widget.dateTimeRange.start);
    final routineLogsByDay = groupBy(routineLogs, (log) => log.createdAt.withoutTime().day);
    final monthlyProgress = routineLogsByDay.length / 12;

    if (burning != null && burningIntense != null) {
      logger.i("Triggering initial spark and burn.");

      if (monthlyProgress < 0.3) {
        burning?.change(false);
        burningIntense?.change(false);
      } else if (monthlyProgress < 0.5) {
        burning?.change(true);
        burningIntense?.change(false);
      } else if (monthlyProgress < 0.8) {
        burning?.change(true);
        burningIntense?.change(true);
      } else {
        burning?.change(true);
        burningIntense?.change(true);
      }
      logger.i("Changing burning state: ${burning?.value}"); // Burning
      logger.i("Changing burning state: ${burningIntense?.value}"); // Burning
    } else {
      logger.e("State machine inputs are not properly initialized.");
    }
  }
}


typedef InputChanged = void Function(int id, dynamic value);

class CustomStateMachineController extends StateMachineController {
  CustomStateMachineController(
      super.stateMachine, {
        core.OnStateChange? onStateChange,
        required this.onInputChanged,
      });

  final InputChanged onInputChanged;

  @override
  void setInputValue(int id, value) {
    print('Changed id: $id,  value: $value');
    for (final input in stateMachine.inputs) {
      if (input.id == id) {
        // Do something with the input
        print('Found input: $input');
      }
    }
    // Or just pass it back to the calling widget
    onInputChanged.call(id, value);
    super.setInputValue(id, value);
  }

  static CustomStateMachineController? fromArtboard(
      Artboard artboard,
      String stateMachineName, {
        core.OnStateChange? onStateChange,
        required InputChanged onInputChanged,
      }) {
    for (final animation in artboard.animations) {
      if (animation is StateMachine && animation.name == stateMachineName) {
        return CustomStateMachineController(
          animation,
          onStateChange: onStateChange,
          onInputChanged: onInputChanged,
        );
      }
    }
    return null;
  }
}