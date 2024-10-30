
class RoutineUserDto {
  final String id;
  final String cognitoUserId;
  final String name;
  final String email;
  final String owner;

  RoutineUserDto(
      {required this.id, required this.name, required this.cognitoUserId, required this.email, required this.owner});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cognitoUserId': cognitoUserId,
      'name': name,
      'email': email,
      'owner': owner,
    };
  }

  factory RoutineUserDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? "";
    final cognitoUserId = json["cognitoUserId"] ?? "";
    final name = json["name"] ?? "";
    final email = json["email"] ?? "";
    final owner = json["owner"] ?? "";
    return RoutineUserDto(id: id, name: name, cognitoUserId: cognitoUserId, email: email, owner: owner.toString());
  }

  RoutineUserDto copyWith({
    String? id,
    String? name,
    String? cognitoUserId,
    String? email,
    String? owner,
  }) {
    return RoutineUserDto(
        id: id ?? this.id,
        name: name ?? this.name,
        cognitoUserId: cognitoUserId ?? this.cognitoUserId,
        email: email ?? this.email,
        owner: owner ?? this.owner);
  }

  @override
  String toString() {
    return 'RoutineUserDto{id: $id, cognitoUserId: $cognitoUserId, name: $name, email: $email, owner: $owner}';
  }

}
