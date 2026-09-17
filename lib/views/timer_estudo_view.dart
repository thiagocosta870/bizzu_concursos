import 'package:flutter/material.dart';
import 'package:bizzu_concursos/theme/appCores.dart';
import 'package:bizzu_concursos/controllers/timer_estudo_controller.dart';

class TimerEstudoView extends StatefulWidget {
  final String concursoId;
  final String materia;
  final String assunto;
  final String? revisaoId;

  const TimerEstudoView({
    super.key,
    required this.concursoId,
    required this.materia,
    required this.assunto,
    this.revisaoId,
  });

  @override
  State<TimerEstudoView> createState() => _TimerEstudoViewState();
}

class _TimerEstudoViewState extends State<TimerEstudoView>
    with WidgetsBindingObserver {
  final TimerEstudoController _controller = TimerEstudoController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _controller.processarCicloDeVida(state);
  }

  void _verificarEExibirAlerta() {
    if (_controller.exibirAlertaFoco) {
      _controller.resetarAlerta();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Foco perdido! Cronômetro pausado.',
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
      });
    }
  }

  void _finalizarEstudo() {
    if (_controller.estaRodando) _controller.pausarTimer();

    final tempoEstudado = _controller.obterTempoTotal();
    final minutos = tempoEstudado.inMinutes;
    DateTime? dataSelecionada;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF101820),
          title: const Text(
            'Finalizar estudo?',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Você estudou $minutos minuto(s) de ${widget.materia}.\nAssunto: ${widget.assunto}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(
                  Icons.calendar_month,
                  color: AppCores.amareloBizzu,
                ),
                label: Text(
                  dataSelecionada == null
                      ? 'Agendar próxima revisão (Opcional)'
                      : 'Revisão: ${dataSelecionada!.day.toString().padLeft(2, '0')}/${dataSelecionada!.month.toString().padLeft(2, '0')}/${dataSelecionada!.year}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppCores.amareloBizzu),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppCores.amareloBizzu,
                            onPrimary: Colors.black,
                            surface: Color(0xFF101820),
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setStateDialog(() => dataSelecionada = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCores.amareloBizzu,
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);

                await _controller.salvarTempoDeEstudo(
                  concursoId: widget.concursoId,
                  materia: widget.materia,
                  assunto: widget.assunto,
                  minutosEstudados: minutos,
                  revisaoId: widget.revisaoId,
                  dataProximaRevisao: dataSelecionada,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _verificarEExibirAlerta();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (_controller.obterTempoTotal().inSeconds > 0) {
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Center(
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
                        border: Border.all(
                          color: AppCores.amareloBizzu,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _controller.formatarTempo(),
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
                        if (!_controller.estaRodando &&
                            _controller.obterTempoTotal().inSeconds > 0)
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
                          onPressed: _controller.estaRodando
                              ? _controller.pausarTimer
                              : _controller.iniciarTimer,
                          backgroundColor: AppCores.amareloBizzu,
                          child: Icon(
                            _controller.estaRodando
                                ? Icons.pause
                                : Icons.play_arrow,
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
          ),
        );
      },
    );
  }
}
