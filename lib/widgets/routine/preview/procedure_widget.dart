import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import '../../../providers/exercise_provider.dart';
import '../../../screens/exercise_history_screen.dart';
import '../../helper_widgets/routine_helper.dart';

class ProcedureWidget extends StatelessWidget {
  final ProcedureDto procedureDto;
  final ProcedureDto? otherSuperSetProcedureDto;
  final bool readOnly;

  const ProcedureWidget({
    super.key,
    required this.procedureDto,
    required this.otherSuperSetProcedureDto, this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    final otherProcedureDto = otherSuperSetProcedureDto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(
            splashColor: tealBlueLight
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
              if(!readOnly) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ExerciseHistoryScreen(exerciseId: procedureDto.exerciseId)));
              }
            },
            title: Text(exerciseProvider.whereExercise(exerciseId: procedureDto.exerciseId).name, style: Theme.of(context).textTheme.labelLarge),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                otherProcedureDto != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text("with ${exerciseProvider.whereExercise(exerciseId: otherProcedureDto.exerciseId).name}",
                            style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                      )
                    : const SizedBox.shrink(),
                Row(children: [
                  const Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 5),
                  Text("${procedureDto.restInterval.secondsOrMinutesOrHours()} rest interval",
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
                ]),
              ],
            ),
          ),
        ),
        procedureDto.notes.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(procedureDto.notes,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15)),
              )
            : const SizedBox.shrink(),
        ...setsToWidgets(sets: procedureDto.sets),
      ],
    );
  }
}
