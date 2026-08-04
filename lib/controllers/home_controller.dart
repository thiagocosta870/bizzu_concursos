import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/models/repositories/concurso_repository.dart';

class HomeController {
  final ConcursoRepository _repository = ConcursoRepository();
  List<ConcursoModel> meusConcursos = [];

  Future<void> carregarConcursos(String usuarioId) async {
    try {
      meusConcursos = await _repository.buscarConcursos(usuarioId);
    } catch (e) {
      meusConcursos = [];
    }
  }

  Future<bool> excluirConcurso(String usuarioId, String concursoId) async {
    return await _repository.excluirConcurso(usuarioId, concursoId);
  }

  void limparDados() {
    meusConcursos.clear();
  }
}
