import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/i_alerta_servico.dart';
import '../utils/alerta_snackbar.dart';

class EsqueciSenhaController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final IAlertaServico _alertaServico;

  EsqueciSenhaController({IAlertaServico? alertaServico})
    : _alertaServico = alertaServico ?? AlertaSnackBar();

  void _mostrarAlertaVisual(
    BuildContext context,
    String mensagem,
    Color corFundo,
  ) {
    bool isErro = corFundo == Colors.red;
    _alertaServico.exibir(context, mensagem, isErro: isErro);
  }

  Future<void> enviarEmailRecuperacao(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );

        try {
          await FirebaseAnalytics.instance.logEvent(name: 'recuperar_senha');
          debugPrint(' ANALYTICS: Evento recuperar_senha registrado!');
        } catch (e) {
          debugPrint(' ANALYTICS ERRO: $e');
        }

        if (!context.mounted) return;
        _mostrarAlertaVisual(
          context,
          'E-mail enviado! Verifique sua caixa de entrada.',
          Colors.green,
        );

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String mensagem = 'Erro ao enviar e-mail: $e';

        if (e.code == 'user-not-found') {
          mensagem = 'Não há nenhum usuário cadastrado com esse e-mail.';
        } else if (e.code == 'invalid-email') {
          mensagem = 'O formato do e-mail é inválido.';
        }

        if (!context.mounted) return;
        _mostrarAlertaVisual(context, mensagem, Colors.red);
      } catch (e) {
        if (!context.mounted) return;
        _mostrarAlertaVisual(
          context,
          'Erro inesperado. Tente novamente.',
          Colors.red,
        );
      }
    }
  }

  void dispose() {
    emailController.dispose();
  }
}
