import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bizzu_concursos/models/repositories/historico_repository.dart';
import 'package:bizzu_concursos/models/repositories/revisao_repository.dart';

class TimerEstudoController {
  final HistoricoRepository _repository = HistoricoRepository();
  final RevisaoRepository _revisaoRepository = RevisaoRepository();

  Future<bool> salvarTempoDeEstudo({
    required String materia,
    required String assunto,
    required int minutosEstudados,
    String? revisaoId,
    DateTime? dataProximaRevisao,
  }) async {
    if (minutosEstudados <= 0) return false;

    try {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return false;

      bool sucesso = await _repository.registrarSessaoEstudo(
        usuarioId: usuario.uid,
        materia: materia,
        assunto: assunto,
        minutos: minutosEstudados,
      );

      if (sucesso) {
        if (revisaoId != null) {
          await _revisaoRepository.marcarComoConcluida(usuario.uid, revisaoId);
        }

        if (dataProximaRevisao != null) {
          await _revisaoRepository.agendarRevisaoManualmente(
            usuarioId: usuario.uid,
            materia: materia,
            assunto: assunto,
            dataEscolhida: dataProximaRevisao,
          );
        }
      }

      return sucesso;
    } catch (e) {
      debugPrint('Erro ao salvar tempo de estudo: $e');
      return false;
    }
  }
}
