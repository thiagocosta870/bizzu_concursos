import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EditalRepository {
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
}
