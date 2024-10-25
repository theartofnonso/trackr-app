import 'dart:convert';

import 'package:tracker_app/models/ModelProvider.dart';

import '../../dtos/routine_user_dto.dart';

extension RoutineUserExtension on RoutineUser {
  RoutineUserDto dto() {
    final json = jsonDecode(data);
    final cognitoUserId = json["cognitoUserId"] ?? "";
    final name = json["name"] ?? "";
    final email = json["email"];
    final owner = json["owner"] ?? "";
    return RoutineUserDto(id: id, name: name, cognitoUserId: cognitoUserId, email: email, owner: owner);
  }
}
