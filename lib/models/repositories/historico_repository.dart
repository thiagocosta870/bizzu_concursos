import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class HistoricoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> registrarSessaoEstudo({
    required String usuarioId,
    required String materia,
    required String assunto,
    required int minutos,
  }) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuarioId)
          .collection('historico_estudos')
          .add({
            'materia': materia,
            'assunto': assunto,
            'minutos': minutos,
            'data': FieldValue.serverTimestamp(),
            'timestampLocal': DateTime.now().millisecondsSinceEpoch,
          });

      return true;
    } catch (e) {
      debugPrint('Erro no repositório ao salvar histórico: $e');
      return false;
    }
  }
}
