import 'dart:convert';

import '../../enums/gender_enums.dart';
import '../../models/RoutineUser.dart';

class RoutineUserDto {
  final String id;
  final String cognitoUserId;
  final String name;
  final String email;
  final num weight;
  final num height;
  final DateTime dateOfBirth;
  final TRKRGender gender;
  final String owner;

  RoutineUserDto(
      {required this.id,
      required this.name,
      required this.cognitoUserId,
      required this.email,
      required this.weight,
        required this.height,
      required this.owner,
      required this.dateOfBirth,
      required this.gender});

  factory RoutineUserDto.toDto(RoutineUser user) {
    return RoutineUserDto.fromJson(user);
  }

  factory RoutineUserDto.fromJson(RoutineUser user) {
    final json = jsonDecode(user.data);
    final cognitoUserId = json["cognitoUserId"] ?? "";
    final name = json["name"] ?? "";
    final email = json["email"] ?? "";
    final weight = (json["weight"]) ?? 0.0;
    final height = (json["height"]) ?? 0.0;
    final dateOrBirth = (json["dob"]) ?? DateTime.now();
    final genderString = json["gender"] ?? "";
    final gender = TRKRGender.fromString(genderString);

    return RoutineUserDto(
        id: user.id,
        name: name,
        cognitoUserId: cognitoUserId,
        email: email,
        weight: weight,
        height: height,
        owner: user.owner ?? "",
        dateOfBirth: dateOrBirth,
        gender: gender);
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'cognitoUserId': cognitoUserId,
      'name': name,
      'email': email,
      'weight': weight,
      'height': height,
      'dob': dateOfBirth,
      'gender': gender,
    };
  }

  RoutineUserDto copyWith({
    String? id,
    String? name,
    String? cognitoUserId,
    String? email,
    num? weight,
    num? height,
    String? owner,
    DateTime? dateOfBirth,
    TRKRGender? gender,
  }) {
    return RoutineUserDto(
        id: id ?? this.id,
        name: name ?? this.name,
        cognitoUserId: cognitoUserId ?? this.cognitoUserId,
        email: email ?? this.email,
        weight: weight ?? this.weight,
        height: height ?? this.height,
        owner: owner ?? this.owner,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth);
  }

  @override
  String toString() {
    return 'RoutineUserDto{id: $id, cognitoUserId: $cognitoUserId, name: $name, email: $email, weight: $weight, height: $height dateOfBirth: $dateOfBirth, gender: $gender,  owner: $owner}';
  }
}
