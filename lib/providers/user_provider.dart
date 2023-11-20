import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';

class UserProvider with ChangeNotifier {
  late final User _user;

  User get user => _user;

  // void fetchUser() async {
  //
  //   final authUser = await Amplify.Auth.getCurrentUser();
  //
  //   final request = ModelQueries.get(
  //     User.classType,
  //     UserModelIdentifier(id: authUser.userId),
  //   );
  //   final response = await Amplify.API.query(request: request).response;
  //   final user = response.data;
  //   if (user != null) {
  //     _user = user;
  //   }
  // }
  void reset() {
    _user = User(email: "");
    notifyListeners();
  }
}
