import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/theme/appCores.dart';
import 'package:bizzu_concursos/controllers/cadastro_concurso_controller.dart';
import 'package:bizzu_concursos/views/assuntos_materia_view.dart';

class DetalhesConcursoView extends StatefulWidget {
  final ConcursoModel concurso;

  const DetalhesConcursoView({super.key, required this.concurso});

  @override
  State<DetalhesConcursoView> createState() => _DetalhesConcursoViewState();
}

class _DetalhesConcursoViewState extends State<DetalhesConcursoView> {
  late List<String> _materiasList;
  final _controller = CadastroConcursoController();

  @override
  void initState() {
    super.initState();
    _atualizarListaDeMaterias();
  }

  void _atualizarListaDeMaterias() {
    String raw = widget.concurso.materias;
    String separador = raw.contains('|') ? '|' : ',';

    _materiasList = raw
        .split(separador)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _adicionarMateriaManual(String novaMateria) async {
    if (novaMateria.trim().isEmpty) return;

    setState(() {
      _materiasList.add(novaMateria.trim());
    });
    await _salvarMateriasNoFirebase();
  }

  Future<void> _confirmarExclusaoMateria(int index) async {
    final nomeMateria = _materiasList[index];

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101820),
        title: const Text(
          'Excluir Matéria?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja realmente apagar a matéria "$nomeMateria"? (Os assuntos vinculados a ela serão perdidos).',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        _materiasList.removeAt(index);
      });

      await _salvarMateriasNoFirebase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$nomeMateria removida!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _salvarMateriasNoFirebase() async {
    widget.concurso.materias = _materiasList.join('|');
    
    final usuarioId = FirebaseAuth.instance.currentUser?.uid;
    if (usuarioId != null && widget.concurso.id != null) {
      await _controller.atualizarConcurso(
        id: widget.concurso.id!,
        nome: widget.concurso.nome,
        cargo: widget.concurso.cargo,
        dataProva: widget.concurso.dataProva,
        materias: widget.concurso.materias,
        usuarioId: usuarioId,
      );
    }
  }

  void _exibirDialogoNovaMateria() {
    final TextEditingController materiaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101820),
          title: const Text(
            'Adicionar Matéria',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: materiaController,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ex: Odontologia Legal',
              hintStyle: const TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppCores.amareloBizzu.withOpacity(0.5),
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppCores.amareloBizzu),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppCores.amareloBizzu,
              ),
              onPressed: () {
                _adicionarMateriaManual(materiaController.text);
                Navigator.pop(context);
              },
              child: const Text(
                'Adicionar',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02080C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppCores.amareloBizzu),
        title: const Text(
          'Informações do concurso',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101820),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_balance,
                          size: 64,
                          color: AppCores.amareloBizzu,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.concurso.nome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.concurso.cargo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppCores.amareloBizzu,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.concurso.dataProva.isNotEmpty
                                ? widget.concurso.dataProva
                                : 'Data a definir',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Matérias',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _exibirDialogoNovaMateria,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: AppCores.amareloBizzu,
                        ),
                        tooltip: 'Adicionar matéria manual',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _materiasList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF101820),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppCores.amareloBizzu.withOpacity(
                              0.2,
                            ),
                            child: const Icon(
                              Icons.book,
                              color: AppCores.amareloBizzu,
                            ),
                          ),
                          title: Text(
                            _materiasList[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                                onPressed: () =>
                                    _confirmarExclusaoMateria(index),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 16,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssuntosMateriaView(
                                  concurso: widget.concurso,
                                  nomeMateria: _materiasList[index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Color(0xFF02080C),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                        color: AppCores.amareloBizzu,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Revisões',
                      style: TextStyle(
                        color: AppCores.amareloBizzu,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppCores.amareloBizzu,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
