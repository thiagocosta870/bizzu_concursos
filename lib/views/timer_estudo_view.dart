import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bizzu_concursos/theme/appCores.dart';
import 'package:bizzu_concursos/controllers/timer_estudo_controller.dart';

class TimerEstudoView extends StatefulWidget {
  final String materia;
  final String assunto;

  const TimerEstudoView({
    super.key,
    required this.materia,
    required this.assunto,
  });

  @override
  State<TimerEstudoView> createState() => _TimerEstudoViewState();
}

class _TimerEstudoViewState extends State<TimerEstudoView>
    with WidgetsBindingObserver {
  final TimerEstudoController _controller = TimerEstudoController();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  bool _estaRodando = false;
  bool _perdeuFoco = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_estaRodando) {
        _pausarTimer();
        _perdeuFoco = true;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_perdeuFoco) {
        _perdeuFoco = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Foco perdido! Seu cronômetro foi pausado porque você saiu do aplicativo.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _iniciarTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    setState(() {
      _estaRodando = true;
    });
  }

  void _pausarTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {
      _estaRodando = false;
    });
  }

  void _finalizarEstudo() {
    if (_estaRodando) {
      _pausarTimer();
    }

    final tempoEstudado = _stopwatch.elapsed;
    final minutos = tempoEstudado.inMinutes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101820),
        title: const Text(
          'Finalizar estudo?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Você estudou $minutos minuto(s) de ${widget.materia}.\n\n'
          'Assunto: ${widget.assunto}\n\n'
          'Deseja salvar e registrar esse tempo no seu Dashboard?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Voltar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppCores.amareloBizzu,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);

              await _controller.salvarTempoDeEstudo(
                materia: widget.materia,
                assunto: widget.assunto,
                minutosEstudados: minutos,
              );

              if (mounted) {
                navigator.pop();
                navigator.pop(tempoEstudado);
              }
            },
            child: const Text(
              'Salvar e Sair',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarTempo() {
    final horas = _stopwatch.elapsed.inHours.toString().padLeft(2, '0');
    final minutos = (_stopwatch.elapsed.inMinutes % 60).toString().padLeft(
      2,
      '0',
    );
    final segundos = (_stopwatch.elapsed.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );

    if (horas == '00') {
      return '$minutos:$segundos';
    }
    return '$horas:$minutos:$segundos';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_stopwatch.elapsedTicks > 0) {
          _finalizarEstudo();
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF02080C),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppCores.amareloBizzu),
          title: const Text(
            'Foco nos Estudos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.materia,
                      style: const TextStyle(
                        color: AppCores.amareloBizzu,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.assunto,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),

              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppCores.amareloBizzu, width: 3),
                ),
                child: Center(
                  child: Text(
                    _formatarTempo(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 64),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_estaRodando && _stopwatch.elapsedTicks > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: FloatingActionButton(
                        heroTag: 'btn_stop',
                        onPressed: _finalizarEstudo,
                        backgroundColor: Colors.redAccent,
                        child: const Icon(
                          Icons.stop,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),

                  FloatingActionButton(
                    heroTag: 'btn_play_pause',
                    onPressed: _estaRodando ? _pausarTimer : _iniciarTimer,
                    backgroundColor: AppCores.amareloBizzu,
                    child: Icon(
                      _estaRodando ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
