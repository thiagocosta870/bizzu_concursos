import 'package:flutter/material.dart';
import 'cadastro_view.dart';
import 'package:bizzu_concursos/views/login_view.dart';
import 'package:bizzu_concursos/theme/appCores.dart';

class BemVindoView extends StatelessWidget {
  const BemVindoView({super.key});

  Widget _criarBotaoAcesso({
    required String texto,
    required Color corFundo,
    required Color corTexto,
    required VoidCallback aoPressionar,
  }) {
    return ElevatedButton(
      onPressed: aoPressionar,
      style: ElevatedButton.styleFrom(
        backgroundColor: corFundo,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: corTexto,
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    double tamanho = MediaQuery.of(context).size.height * 0.3;
    if (tamanho > 250) tamanho = 250;

    return Container(
      width: tamanho,
      height: tamanho,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF02080C),
        shape: BoxShape.circle,
        border: Border.all(color: AppCores.amareloBizzu, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildTextosInformativos(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double tamanhoTitulo = alturaTela < 700 ? 28 : 35;
    double tamanhoSubtitulo = alturaTela < 700 ? 16 : 20;

    return Column(
      children: [
        Text(
          'Bem-vindo ao\nBizzu Concursos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: tamanhoTitulo,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Estratégia e disciplina na palma da sua mão.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: tamanhoSubtitulo,
            color: const Color(0xFFE0E1DD),
          ),
        ),
      ],
    );
  }

  Widget _buildBotoesAcesso(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _criarBotaoAcesso(
          texto: 'Login',
          corFundo: const Color(0xFF415A77),
          corTexto: Colors.white,
          aoPressionar: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginView()),
            );
          },
        ),
        const SizedBox(height: 16),
        _criarBotaoAcesso(
          texto: 'Cadastrar',
          corFundo: const Color(0xFF1B263B),
          corTexto: const Color(0xFFE0E1DD),
          aoPressionar: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CadastroView()),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02080C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLogo(context),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                              ),
                              _buildTextosInformativos(context),
                            ],
                          ),
                        ),
                        _buildBotoesAcesso(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
