import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu_concursos/models/concurso_model.dart';
import 'package:bizzu_concursos/theme/appCores.dart';

class AssuntosMateriaView extends StatefulWidget {
  final ConcursoModel concurso;
  final String nomeMateria;

  const AssuntosMateriaView({
    super.key,
    required this.concurso,
    required this.nomeMateria,
  });

  @override
  State<AssuntosMateriaView> createState() => _AssuntosMateriaViewState();
}

class _AssuntosMateriaViewState extends State<AssuntosMateriaView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _assuntosRef {
    return _firestore
        .collection('usuarios')
        .doc(_uid)
        .collection('concursos')
        .doc(widget.concurso.id)
        .collection('assuntos');
  }

  void _exibirDialogoNovoAssunto() {
    final TextEditingController assuntoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101820),
          title: const Text(
            'Adicionar Assunto',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: assuntoController,
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Digite o tema para estudar...',
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
              onPressed: () async {
                if (assuntoController.text.trim().isNotEmpty) {
                  await _assuntosRef.add({
                    'materia': widget.nomeMateria,
                    'nome': assuntoController.text.trim(),
                    'concluido': false,
                    'criadoEm': DateTime.now().millisecondsSinceEpoch,
                  });
                }
                if (mounted) Navigator.pop(context);
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

  Future<void> _confirmarExclusaoAssunto(
    DocumentReference docRef,
    String nomeAssunto,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101820),
        title: const Text(
          'Excluir Assunto?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja realmente apagar o assunto "$nomeAssunto"?',
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
      await docRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02080C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101820),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppCores.amareloBizzu),
        title: Text(
          widget.nomeMateria,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _assuntosRef
            .where('materia', isEqualTo: widget.nomeMateria)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar assuntos.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppCores.amareloBizzu),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.library_books,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum assunto cadastrado',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _exibirDialogoNovoAssunto,
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Adicionar Assunto',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppCores.amareloBizzu,
                    ),
                  ),
                ],
              ),
            );
          }

          final assuntos = snapshot.data!.docs;
          assuntos.sort((a, b) {
            final dataA = (a.data() as Map<String, dynamic>)['criadoEm'] ?? 0;
            final dataB = (b.data() as Map<String, dynamic>)['criadoEm'] ?? 0;
            return dataA.compareTo(dataB);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assuntos.length,
            itemBuilder: (context, index) {
              final doc = assuntos[index];
              final data = doc.data() as Map<String, dynamic>;
              final isConcluido = data['concluido'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF101820),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isConcluido
                        ? AppCores.amareloBizzu.withOpacity(0.3)
                        : Colors.white12,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    data['nome'],
                    style: TextStyle(
                      color: isConcluido ? Colors.grey : Colors.white,
                      decoration: isConcluido
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () => _confirmarExclusaoAssunto(
                          doc.reference,
                          data['nome'],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isConcluido
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isConcluido
                              ? AppCores.amareloBizzu
                              : Colors.white24,
                        ),
                        onPressed: () {
                          doc.reference.update({'concluido': !isConcluido});
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exibirDialogoNovoAssunto,
        backgroundColor: AppCores.amareloBizzu,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
