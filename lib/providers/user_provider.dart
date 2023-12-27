import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../models/User.dart';
import '../shared_prefs.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> createUser() async {
    final authUser = await Amplify.Auth.getCurrentUser();
    final signInDetails = authUser.signInDetails.toJson();
    final email = signInDetails["username"] as String;
    final id = authUser.userId;
    final newUser = User(id: id, email: email, createdAt: TemporalDateTime.now(), updatedAt: TemporalDateTime.now());
    await Amplify.DataStore.save(newUser);
    _user = newUser;
    SharedPrefs().user = jsonEncode(_user);
  }

  void fetchUser() {
    _user = cachedUser();
  }

  void delete() {
    final user = _user;
    if(user == null) {
      return;
    }

    Amplify.DataStore.delete<User>(user, where: User.ID.eq(user.id));
  }
}