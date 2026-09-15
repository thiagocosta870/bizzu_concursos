import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu_concursos/models/repositories/historico_repository.dart';

class DashboardController {
  final HistoricoRepository _repository = HistoricoRepository();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot>? streamHistoricoRecente() {
    if (_uid == null) return null;
    return _repository.streamHistoricoRecente(_uid!);
  }

  Stream<QuerySnapshot>? streamDesempenho(int dias) {
    if (_uid == null) return null;
    DateTime inicioDoDia;
    if (dias == 0) {
      inicioDoDia = DateTime(2000, 1, 1);
    } else {
      final dataInicio = DateTime.now().subtract(Duration(days: dias));
      inicioDoDia = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
    }
    return _repository.streamSessoesPorPeriodo(_uid!, inicioDoDia);
  }

  Stream<QuerySnapshot>? streamMeusConcursos() {
    if (_uid == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_uid)
        .collection('concursos')
        .snapshots();
  }

  Stream<QuerySnapshot>? streamAssuntosDoConcurso(String concursoId) {
    if (_uid == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_uid)
        .collection('concursos')
        .doc(concursoId)
        .collection('assuntos')
        .snapshots();
  }

  Map<String, dynamic> calcularProgresso(
    List<QueryDocumentSnapshot> assuntosDocs,
  ) {
    int totalAssuntos = assuntosDocs.length;
    int concluidosGeral = 0;

    Map<String, int> totalPorMateria = {};
    Map<String, int> concluidosPorMateria = {};

    for (var doc in assuntosDocs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final isConcluido = data['concluido'] == true;
      final materia = data['materia']?.toString() ?? 'Geral';

      totalPorMateria[materia] = (totalPorMateria[materia] ?? 0) + 1;

      if (isConcluido) {
        concluidosGeral++;
        concluidosPorMateria[materia] =
            (concluidosPorMateria[materia] ?? 0) + 1;
      }
    }

    return {
      'totalAssuntos': totalAssuntos,
      'concluidosGeral': concluidosGeral,
      'progressoGeral': totalAssuntos == 0
          ? 0.0
          : (concluidosGeral / totalAssuntos),
      'totalPorMateria': totalPorMateria,
      'concluidosPorMateria': concluidosPorMateria,
    };
  }

  int _parseIntSeguro(dynamic valor) {
    if (valor == null) return 0;
    if (valor is int) return valor;
    if (valor is double) return valor.toInt();
    if (valor is String) return int.tryParse(valor) ?? 0;
    return 0;
  }

  Map<String, dynamic> processarEstatisticas(
    List<QueryDocumentSnapshot> docs,
    String concursoIdFiltro,
  ) {
    int totalMinutos = 0;
    Map<String, int> tempoPorMateria = {};
    Map<int, int> tempoPorDia = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};

      if (concursoIdFiltro != 'geral' &&
          data['concursoId'] != concursoIdFiltro) {
        continue;
      }

      final minutos = _parseIntSeguro(data['minutos']);
      final timestamp = _parseIntSeguro(data['timestampLocal']);
      final materia = data['materia']?.toString() ?? 'Sem Matéria';

      totalMinutos += minutos;

      if (minutos > 0) {
        tempoPorMateria[materia] = (tempoPorMateria[materia] ?? 0) + minutos;
      }

      if (timestamp > 0) {
        final dataEstudo = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final diaSemana = dataEstudo.weekday;
        tempoPorDia[diaSemana] = (tempoPorDia[diaSemana] ?? 0) + minutos;
      }
    }

    return {
      'totalMinutos': totalMinutos,
      'tempoPorMateria': tempoPorMateria,
      'tempoPorDia': tempoPorDia,
    };
  }

  String formatarTempoTotal(dynamic minutosBrutos) {
    final minutosTotais = _parseIntSeguro(minutosBrutos);
    if (minutosTotais < 60) return '${minutosTotais}m';
    final horas = minutosTotais ~/ 60;
    final minutos = minutosTotais % 60;
    if (minutos == 0) return '${horas}h';
    return '${horas}h ${minutos}m';
  }
}
