import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/usuario_model.dart';
import '../models/repositories/cadastro_repository.dart';
import 'package:bizzu_concursos/views/login_view.dart';
import '../utils/i_alerta_servico.dart';
import '../utils/alerta_snackbar.dart';
import '../utils/alerta_dialog.dart'; 

class CadastroController {
  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final CadastroRepository _repository;


  final IAlertaServico _alertaServico;

  CadastroController({
    CadastroRepository? repository,
    IAlertaServico? alertaServico,
  })  : _repository = repository ?? CadastroRepository(),
        _alertaServico = alertaServico ?? AlertaSnackBar(); //Se quiser posso trocar para (AlertaDialog, que vai funcionar perfeitamente, respeitando o Liskov Substitution) 

  void _mostrarAlertaVisual(BuildContext context, String mensagem, Color corFundo) {
    bool isErro = corFundo == Colors.red;
    _alertaServico.exibir(context, mensagem, isErro: isErro);
  }

  Future<void> finalizarCadastro(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        final novoUsuario = UsuarioModel(
          nome: nomeController.text.trim(),
          email: emailController.text.trim(),
          senha: senhaController.text.trim(),
        );

        String uid = await _repository.cadastrarUsuarioComEmail(novoUsuario);

        debugPrint('SUCESSO COMPLETO!');
        debugPrint('Usuário criado e salvo no Firestore com UID: $uid');

        if (!context.mounted) return;

        nomeController.clear();
        emailController.clear();
        senhaController.clear();

        _mostrarAlertaVisual(context, 'Cadastro realizado com sucesso!', Colors.green);

        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      } on FirebaseAuthException catch (e) {
        String mensagem = 'Erro ao realizar cadastro: $e';

        if (e.code == 'weak-password') {
          mensagem = 'A senha fornecida é muito fraca. Use pelo menos 6 caracteres.';
        } else if (e.code == 'email-already-in-use') {
          mensagem = 'Já existe uma conta cadastrada com este e-mail.';
        } else if (e.code == 'invalid-email') {
          mensagem = 'O formato do e-mail é inválido.';
        }

        debugPrint(mensagem);
        _mostrarAlertaVisual(context, mensagem, Colors.red);
        
      } catch (e) {
        debugPrint('Erro desconhecido ao salvar usuário: $e');
        _mostrarAlertaVisual(
          context,
          'Ocorreu um erro inesperado. Verifique sua conexão e tente novamente.',
          Colors.red,
        );
      }
    } else {
      debugPrint('Bloqueado: O usuário preencheu algo errado.');
    }
  }

  Future<void> cadastrarComGoogle(BuildContext context) async {
    try {
      await GoogleSignIn.instance.initialize();

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        debugPrint('Login com Google cancelado pelo usuário.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
      ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCredential.user?.uid ?? '';

      await _repository.salvarUsuarioNoFirestore(
        uid,
        userCredential.user?.displayName ?? 'Usuário',
        userCredential.user?.email ?? '',
      );

      debugPrint('--- SUCESSO COMPLETO COM GOOGLE! ---');
      debugPrint('UID: $uid | Nome: ${userCredential.user?.displayName}');

      _mostrarAlertaVisual(context, 'Conta Google conectada com sucesso!', Colors.green);
      
    } catch (e) {
      debugPrint('Erro ao cadastrar com o Google: $e');
      _mostrarAlertaVisual(context, 'Erro ao conectar Google: $e', Colors.red);
    }
  }

  Future<void> cadastrarComFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        debugPrint('Login com Facebook cancelado ou falhou. Status: ${result.status}');
        return;
      }

      final AccessToken accessToken = result.accessToken!;

      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCredential.user?.uid ?? '';

      await _repository.salvarUsuarioNoFirestore(
        uid,
        userCredential.user?.displayName ?? 'Usuário',
        userCredential.user?.email ?? '',
      );

      debugPrint('--- SUCESSO COMPLETO COM FACEBOOK! ---');
      debugPrint('UID: $uid | Nome: ${userCredential.user?.displayName}');

      _mostrarAlertaVisual(context, 'Conta Facebook conectada com sucesso!', Colors.green);
      
    } catch (e) {
      debugPrint('Erro ao cadastrar com o Facebook: $e');
      _mostrarAlertaVisual(context, 'Erro ao conectar Facebook: $e', Colors.red);
    }
  }

  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
  }
}