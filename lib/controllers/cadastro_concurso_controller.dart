import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/models/repositories/concurso_repository.dart';

class CadastroConcursoController {
  final ConcursoRepository _repository = ConcursoRepository();

  Future<bool> salvarNovoConcurso({
    required String nome,
    required String cargo,
    required String dataProva,
    required String materias,
    required String usuarioId,
  }) async {
    final novoConcurso = ConcursoModel(
      nome: nome,
      cargo: cargo,
      dataProva: dataProva,
      materias: materias,
    );
    return await _repository.salvarConcurso(novoConcurso, usuarioId);
  }

  Future<bool> atualizarConcurso({
    required String id,
    required String nome,
    required String cargo,
    required String dataProva,
    required String materias,
    required String usuarioId,
  }) async {
    final concursoAtualizado = ConcursoModel(
      id: id,
      nome: nome,
      cargo: cargo,
      dataProva: dataProva,
      materias: materias,
    );
    return await _repository.atualizarConcurso(concursoAtualizado, usuarioId);
  }
}
