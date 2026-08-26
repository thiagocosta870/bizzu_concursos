import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../views/home_view.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  void _mostrarMensagem(BuildContext context, String mensagem, Color cor) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
  }

  void _navegarParaHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeView()),
    );
  }

  Future<void> entrarComEmail(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: senhaController.text.trim(),
        );

        if (!context.mounted) return;
        _mostrarMensagem(
          context,
          'Bem-vindo(a) de volta ao Bizzu Concursos!',
          Colors.green,
        );

        emailController.clear();
        senhaController.clear();

        if (!context.mounted) return;

        _navegarParaHome(context);
      } on FirebaseAuthException catch (e) {
        String mensagem = 'Erro ao fazer login: $e';

        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          mensagem = 'E-mail ou senha incorretos. Tente novamente.';
        }

        if (!context.mounted) return;

        _mostrarMensagem(context, mensagem, Colors.red);
      }
    }
  }

  Future<void> entrarComGoogle(BuildContext context) async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) {
        debugPrint('Login com Google cancelado pelo usuário.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
      ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login com Google realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      if (!context.mounted) return;

      _mostrarMensagem(
        context,
        'Login com Google realizado com sucesso!',
        Colors.green,
      );

      _navegarParaHome(context);
    } catch (e) {
      if (!context.mounted) return;

      _mostrarMensagem(context, 'Erro ao conectar Google: $e', Colors.red);
    }
  }

  Future<void> entrarComFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) return;

      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!context.mounted) return;

      _mostrarMensagem(
        context,
        'Login com Facebook realizado com sucesso!',
        Colors.green,
      );

      if (!context.mounted) return;

      _navegarParaHome(context);
    } catch (e) {
      if (!context.mounted) return;

      _mostrarMensagem(context, 'Erro ao conectar Facebook: $e', Colors.red);
    }
  }
}
