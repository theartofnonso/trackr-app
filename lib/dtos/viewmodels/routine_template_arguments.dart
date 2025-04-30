import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';

class RoutineTemplateArguments {
  final RoutineTemplateDto? template;
  final String planId;

  RoutineTemplateArguments({this.template, required this.planId});
}