import 'package:flutter/material.dart';
import 'package:bizzu_concursos/controllers/cadastro_controller.dart';
import 'package:bizzu_concursos/theme/appCores.dart';
import 'package:bizzu_concursos/utils/validadores.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final CadastroController _controller = CadastroController();

  bool _isLoading = false;

  bool _ocultarSenha = true;

  static const double espacoGrande = 35.0;
  static const double espacoMedio = 32.0;
  static const double espacoPequeno = 16.0;

  Future<void> _executarComLoading(Future<void> Function() acao) async {
    setState(() {
      _isLoading = true;
    });

    await acao();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputBorder _criarBorda({required Color cor}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: cor),
      borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(height: espacoGrande),
                          const Text(
                            'Crie sua conta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: espacoMedio),
                          TextFormField(
                            controller: _controller.nomeController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Nome Completo',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                              enabledBorder: _criarBorda(cor: Colors.grey),
                              focusedBorder: _criarBorda(
                                cor: const Color(0xFF415A77),
                              ),
                              errorBorder: _criarBorda(cor: Colors.red),
                              focusedErrorBorder: _criarBorda(cor: Colors.red),
                            ),
                            validator: ValidadorNome().validar,
                          ),
                          const SizedBox(height: espacoPequeno),
                          TextFormField(
                            controller: _controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.grey,
                              ),
                              enabledBorder: _criarBorda(cor: Colors.grey),
                              focusedBorder: _criarBorda(
                                cor: const Color(0xFF415A77),
                              ),
                              errorBorder: _criarBorda(cor: Colors.red),
                              focusedErrorBorder: _criarBorda(cor: Colors.red),
                            ),
                            validator: ValidadorEmail().validar,
                          ),
                          const SizedBox(height: espacoPequeno),
                          TextFormField(
                            controller: _controller.senhaController,
                            obscureText: _ocultarSenha,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.grey,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _ocultarSenha = !_ocultarSenha;
                                  });
                                },
                                icon: Icon(
                                  _ocultarSenha
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                              ),
                              enabledBorder: _criarBorda(cor: Colors.grey),
                              focusedBorder: _criarBorda(
                                cor: const Color(0xFF415A77),
                              ),
                              errorBorder: _criarBorda(cor: Colors.red),
                              focusedErrorBorder: _criarBorda(cor: Colors.red),
                            ),
                            validator: ValidadorSenha().validar,
                          ),
                          const SizedBox(height: espacoMedio),
                          ElevatedButton(
                            onPressed: () {
                              _executarComLoading(() async {
                                await _controller.finalizarCadastro(context);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF415A77),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Finalizar Cadastro',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: espacoGrande),
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
                                  'ou cadastre-se com',
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
                          const SizedBox(height: espacoMedio),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _executarComLoading(() async {
                                    await _controller.cadastrarComGoogle(
                                      context,
                                    );
                                  });
                                },
                                icon: const Icon(Icons.g_mobiledata, size: 40),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.all(12),
                                  minimumSize: const Size(60, 40),
                                ),
                              ),
                              const SizedBox(width: espacoGrande),
                              IconButton(
                                onPressed: () {
                                  _executarComLoading(() async {
                                    await _controller.cadastrarComFacebook(
                                      context,
                                    );
                                  });
                                },
                                icon: const Icon(Icons.facebook, size: 40),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue.shade800,
                                  padding: const EdgeInsets.all(12),
                                  minimumSize: const Size(60, 40),
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
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator.adaptive(
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
