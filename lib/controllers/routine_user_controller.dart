import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/appsync/routine_user_dto.dart';

import '../models/RoutineUser.dart';
import '../repositories/amplify/amplify_routine_user_repository.dart';

class RoutineUserController extends ChangeNotifier {
  String errorMessage = '';

  late AmplifyRoutineUserRepository _amplifyRoutineUserRepository;

  RoutineUserController(AmplifyRoutineUserRepository amplifyRoutineLogRepository) {
    _amplifyRoutineUserRepository = amplifyRoutineLogRepository;
  }

  RoutineUserDto? get user => _amplifyRoutineUserRepository.user;

  void streamUsers({required List<RoutineUser> users}) async {
    _amplifyRoutineUserRepository.loadUserStream(users: users);
    notifyListeners();
  }

  Future<RoutineUserDto?> saveUser({required RoutineUserDto userDto}) async {
    RoutineUserDto? savedUser;
    try {
      savedUser = await _amplifyRoutineUserRepository.saveUser(userDto: userDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      savedUser = null;
    } finally {
      notifyListeners();
    }
    return savedUser;
  }

  Future<void> updateUser({required RoutineUserDto userDto}) async {
    try {
      await _amplifyRoutineUserRepository.updateUser(userDto: userDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeUser({required RoutineUserDto userDto}) async {
    try {
      await _amplifyRoutineUserRepository.removeUser(userDto: userDto);
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
    } finally {
      notifyListeners();
    }
  }

  int weight() {
    return _amplifyRoutineUserRepository.user?.weight ?? 0;
  }

  void clear() {
    _amplifyRoutineUserRepository.clear();
    notifyListeners();
  }
}
