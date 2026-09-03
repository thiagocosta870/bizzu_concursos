import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AssuntoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> obterAssuntosStream(
    String usuarioId,
    String concursoId,
    String materia,
  ) {
    return _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('concursos')
        .doc(concursoId)
        .collection('assuntos')
        .where('materia', isEqualTo: materia)
        .snapshots();
  }

  Future<bool> adicionarAssunto(
    String usuarioId,
    String concursoId,
    String materia,
    String nome,
  ) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('concursos')
          .doc(concursoId)
          .collection('assuntos')
          .add({
            'materia': materia,
            'nome': nome,
            'concluido': false,
            'criadoEm': DateTime.now().millisecondsSinceEpoch,
          });
      return true;
    } catch (e) {
      debugPrint('Erro ao adicionar assunto: $e');
      return false;
    }
  }

  Future<bool> excluirAssunto(
    String usuarioId,
    String concursoId,
    String assuntoId,
  ) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('concursos')
          .doc(concursoId)
          .collection('assuntos')
          .doc(assuntoId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir assunto: $e');
      return false;
    }
  }

  Future<bool> alternarStatusConcluido(
    String usuarioId,
    String concursoId,
    String assuntoId,
    bool statusAtual,
  ) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('concursos')
          .doc(concursoId)
          .collection('assuntos')
          .doc(assuntoId)
          .update({'concluido': !statusAtual});
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar status do assunto: $e');
      return false;
    }
  }
}
