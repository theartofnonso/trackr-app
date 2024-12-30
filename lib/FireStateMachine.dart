import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:rive/src/rive_core/state_machine_controller.dart' as core;
import 'package:tracker_app/utils/exercise_logs_utils.dart';
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
  late double _activityDays, _trainedDays;
  final logger = getLogger(className: "FireStateMachineState");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          return SizedBox(
            width: 50.0,
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
    sparkController(this.context, false);
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
    final monthlyRoutineLogs = getMonthlyRoutineLogs(context: context, startDate: widget.dateTimeRange.start);
    final monthlyActivityLogs = getMonthlyActivityLog(context: context, startDate: widget.dateTimeRange.start);

    double trainedDays = monthlyRoutineLogs.length.toDouble();
    double activityDays = monthlyActivityLogs.length.toDouble();

    _trainedDays = trainedDays;
    _activityDays = activityDays;
    return Future.value(activityDays);
  }

  void sparkController(context, bool consolidatedActivities){
    double totalMonthDays = widget.dateTimeRange.end.day + 0.0; //4 weeks
    double dayOfMonth ;
    if(DateTime.now().month == widget.dateTimeRange.end.month){
      dayOfMonth = DateTime.now().day.toDouble(); //get the day of today
    }else{
      dayOfMonth = widget.dateTimeRange.end.day.toDouble(); //get end of month day
    }
     double goalPercentage = (12/totalMonthDays *100).round() / 100;
     double halfPoint = (goalPercentage*0.5 * 100).round() / 100;
     double eightyPercent = (goalPercentage*0.75 * 100).round() / 100;

    double currentPercentage;
    if(consolidatedActivities){
      currentPercentage = (_trainedDays+_activityDays)/dayOfMonth;
    }else{
      currentPercentage = _trainedDays/dayOfMonth;
    }

    if(currentPercentage<halfPoint){
      burning?.change(false);
      burningIntense?.change(false);
    }else if (currentPercentage > halfPoint && currentPercentage < eightyPercent){
      burning?.change(true);
      burningIntense?.change(false);
    }else if (currentPercentage >= eightyPercent){
      burning?.change(true);
      burningIntense?.change(true);
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