import '../../enums/gender_enums.dart';

class RoutineUserDto {
  final String id;
  final String cognitoUserId;
  final String name;
  final String email;
  final String trainingHistory;
  final num weight;
  final num height;
  final DateTime dateOfBirth;
  final TRKRGender gender;

  RoutineUserDto(
      {required this.id,
      required this.name,
      required this.cognitoUserId,
      required this.email,
      required this.weight,
      required this.height,
      required this.trainingHistory,
      required this.dateOfBirth,
      required this.gender});

  factory RoutineUserDto.fromJson(Map<String, dynamic> json, {String id = ""}) {
    final cognitoUserId = json["cognitoUserId"] ?? "";
    final name = json["name"] ?? "";
    final email = json["email"] ?? "";
    final trainingHistory = json["trainingHistory"] ?? "";
    final weight = (json["weight"]) ?? 0.0;
    final height = (json["height"]) ?? 0;
    final dateOfBirthMillisecondsSinceEpoch =
        (json["dob"]) as int? ?? DateTime.now().millisecondsSinceEpoch;
    final dateOfBirth =
        DateTime.fromMillisecondsSinceEpoch(dateOfBirthMillisecondsSinceEpoch);
    final genderString = json["gender"] ?? "";
    final gender = TRKRGender.fromString(genderString);

    return RoutineUserDto(
        id: id,
        name: name,
        cognitoUserId: cognitoUserId,
        email: email,
        weight: weight,
        height: height,
        trainingHistory: trainingHistory,
        dateOfBirth: dateOfBirth,
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
      'dob': dateOfBirth.millisecondsSinceEpoch,
      'gender': gender.display,
      'trainingHistory': trainingHistory
    };
  }

  RoutineUserDto copyWith({
    String? id,
    String? name,
    String? cognitoUserId,
    String? email,
    String? trainingHistory,
    num? weight,
    num? height,
    DateTime? dateOfBirth,
    TRKRGender? gender,
  }) {
    return RoutineUserDto(
        id: id ?? this.id,
        name: name ?? this.name,
        cognitoUserId: cognitoUserId ?? this.cognitoUserId,
        email: email ?? this.email,
        trainingHistory: trainingHistory ?? this.trainingHistory,
        weight: weight ?? this.weight,
        height: height ?? this.height,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth);
  }

  @override
  String toString() {
    return 'RoutineUserDto{id: $id, cognitoUserId: $cognitoUserId, name: $name, trainingHistory: $trainingHistory, email: $email, weight: $weight, height: $height dateOfBirth: $dateOfBirth, gender: $gender}';
  }
}
