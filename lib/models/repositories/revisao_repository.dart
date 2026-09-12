import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RevisaoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> agendarRevisaoManualmente({
    required String usuarioId,
    required String materia,
    required String assunto,
    required DateTime dataEscolhida,
  }) async {
    try {
      final dataFiltro = DateTime(
        dataEscolhida.year,
        dataEscolhida.month,
        dataEscolhida.day,
      );

      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('revisoes')
          .doc()
          .set({
            'materia': materia,
            'assunto': assunto,
            'dataAgendada': dataFiltro.millisecondsSinceEpoch,
            'concluido': false,
            'criadoEm': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      debugPrint('Erro ao agendar revisão manual: $e');
      return false;
    }
  }

  Stream<QuerySnapshot> streamRevisoesPorData(
    String usuarioId,
    DateTime dataAlvo,
  ) {
    final hoje = DateTime.now();
    final isHoje =
        dataAlvo.year == hoje.year &&
        dataAlvo.month == hoje.month &&
        dataAlvo.day == hoje.day;

    final fimDoDia = DateTime(
      dataAlvo.year,
      dataAlvo.month,
      dataAlvo.day,
      23,
      59,
      59,
    );

    if (isHoje) {
      return _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('revisoes')
          .where('concluido', isEqualTo: false)
          .where(
            'dataAgendada',
            isLessThanOrEqualTo: fimDoDia.millisecondsSinceEpoch,
          )
          .snapshots();
    } else {
      final inicioDoDia = DateTime(
        dataAlvo.year,
        dataAlvo.month,
        dataAlvo.day,
        0,
        0,
        0,
      );
    }
    return _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('revisoes')
        .where('concluido', isEqualTo: false)
        .where(
          'dataAgendada',
          isLessThanOrEqualTo: fimDoDia.millisecondsSinceEpoch,
        )
        .snapshots();
  }

  Future<void> marcarComoConcluida(String usuarioId, String revisaoId) async {
    await _firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('revisoes')
        .doc(revisaoId)
        .update({'concluido': true});
  }
}
