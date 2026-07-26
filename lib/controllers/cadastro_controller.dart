import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Importamos o Auth do Firebase
import '../models/usuario_model.dart';

class CadastroController {
  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  // Tornamos a função 'async' porque a conexão com a nuvem leva alguns milissegundos
  void finalizarCadastro(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        // 2. Criamos o usuário de verdade no Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: senhaController.text.trim(),
        );

        // Pegamos o ID único gerado pelo Google para este usuário
        String uid = userCredential.user?.uid ?? '';

        final novoUsuario = UsuarioModel(
          nome: nomeController.text.trim(),
          email: emailController.text.trim(),
          senha: senhaController.text.trim(),
        );

        debugPrint('--- SUCESSO! USUÁRIO CADASTRADO NO FIREBASE ---');
        debugPrint('UID do Firebase: $uid');
        debugPrint('Nome: ${novoUsuario.nome}');
        debugPrint('E-mail: ${novoUsuario.email}');

        // Aqui depois podemos colocar um comando para avançar de tela!

      } on FirebaseAuthException catch (e) {
        // 3. Tratamento caso dê algum erro (ex: e-mail já cadastrado, senha fraca)
        debugPrint('Erro ao cadastrar no Firebase: ${e.message}');
      }
      
    } else {
      debugPrint('Bloqueado: O usuário preencheu algo errado.');
    }
  }

  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
  }
}