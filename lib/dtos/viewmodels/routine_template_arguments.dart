import 'package:tracker_app/dtos/routine_template_dto.dart';

class RoutineTemplateArguments {
  final RoutineTemplateDto template;
  final bool shouldLogTemplate;

  RoutineTemplateArguments({required this.template, this.shouldLogTemplate = false});
}