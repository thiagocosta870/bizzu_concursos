import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu_concursos/views/bem_vindo_view.dart';
import 'package:bizzu_concursos/views/widgets/card_concurso.dart';
import 'package:bizzu_concursos/views/cadastrar_concurso_view.dart';
import 'package:bizzu_concursos/controllers/home_controller.dart';
import 'package:bizzu_concursos/theme/appCores.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _indiceAtual = 0;
  final usuario = FirebaseAuth.instance.currentUser;
  final HomeController _homeController = HomeController();
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarConcursos();
  }

  Future<void> _carregarConcursos() async {
    if (usuario?.uid != null) {
      setState(() => _carregando = true);
      await _homeController.carregarConcursos(usuario!.uid);
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _deslogar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppCores.fundoPrimario,
        title: const Text(
          'Sair do App?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja desconectar sua conta?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sair',
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
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BemVindoView()),
        (route) => false,
      );
    }
  }

  Widget _buildAbaInicio() {
    String nomeExibicao = usuario?.email?.split('@').first ?? 'Estudante';
    nomeExibicao = nomeExibicao.isNotEmpty
        ? '${nomeExibicao[0].toUpperCase()}${nomeExibicao.substring(1)}'
        : nomeExibicao;

    final concursos = _homeController.meusConcursos;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(
          'Olá, $nomeExibicao!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF415A77),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF415A77), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total de concursos cadastrados',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '${concursos.length}',
                style: const TextStyle(
                  color: AppCores.amareloBizzu,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        const Text(
          'Meus Concursos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        if (_carregando)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: AppCores.amareloBizzu,
              ),
            ),
          )
        else if (concursos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_add,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Você ainda não possui concursos.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Clique em "Cadastrar concurso" para começar!',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...concursos
              .map(
                (concurso) => CardConcurso(
                  nome: concurso.nome,
                  data: concurso.dataProva,
                  cargo: concurso.cargo,
                  onEditar: () async {
                    final atualizou = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CadastrarConcursoView(concursoParaEditar: concurso),
                      ),
                    );
                    if (atualizou == true) _carregarConcursos();
                  },
                  onExcluir: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppCores.fundoPrimario,
                        title: const Text(
                          'Excluir Concurso?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'Esta ação não pode ser desfeita.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.grey),
                            ),
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

                    if (confirmar == true && usuario != null) {
                      setState(() => _carregando = true);
                      await _homeController.excluirConcurso(
                        usuario!.uid,
                        concurso.id!,
                      );
                      _carregarConcursos();
                    }
                  },
                  onAbrir: () {},
                ),
              )
              .toList(),

        const SizedBox(height: 80),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02080C),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_horizontal.png',
          height: 120,
          width: 160,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _deslogar,
            tooltip: 'Sair da conta',
          ),
        ],
      ),
      body: _indiceAtual == 0
          ? _buildAbaInicio()
          : const Center(
              child: Text(
                'Em construção 🚧',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
      floatingActionButton: _indiceAtual == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final atualizou = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastrarConcursoView(),
                  ),
                );

                if (atualizou == true) {
                  _carregarConcursos();
                }
              },
              backgroundColor: AppCores.amareloBizzu,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Cadastrar concurso',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white24, width: 0.5)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: AppCores.amareloBizzu,
          unselectedItemColor: Colors.grey,
          currentIndex: _indiceAtual,
          type: BottomNavigationBarType.fixed,
          onTap: (indice) {
            setState(() {
              _indiceAtual = indice;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Simulados',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
