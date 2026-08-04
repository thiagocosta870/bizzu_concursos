import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bizzu_concursos/models/concurso_model.dart';

class ConcursoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ConcursoModel>> buscarConcursos(String usuarioId) async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('concursos')
          .get();

      return snapshot.docs
          .map((doc) => ConcursoModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar concursos: $e');
      return [];
    }
  }

  Future<bool> salvarConcurso(ConcursoModel concurso, String usuarioId) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('concursos')
          .add(concurso.toMap());
      return true;
    } catch (e) {
      print('Erro ao salvar: $e');
      return false;
    }
  }

  Future<bool> atualizarConcurso(
    ConcursoModel concurso,
    String usuarioId,
  ) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('concursos')
          .doc(concurso.id)
          .update(concurso.toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar: $e');
      return false;
    }
  }

  Future<bool> excluirConcurso(String usuarioId, String concursoId) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('concursos')
          .doc(concursoId)
          .delete();
      return true;
    } catch (e) {
      print('Erro ao excluir: $e');
      return false;
    }
  }
}
