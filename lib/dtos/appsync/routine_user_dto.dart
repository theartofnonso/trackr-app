class RoutineUserDto {
  final String id;
  final String cognitoUserId;
  final String name;
  final String email;
  final double weight;
  final String owner;

  RoutineUserDto(
      {required this.id,
      required this.name,
      required this.cognitoUserId,
      required this.email,
      required this.weight,
      required this.owner});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cognitoUserId': cognitoUserId,
      'name': name,
      'email': email,
      'weight': weight,
      'owner': owner,
    };
  }

  factory RoutineUserDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? "";
    final cognitoUserId = json["cognitoUserId"] ?? "";
    final name = json["name"] ?? "";
    final email = json["email"] ?? "";
    final weight = json["weight"] ?? 0.0;
    final owner = json["owner"] ?? "";
    return RoutineUserDto(
        id: id, name: name, cognitoUserId: cognitoUserId, email: email, weight: weight, owner: owner.toString());
  }

  RoutineUserDto copyWith({
    String? id,
    String? name,
    String? cognitoUserId,
    String? email,
    double? weight,
    String? owner,
  }) {
    return RoutineUserDto(
        id: id ?? this.id,
        name: name ?? this.name,
        cognitoUserId: cognitoUserId ?? this.cognitoUserId,
        email: email ?? this.email,
        weight: weight ?? this.weight,
        owner: owner ?? this.owner);
  }

  @override
  String toString() {
    return 'RoutineUserDto{id: $id, cognitoUserId: $cognitoUserId, name: $name, email: $email, weight: $weight, owner: $owner}';
  }
}
