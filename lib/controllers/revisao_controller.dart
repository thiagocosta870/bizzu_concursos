import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu_concursos/models/repositories/revisao_repository.dart';

class RevisaoController {
  final RevisaoRepository _repository = RevisaoRepository();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot>? streamRevisoesPorData(DateTime dataAlvo) {
    if (_uid == null) return null;
    return _repository.streamRevisoesPorData(_uid!, dataAlvo);
  }

  Future<void> concluirRevisao(String revisaoId) async {
    if (_uid != null) {
      await _repository.marcarComoConcluida(_uid!, revisaoId);
    }
  }

  Future<void> desfazerConclusao(String revisaoId) async {
    if (_uid != null) {
      await _repository.desfazerConclusao(_uid!, revisaoId);
    }
  }
}
