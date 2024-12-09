import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:tracker_app/dtos/appsync/routine_user_dto.dart';
import 'package:tracker_app/models/ModelProvider.dart';

import '../../shared_prefs.dart';

class AmplifyRoutineUserRepository {
  RoutineUserDto? _user;

  RoutineUserDto? get user => _user;

  void loadUserStream({required List<RoutineUser> users}) {
    if (users.isNotEmpty) {
      final onlyUser = users.first;
      _user = RoutineUserDto.toDto(onlyUser);
    }
  }

  Future<RoutineUserDto?> saveUser({required RoutineUserDto userDto}) async {
    final now = TemporalDateTime.now();

    final userToCreate = RoutineUser(
        username: userDto.name, data: jsonEncode(userDto), createdAt: now, updatedAt: now, owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineUser>(userToCreate);

    Posthog().capture(eventName: userDto.name, properties: userDto.toJson());

    final updatedUserWithId = userDto.copyWith(id: userToCreate.id, owner: SharedPrefs().userId);

    _user = updatedUserWithId;

    return updatedUserWithId;
  }

  Future<void> updateUser({required RoutineUserDto userDto}) async {
    final result = (await Amplify.DataStore.query(
      RoutineUser.classType,
      where: RoutineUser.ID.eq(userDto.id),
    ));

    if (result.isNotEmpty) {
      final oldUser = result.first;
      final newUser = oldUser.copyWith(data: jsonEncode(userDto));
      await Amplify.DataStore.save<RoutineUser>(newUser);
      _user = userDto;
    }
  }

  Future<void> removeUser({required RoutineUserDto userDto}) async {
    final result = (await Amplify.DataStore.query(
      RoutineUser.classType,
      where: RoutineUser.ID.eq(userDto.id),
    ));

    if (result.isNotEmpty) {
      final oldUser = result.first;
      await Amplify.DataStore.delete<RoutineUser>(oldUser);
      _user = userDto;
    }
  }

  void clear() {
    _user = null;
  }
}
