import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/models/repositories/concurso_repository.dart';

class HomeController {
  final ConcursoRepository _repository = ConcursoRepository();

  List<ConcursoModel> meusConcursos = [];

  Future<void> carregarConcursos(String usuarioId) async {
    try {
      meusConcursos = await _repository.buscarConcursos(usuarioId);
    } catch (e) {
      print('Erro no controller ao carregar concursos: $e');
      meusConcursos = [];
    }
  }

  void limparDados() {
    meusConcursos.clear();
  }
}