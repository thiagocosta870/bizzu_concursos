import 'package:flutter/material.dart';
import '../controllers/esqueci_senha_controller.dart';
import 'package:bizzu_concursos/views/widgets/campo_texto_customizado.dart';
import 'package:bizzu_concursos/views/widgets/botao_customizado.dart';

class EsqueciSenhaView extends StatefulWidget {
  const EsqueciSenhaView({super.key});

  @override
  State<EsqueciSenhaView> createState() => _EsqueciSenhaViewState();
}

class _EsqueciSenhaViewState extends State<EsqueciSenhaView> {
  final _controller = EsqueciSenhaController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFF02080C),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color.fromARGB(255, 251, 239, 12),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Form(
                  key: _controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 35),

                      const Text(
                        'Esqueceu sua senha?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Digite seu e-mail cadastrado abaixo para receber um link de redefinição de senha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 35),

                      CampoTextoCustomizado(
                        controller: _controller.emailController,
                        hintText: 'E-mail',
                        icone: Icons.email,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe seu e-mail.';
                          }
                          if (!value.contains('@')) {
                            return 'Insira um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      BotaoCustomizado(
                        texto: 'Enviar Link',
                        onPressed: () =>
                            _controller.enviarEmailRecuperacao(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
