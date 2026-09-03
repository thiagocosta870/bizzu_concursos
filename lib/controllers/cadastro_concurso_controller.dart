import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/models/repositories/concurso_repository.dart';
import 'package:bizzu_concursos/models/repositories/edital_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class CadastroConcursoController {
  final ConcursoRepository _repository = ConcursoRepository();
  final EditalRepository _editalRepository = EditalRepository();

  Future<List<String>> buscarMateriasDaApi() async {
    return await _editalRepository.buscarMateriasDaApi();
  }

  Future<List<dynamic>> buscarListaDeEditais() async {
    return await _editalRepository.buscarListaDeEditais();
  }

  Future<Map<String, dynamic>?> buscarDetalhesDoEdital(int id) async {
    return await _editalRepository.buscarDetalhesDoEdital(id);
  }

  Future<bool> salvarConcursoImportado({
    required String nome,
    required String cargo,
    required String dataProva,
    required List<String> materiasSelecionadas,
    required List<dynamic> materiasDaApi,
    required String usuarioId,
  }) async {
    bool sucesso = await _repository.salvarConcursoEmLote(
      nome: nome,
      cargo: cargo,
      dataProva: dataProva,
      materiasSelecionadas: materiasSelecionadas,
      materiasDaApi: materiasDaApi,
      usuarioId: usuarioId,
    );

    if (sucesso) {
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: 'importar_edital_completo',
        );
      } catch (_) {}
    }

    return sucesso;
  }

  Future<bool> salvarNovoConcurso({
    required String nome,
    required String cargo,
    required String dataProva,
    required String materias,
    required String usuarioId,
  }) async {
    return await _repository.salvarConcurso(
      ConcursoModel(
        nome: nome,
        cargo: cargo,
        dataProva: dataProva,
        materias: materias,
      ),
      usuarioId,
    );
  }

  Future<bool> atualizarConcurso({
    required String id,
    required String nome,
    required String cargo,
    required String dataProva,
    required String materias,
    required String usuarioId,
  }) async {
    return await _repository.atualizarConcurso(
      ConcursoModel(
        id: id,
        nome: nome,
        cargo: cargo,
        dataProva: dataProva,
        materias: materias,
      ),
      usuarioId,
    );
  }
}
