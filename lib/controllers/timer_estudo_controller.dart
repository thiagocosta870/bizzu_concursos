import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:screen_state/screen_state.dart';
import 'package:bizzu_concursos/models/repositories/historico_repository.dart';
import 'package:bizzu_concursos/models/repositories/revisao_repository.dart';

class TimerEstudoController extends ChangeNotifier {
  final HistoricoRepository _repository = HistoricoRepository();
  final RevisaoRepository _revisaoRepository = RevisaoRepository();

  DateTime? _horaInicio;
  Duration _tempoAcumulado = Duration.zero;
  DateTime? _horaPausa;
  Timer? _timerUI;

  bool estaRodando = false;
  bool perdeuFoco = false;
  bool exibirAlertaFoco = false;

  final Screen _screen = Screen();
  StreamSubscription<ScreenStateEvent>? _screenSubscription;
  DateTime? _ultimaVezQueATelaApagou;

  TimerEstudoController() {
    _iniciarDetectorDeTela();
  }

  void _iniciarDetectorDeTela() {
    try {
      _screenSubscription = _screen.screenStateStream.listen((event) {
        if (event == ScreenStateEvent.screenOff) {
          _ultimaVezQueATelaApagou = DateTime.now();
          _tentarResgatarCronometro();
        }
      });
    } catch (e) {
      debugPrint('Erro no detector de tela: $e');
    }
  }

  void _tentarResgatarCronometro() {
    if (perdeuFoco && _horaPausa != null && _ultimaVezQueATelaApagou != null) {
      final diferencaSegundos = _horaPausa!
          .difference(_ultimaVezQueATelaApagou!)
          .inSeconds
          .abs();

      if (diferencaSegundos <= 2) {
        perdeuFoco = false;
        estaRodando = true;

        _horaInicio = _horaPausa!.subtract(_tempoAcumulado);
        _tempoAcumulado = Duration.zero;
        _horaPausa = null;

        notifyListeners();
      }
    }
  }

  void processarCicloDeVida(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (estaRodando) {
        _horaPausa = DateTime.now();
        _tempoAcumulado += _horaPausa!.difference(_horaInicio!);
        _horaInicio = null;
        estaRodando = false;
        perdeuFoco = true;

        _tentarResgatarCronometro();
        notifyListeners();
      }
    } else if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (perdeuFoco) {
          perdeuFoco = false;
          _horaPausa = null;
          exibirAlertaFoco = true;
        }
        notifyListeners();
      });
    }
  }

  void iniciarTimer() {
    _horaInicio = DateTime.now();
    estaRodando = true;
    _horaPausa = null;
    perdeuFoco = false;
    exibirAlertaFoco = false;

    _timerUI?.cancel();
    _timerUI = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners();
    });
    notifyListeners();
  }

  void pausarTimer() {
    if (_horaInicio != null) {
      _tempoAcumulado += DateTime.now().difference(_horaInicio!);
      _horaInicio = null;
    }
    _timerUI?.cancel();
    estaRodando = false;
    notifyListeners();
  }

  Duration obterTempoTotal() {
    if (_horaInicio != null && estaRodando) {
      return _tempoAcumulado + DateTime.now().difference(_horaInicio!);
    }
    return _tempoAcumulado;
  }

  String formatarTempo() {
    final tempo = obterTempoTotal();
    final horas = tempo.inHours.toString().padLeft(2, '0');
    final minutos = (tempo.inMinutes % 60).toString().padLeft(2, '0');
    final segundos = (tempo.inSeconds % 60).toString().padLeft(2, '0');

    if (horas == '00') return '$minutos:$segundos';
    return '$horas:$minutos:$segundos';
  }

  void resetarAlerta() {
    exibirAlertaFoco = false;
  }

  @override
  void dispose() {
    _timerUI?.cancel();
    _screenSubscription?.cancel();
    super.dispose();
  }

  Future<bool> salvarTempoDeEstudo({
    required String concursoId,
    required String materia,
    required String assunto,
    required int minutosEstudados,
    String? revisaoId,
    DateTime? dataProximaRevisao,
  }) async {
    int minutosParaSalvar = minutosEstudados;
    if (minutosParaSalvar <= 0 && obterTempoTotal().inSeconds > 0) {
      minutosParaSalvar = 1;
    }

    if (minutosParaSalvar <= 0) return false;

    try {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return false;

      bool sucesso = await _repository.registrarSessaoEstudo(
        usuarioId: usuario.uid,
        concursoId: concursoId,
        materia: materia,
        assunto: assunto,
        minutos: minutosParaSalvar,
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
