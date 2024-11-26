import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/appsync/routine_user_dto.dart';

import '../logger.dart';
import '../models/RoutineUser.dart';
import '../repositories/amplify/amplify_routine_user_repository.dart';

class RoutineUserController extends ChangeNotifier {
  String errorMessage = '';

  final logger = getLogger(className: "RoutineUserController");

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
      logger.i("saved user $userDto");
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      savedUser = null;
      logger.e("Error saving user $userDto",error: e);
    } finally {
      notifyListeners();
    }
    return savedUser;
  }

  Future<void> updateUser({required RoutineUserDto userDto}) async {
    try {
      await _amplifyRoutineUserRepository.updateUser(userDto: userDto);
      logger.i("update user $userDto");
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error updating user $userDto",error: e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeUser({required RoutineUserDto userDto}) async {
    try {
      await _amplifyRoutineUserRepository.removeUser(userDto: userDto);
      logger.i("remove user $userDto");
    } catch (e) {
      errorMessage = "Oops! Something went wrong. Please try again later.";
      logger.e("Error removing user $userDto",error: e);
    } finally {
      notifyListeners();
    }
  }

  double weight() {
    return _amplifyRoutineUserRepository.user?.weight ?? 0;
  }

  void clear() {
    _amplifyRoutineUserRepository.clear();
    notifyListeners();
  }
}
