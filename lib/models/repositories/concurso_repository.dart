import 'package:bizzu_concursos/models/concurso_model.dart';

class ConcursoRepository {
  
  Future<List<ConcursoModel>> buscarConcursos(String usuarioId) async {
    try {
      // TODO: Aqui entrará o código do Firebase Firestore (collection.get)
      return [];
    } catch (e) {
      print('Erro no repositório ao buscar concursos: $e');
      return []; 
    }
  }

  Future<bool> salvarConcurso(ConcursoModel concurso, String usuarioId) async {
    try {
      return true; 
    } catch (e) {
      print('Erro no repositório ao salvar concurso: $e');
      return false; 
    }
  }
}