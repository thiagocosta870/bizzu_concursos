class ConcursoModel {
  String? id;
  String nome;
  String dataProva;
  String cargo;

  ConcursoModel({
    this.id,
    required this.nome,
    required this.dataProva,
    required this.cargo,
  });

  factory ConcursoModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ConcursoModel(
      id: documentId,
      nome: map['nome'] ?? '',
      dataProva: map['dataProva'] ?? '',
      cargo: map['cargo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'dataProva': dataProva,
      'cargo': cargo,
    };
  }
}