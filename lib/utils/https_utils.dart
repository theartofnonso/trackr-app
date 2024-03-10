import 'package:amplify_flutter/amplify_flutter.dart';


Future<String> getAPI({required String endpoint}) async {
  final restOperation = Amplify.API.get(endpoint);
  final restResponse = await restOperation.response;
  return restResponse.decodeBody();
}