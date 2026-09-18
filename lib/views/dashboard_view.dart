import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bizzu_concursos/theme/appCores.dart';
import 'package:bizzu_concursos/controllers/dashboard_controller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardController _controller = DashboardController();

  Stream<QuerySnapshot>? _streamDesempenho;
  Stream<QuerySnapshot>? _streamHistoricoRecente;
  Stream<QuerySnapshot>? _streamMeusConcursos;
  Stream<QuerySnapshot>? _streamAssuntosDoConcurso;

  String _concursoSelecionadoId = 'geral';
  int _diasFiltro = 7;

  final List<Color> _coresGrafico = [
    AppCores.amareloBizzu,
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    _streamMeusConcursos = _controller.streamMeusConcursos();
    _streamHistoricoRecente = _controller.streamHistoricoRecente();
    _atualizarStreamDesempenho();
  }

  void _atualizarStreamDesempenho() {
    _streamDesempenho = _controller.streamDesempenho(_diasFiltro);
  }

  void _atualizarStreamAssuntos(String concursoId) {
    if (concursoId != 'geral') {
      _streamAssuntosDoConcurso = _controller.streamAssuntosDoConcurso(
        concursoId,
      );
    }
  }

  double _obterMaxY(Map<int, int> tempoPorDia) {
    int max = 0;
    for (var valor in tempoPorDia.values) {
      if (valor > max) max = valor;
    }
    return (max + 10).toDouble();
  }

  Widget _buildFiltroTempo(String texto, int valorDias) {
    bool selecionado = _diasFiltro == valorDias;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _diasFiltro = valorDias;
            _atualizarStreamDesempenho();
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selecionado
                ? AppCores.amareloBizzu
                : const Color(0xFF101820),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selecionado ? AppCores.amareloBizzu : Colors.white12,
            ),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selecionado ? Colors.black : Colors.white70,
              fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _streamMeusConcursos,
              builder: (context, snapshot) {
                // Adicionado chaves aqui também por boa prática
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final concursos = snapshot.data!.docs;

                bool idExiste =
                    _concursoSelecionadoId == 'geral' ||
                    concursos.any((doc) => doc.id == _concursoSelecionadoId);

                if (!idExiste) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // 🛡️ Ajuste feito aqui: adicionamos as chaves para sumir a linha azul!
                    if (mounted) {
                      setState(() => _concursoSelecionadoId = 'geral');
                    }
                  });
                }

                List<DropdownMenuItem<String>> dropdownItems = [
                  const DropdownMenuItem(
                    value: 'geral',
                    child: Text(
                      'Visão Geral (Todos os Concursos)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppCores.amareloBizzu,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ];

                dropdownItems.addAll(
                  concursos.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(
                        data['nome']?.toString() ?? 'Concurso sem nome',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                );

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101820),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: idExiste ? _concursoSelecionadoId : 'geral',
                      dropdownColor: const Color(0xFF101820),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppCores.amareloBizzu,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      onChanged: (String? novoValor) {
                        if (novoValor != null) {
                          setState(() {
                            _concursoSelecionadoId = novoValor;
                            _atualizarStreamAssuntos(novoValor);
                          });
                        }
                      },
                      items: dropdownItems,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            if (_concursoSelecionadoId == 'geral')
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.assignment, size: 48, color: Colors.white24),
                    SizedBox(height: 12),
                    Text(
                      'Selecione um concurso específico no menu acima para ver o progresso do edital.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              )
            else
              StreamBuilder<QuerySnapshot>(
                stream: _streamAssuntosDoConcurso,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppCores.amareloBizzu,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101820),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Nenhum assunto cadastrado neste concurso.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  final dadosProgresso = _controller.calcularProgresso(
                    snapshot.data!.docs,
                  );
                  final progressoGeral =
                      dadosProgresso['progressoGeral'] as double;
                  final concluidosGeral =
                      dadosProgresso['concluidosGeral'] as int;
                  final totalAssuntos = dadosProgresso['totalAssuntos'] as int;
                  final totalPorMateria =
                      dadosProgresso['totalPorMateria'] as Map<String, int>;
                  final concluidosPorMateria =
                      dadosProgresso['concluidosPorMateria']
                          as Map<String, int>;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101820),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Edital Concluído',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${(progressoGeral * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: AppCores.amareloBizzu,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressoGeral,
                            minHeight: 12,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppCores.amareloBizzu,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$concluidosGeral de $totalAssuntos assuntos vencidos',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),

                        const Divider(color: Colors.white12, height: 32),

                        const Text(
                          'Por Matéria',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...totalPorMateria.entries.map((entry) {
                          final materia = entry.key;
                          final totalMateria = entry.value;
                          final concluidosMateria =
                              concluidosPorMateria[materia] ?? 0;
                          final porcentagem = totalMateria == 0
                              ? 0.0
                              : (concluidosMateria / totalMateria);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        materia,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${(porcentagem * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: porcentagem,
                                    minHeight: 6,
                                    backgroundColor: Colors.white12,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.greenAccent,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 48),

            const Text(
              'Desempenho em Foco',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildFiltroTempo('7 Dias', 7),
                _buildFiltroTempo('30 Dias', 30),
                _buildFiltroTempo('Tudo', 0),
              ],
            ),
            const SizedBox(height: 24),

            StreamBuilder<QuerySnapshot>(
              stream: _streamDesempenho,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppCores.amareloBizzu,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return _buildEmptyChartState();
                }

                final estatisticas = _controller.processarEstatisticas(
                  snapshot.data!.docs,
                  _concursoSelecionadoId,
                );
                final totalMinutos = estatisticas['totalMinutos'] as int;
                final tempoPorMateria =
                    estatisticas['tempoPorMateria'] as Map<String, int>;
                final tempoPorDia =
                    estatisticas['tempoPorDia'] as Map<int, int>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101820),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppCores.amareloBizzu),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Tempo Total Estudado',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _controller.formatarTempoTotal(totalMinutos),
                            style: const TextStyle(
                              color: AppCores.amareloBizzu,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    if (totalMinutos == 0)
                      _buildEmptyChartState()
                    else ...[
                      const Text(
                        'Foco por Matéria',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(enabled: false),
                            sectionsSpace: 4,
                            centerSpaceRadius: 50,
                            sections: _gerarSecoesPizza(
                              tempoPorMateria,
                              totalMinutos,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: _gerarLegendaPizza(tempoPorMateria),
                      ),

                      const SizedBox(height: 48),

                      const Text(
                        'Produtividade por Dia da Semana',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            maxY: _obterMaxY(tempoPorDia),
                            barTouchData: BarTouchData(enabled: false),
                            alignment: BarChartAlignment.spaceAround,
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const dias = {
                                      1: 'Seg',
                                      2: 'Ter',
                                      3: 'Qua',
                                      4: 'Qui',
                                      5: 'Sex',
                                      6: 'Sáb',
                                      7: 'Dom',
                                    };
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        dias[value.toInt()] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: tempoPorDia.entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    color: AppCores.amareloBizzu,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 48),

            const Text(
              'Sessões Recentes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _streamHistoricoRecente,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppCores.amareloBizzu,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Text(
                    'Erro ao carregar histórico.',
                    style: TextStyle(color: Colors.redAccent),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'Nenhuma sessão registrada.',
                    style: TextStyle(color: Colors.white70),
                  );
                }

                var docsFiltrados = snapshot.data!.docs;
                if (_concursoSelecionadoId != 'geral') {
                  docsFiltrados = docsFiltrados.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['concursoId'] == _concursoSelecionadoId;
                  }).toList();
                }

                if (docsFiltrados.isEmpty) {
                  return const Text(
                    'Nenhuma sessão recente para este edital.',
                    style: TextStyle(color: Colors.white70),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docsFiltrados.length,
                  itemBuilder: (context, index) {
                    final data =
                        docsFiltrados[index].data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101820),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppCores.amareloBizzu,
                          child: Icon(
                            Icons.menu_book,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          data['materia']?.toString() ?? 'Desconhecido',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          data['assunto']?.toString() ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Text(
                          _controller.formatarTempoTotal(data['minutos']),
                          style: const TextStyle(
                            color: AppCores.amareloBizzu,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _gerarSecoesPizza(
    Map<String, int> tempoPorMateria,
    int totalMinutos,
  ) {
    final entradas = tempoPorMateria.entries.where((e) => e.value > 0).toList();
    entradas.sort((a, b) => b.value.compareTo(a.value));

    int index = 0;
    return entradas.map((entry) {
      final cor = _coresGrafico[index % _coresGrafico.length];
      index++;

      final porcentagem = totalMinutos > 0
          ? (entry.value / totalMinutos) * 100
          : 0;

      final mostrarTexto = porcentagem > 6;

      return PieChartSectionData(
        color: cor,
        value: entry.value.toDouble(),
        title: mostrarTexto ? _controller.formatarTempoTotal(entry.value) : '',
        showTitle: mostrarTexto,
        radius: mostrarTexto ? 50 : 40,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }).toList();
  }

  List<Widget> _gerarLegendaPizza(Map<String, int> tempoPorMateria) {
    final entradas = tempoPorMateria.entries.where((e) => e.value > 0).toList();
    entradas.sort((a, b) => b.value.compareTo(a.value));

    int index = 0;
    return entradas.map((entry) {
      final cor = _coresGrafico[index % _coresGrafico.length];
      index++;

      return Padding(
        padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key} (${_controller.formatarTempoTotal(entry.value)})',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildEmptyChartState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF101820),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhum estudo registrado.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
