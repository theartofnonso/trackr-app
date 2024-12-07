class ToolDto {
  final String id;
  final String name;

  ToolDto({
    required this.id,
    required this.name,
  });

  // Factory constructor to create a DTO from a map (JSON-like object)
  factory ToolDto.fromJson(Map<String, dynamic> map) {
    return ToolDto(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
    );
  }

  // Method to convert the DTO back to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}