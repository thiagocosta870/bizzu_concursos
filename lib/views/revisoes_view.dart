import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bizzu_concursos/theme/appCores.dart';
import 'package:bizzu_concursos/controllers/revisao_controller.dart';
import 'package:bizzu_concursos/views/timer_estudo_view.dart';

class RevisoesView extends StatefulWidget {
  const RevisoesView({super.key});

  @override
  State<RevisoesView> createState() => _RevisoesViewState();
}

class _RevisoesViewState extends State<RevisoesView> {
  final RevisaoController _controller = RevisaoController();
  DateTime _dataSelecionada = DateTime.now();

  String _formatarDataVisual(DateTime data) {
    final hoje = DateTime.now();
    if (data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day) {
      return 'Hoje';
    }
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState() {
    final hoje = DateTime.now();
    final isHoje =
        _dataSelecionada.year == hoje.year &&
        _dataSelecionada.month == hoje.month &&
        _dataSelecionada.day == hoje.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isHoje ? Icons.task_alt : Icons.event_busy,
            size: 72,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            isHoje ? 'Tudo em dia!' : 'Nenhuma revisão agendada',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isHoje
                ? 'Quando você estudar um assunto, ele aparecerá aqui nos dias exatos que você configurar para revisar.'
                : 'Você não tem cartões para revisar nesta data. Aproveite para focar em assuntos novos!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minhas Revisões',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.calendar_month,
                  color: AppCores.amareloBizzu,
                ),
                label: Text(
                  _formatarDataVisual(_dataSelecionada),
                  style: const TextStyle(
                    color: AppCores.amareloBizzu,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dataSelecionada,
                    firstDate: DateTime(2023),
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
                    setState(() => _dataSelecionada = picked);
                  }
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _controller.streamRevisoesPorData(_dataSelecionada),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erro ao carregar',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppCores.amareloBizzu,
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final id = docs[index].id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: const Color(0xFF101820),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppCores.amareloBizzu),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        title: Text(
                          data['materia'],
                          style: const TextStyle(
                            color: AppCores.amareloBizzu,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            data['assunto'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                              tooltip: 'Revisar Agora',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TimerEstudoView(
                                      materia: data['materia'],
                                      assunto: data['assunto'],
                                      revisaoId: id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: AppCores.amareloBizzu,
                                size: 28,
                              ),
                              tooltip: 'Marcar como Feito',
                              onPressed: () => _controller.concluirRevisao(id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
