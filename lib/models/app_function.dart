class AppFunction {
  final String id;
  final String name;
  final String description;

  AppFunction({
    required this.id,
    required this.name,
    this.description = '',
  });

  factory AppFunction.fromMap(Map<String, dynamic> map) {
    return AppFunction(
      id: map['id'] ?? '',
      name: map['nome'] ?? '',
      description: map['descricao'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}