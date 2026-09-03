import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu_concursos/models/repositories/assunto_repository.dart';

class AssuntoController {
  final AssuntoRepository _repository = AssuntoRepository();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot>? streamAssuntos(String concursoId, String materia) {
    if (_uid == null) return null;
    return _repository.obterAssuntosStream(_uid!, concursoId, materia);
  }

  Future<bool> adicionarAssunto(
    String concursoId,
    String materia,
    String nome,
  ) async {
    if (_uid == null) return false;
    return await _repository.adicionarAssunto(_uid!, concursoId, materia, nome);
  }

  Future<bool> excluirAssunto(String concursoId, String assuntoId) async {
    if (_uid == null) return false;
    return await _repository.excluirAssunto(_uid!, concursoId, assuntoId);
  }

  Future<bool> alternarStatusConcluido(
    String concursoId,
    String assuntoId,
    bool statusAtual,
  ) async {
    if (_uid == null) return false;
    return await _repository.alternarStatusConcluido(
      _uid!,
      concursoId,
      assuntoId,
      statusAtual,
    );
  }
}
