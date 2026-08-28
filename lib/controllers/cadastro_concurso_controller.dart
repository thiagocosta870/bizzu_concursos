import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/models/repositories/concurso_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class CadastroConcursoController {
  final ConcursoRepository _repository = ConcursoRepository();

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
