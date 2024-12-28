import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  RiveFile? _riveFile;
  var _monthlyProgress;
  final logger = getLogger(className: "FireStateMachineState");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          return SizedBox(
            width: 50.0,  // Set the width of your icon
            height: 50.0,
            child:
              RiveAnimation.direct(_riveFile!, onInit: _onRiveInit,),
          );
        }
        else{
          return CircularProgressIndicator();
        }
      },
    );
  }

  void _onRiveInit(Artboard artboard) {
    final controller = CustomStateMachineController.fromArtboard(
        artboard, 'trkrstate',
        onInputChanged: (int id, value) {});
    if (controller != null) {
      artboard.addController(controller);
    }
    controller?.inputs.forEach((element) {
      if (element.name == 'burning') {
        burning = element as SMIBool;
      }
      if (element.name == 'burningIntense') {
        burningIntense = element as SMIBool;
      }
    });
    sparkController();
  }

    @override
  void initState() {
    super.initState();
      rootBundle.load('animations/flame.riv').then(
            (data) async {
          await RiveFile.initialize();
          final file = RiveFile.import(data);
          _riveFile = file;});
  }

  Future<double> getData(){
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    final routineLogs = exerciseAndRoutineController.whereLogsIsSameMonth(dateTime: widget.dateTimeRange.start);
    final routineLogsByDay = groupBy(routineLogs, (log) => log.createdAt.withoutTime().day);
    final monthlyProgress = routineLogsByDay.length / 12;
    _monthlyProgress = monthlyProgress;
    return Future.value(monthlyProgress);
  }

  void sparkController() {
    if (burning != null && burningIntense != null) {
      logger.i("Triggering spark controller");
      if (_monthlyProgress < 0.3) {
        burning?.change(false);
        burningIntense?.change(false);
      } else if (_monthlyProgress < 0.5) {
        burning?.change(true);
        burningIntense?.change(false);
      } else if (_monthlyProgress < 0.8) {
        burning?.change(true);
        burningIntense?.change(true);
      } else {
        burning?.change(true);
        burningIntense?.change(true);
      }
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