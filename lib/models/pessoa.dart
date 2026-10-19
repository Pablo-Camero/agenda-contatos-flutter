class Pessoa {
  int id;
  String nome;
  String email;
  int idade;
  String telefone;

  Pessoa({
    this.id = 0,
    required this.nome,
    required this.email,
    required this.idade,
    required this.telefone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'idade': idade,
      'telefone': telefone,
    };
  }

  static Pessoa fromMap(Map<String, dynamic> map) {
    return Pessoa(
      id: map['id'] as int,
      nome: map['nome'] as String,
      email: map['email'] as String,
      idade: map['idade'] as int,
      telefone: map['telefone'] as String,
    );
  }
}