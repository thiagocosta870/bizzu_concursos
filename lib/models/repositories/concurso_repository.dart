import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:flutter/foundation.dart'; 

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
      debugPrint('Erro ao buscar concursos: $e');
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
      debugPrint('Erro ao salvar: $e');
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
      debugPrint('Erro ao atualizar: $e');
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
      debugPrint('Erro ao excluir: $e');
      return false;
    }
  }

  Future<bool> salvarConcursoEmLote({
    required String nome,
    required String cargo,
    required String dataProva,
    required List<String> materiasSelecionadas,
    required List<dynamic> materiasDaApi,
    required String usuarioId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final docRef = firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('concursos')
          .doc();

      final batch = firestore.batch();

      batch.set(docRef, {
        'id': docRef.id,
        'nome': nome,
        'cargo': cargo,
        'dataProva': dataProva,
        'materias': materiasSelecionadas.join('|'),
      });

      for (String nomeMateria in materiasSelecionadas) {
        final materiaApi = materiasDaApi.firstWhere(
          (m) => m['nome'] == nomeMateria,
          orElse: () => null,
        );

        if (materiaApi != null && materiaApi['assuntos'] != null) {
          List<dynamic> assuntos = materiaApi['assuntos'];

          for (String nomeAssunto in assuntos) {
            final assuntoRef = docRef.collection('assuntos').doc();
            batch.set(assuntoRef, {
              'materia': nomeMateria,
              'nome': nomeAssunto,
              'concluido': false,
              'criadoEm': DateTime.now().millisecondsSinceEpoch,
            });
          }
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Erro no Batch Write do Concurso: $e');
      return false;
    }
  }
}
