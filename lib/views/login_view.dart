import 'package:flutter/material.dart';
import 'package:bizzu_concursos/controllers/login_controller.dart';
import 'package:bizzu_concursos/views/widgets/campo_texto_customizado.dart';
import 'package:bizzu_concursos/views/widgets/botao_customizado.dart';
import 'package:bizzu_concursos/views/widgets/botao_rede_social.dart';
import 'package:bizzu_concursos/theme/appCores.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  bool _isLoading = false;

  Future<void> _executarComLoading(Future<void> Function() acao) async {
    setState(() => _isLoading = true);
    await acao();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
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
                          Center(
                            child: Container(
                              width: 180,
                              height: 180,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF02080C),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color.fromARGB(
                                    255,
                                    251,
                                    239,
                                    12,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),
                          const Text(
                            'Acesse sua conta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),

                          CampoTextoCustomizado(
                            controller: _controller.emailController,
                            hintText: 'E-mail',
                            icone: Icons.email,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, informe seu e-mail.';
                              }
                              return null;
                            },
                          ),

                          CampoTextoCustomizado(
                            controller: _controller.senhaController,
                            hintText: 'Senha',
                            icone: Icons.lock,
                            isSenha: true,
                            paddingBottom: 8,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, informe sua senha.';
                              }
                              return null;
                            },
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(5),
                              ),
                              child: const Text(
                                'Esqueceu a senha?',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          BotaoCustomizado(
                            texto: 'Entrar',
                            onPressed: () {
                              _executarComLoading(() async {
                                await _controller.entrarComEmail(context);
                              });
                            },
                          ),

                          const SizedBox(height: 40),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'ou entre com',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BotaoSocial(
                                icone: Icons.g_mobiledata,
                                corIcone: Colors.red,
                                onPressed: () {
                                  _executarComLoading(() async {
                                    await _controller.entrarComGoogle(context);
                                  });
                                },
                              ),
                              const SizedBox(width: 32),
                              BotaoSocial(
                                icone: Icons.facebook,
                                corIcone: Colors.blue.shade800,
                                onPressed: () {
                                  _executarComLoading(() async {
                                    await _controller.entrarComFacebook(
                                      context,
                                    );
                                  });
                                },
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
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppCores.amareloBizzu,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
