import 'package:flutter/material.dart';
import 'package:bizzu_concursos/controllers/cadastro_controller.dart'; // Ajuste se o caminho estiver diferente

class CadastroView extends StatelessWidget {
  final CadastroController _controller = CadastroController();

  CadastroView({super.key});

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

                // 1. AQUI ESTÁ O NOSSO FORM RECEBENDO A CHAVE-MESTRA:
                child: Form(
                  key: _controller.formKey,

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 140,
                          height: 140,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF02080C),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromARGB(255, 251, 239, 12),
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
                      const SizedBox(height: 48),
                      const Text(
                        'Crie sua conta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 32),

                      // CAMPO DE NOME COM VALIDAÇÃO
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
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: const Color(0xFF415A77),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            // Borda vermelha de erro
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe seu nome completo.';
                          }
                          return null; // Null significa que passou no teste!
                        },
                      ),
                      const SizedBox(height: 16),

                      // CAMPO DE E-MAIL COM VALIDAÇÃO
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
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: const Color(0xFF415A77),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe seu e-mail.';
                          } else if (!value.contains('@') ||
                              !value.contains('.')) {
                            return 'Informe um e-mail válido (ex: seu@email.com).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CAMPO DE SENHA COM VALIDAÇÃO
                      TextFormField(
                        controller: _controller.senhaController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.grey,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: const Color(0xFF415A77),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, crie uma senha.';
                          } else if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () {
                          _controller.finalizarCadastro(context);
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
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Colors.grey, thickness: 0.5),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ou cadastre-se com',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Colors.grey, thickness: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata, size: 40),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.all(12),
                              minimumSize: const Size(60, 40),
                            ),
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            onPressed: () {},
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
    );
  }
}
