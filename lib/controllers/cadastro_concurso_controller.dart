import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/models/repositories/concurso_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class CadastroConcursoController {
  final ConcursoRepository _repository = ConcursoRepository();
  final String _baseUrl = 'https://api-bizzu-concursos.vercel.app';

  Future<List<String>> buscarMateriasDaApi() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/materias'));
      if (response.statusCode == 200) {
        List<dynamic> dados = json.decode(utf8.decode(response.bodyBytes));
        return dados.cast<String>();
      }
    } catch (e) {
      debugPrint('Erro ao buscar matérias da API: $e');
    }
    return [];
  }

  Future<List<dynamic>> buscarListaDeEditais() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/editais'));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint('Erro ao buscar editais: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> buscarDetalhesDoEdital(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/editais/$id'));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint('Erro ao buscar detalhes do edital $id: $e');
    }
    return null;
  }

  Future<bool> salvarConcursoImportado({
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

      try {
        await FirebaseAnalytics.instance.logEvent(
          name: 'importar_edital_completo',
        );
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('Erro no Batch Write: $e');
      return false;
    }
  }

  Future<bool> salvarNovoConcurso({
    required String nome,
    required String cargo,
    required String dataProva,
    required String materias,
    required String usuarioId,
  }) async {
    bool sucesso = await _repository.salvarConcurso(
      ConcursoModel(
        nome: nome,
        cargo: cargo,
        dataProva: dataProva,
        materias: materias,
      ),
      usuarioId,
    );
    return sucesso;
  }

  Future<bool> atualizarConcurso({
    required String id,
    required String nome,
    required String cargo,
    required String dataProva,
    required String materias,
    required String usuarioId,
  }) async {
    bool sucesso = await _repository.atualizarConcurso(
      ConcursoModel(
        id: id,
        nome: nome,
        cargo: cargo,
        dataProva: dataProva,
        materias: materias,
      ),
      usuarioId,
    );
    return sucesso;
  }
}
