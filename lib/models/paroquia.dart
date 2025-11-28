class Paroquia {
  final String id;
  final String nome;

  Paroquia({required this.id, required this.nome});

  factory Paroquia.fromMap(Map<String, dynamic> map) {
    return Paroquia(
      id: map['id'],
      nome: map['nome'],
    );
  }
}
