import 'dart:convert';
import 'package:http/http.dart' as http;
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

    if (sucesso) {
      try {
        await FirebaseAnalytics.instance.logEvent(name: 'cadastrar_concurso');
        debugPrint('ANALYTICS: Concurso cadastrado com sucesso!');
      } catch (e) {
        debugPrint('ANALYTICS ERRO: $e');
      }
    }
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

    if (sucesso) {
      try {
        await FirebaseAnalytics.instance.logEvent(name: 'editar_concurso');
        debugPrint('ANALYTICS: Edição de concurso registrada!');
      } catch (e) {
        debugPrint('ANALYTICS ERRO: $e');
      }
    }
    return sucesso;
  }
}