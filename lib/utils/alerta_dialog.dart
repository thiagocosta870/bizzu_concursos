import 'package:flutter/material.dart';
import 'i_alerta_servico.dart';

class AlertaDialog implements IAlertaServico {
  @override
  void exibir(BuildContext context, String mensagem, {required bool isErro}) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(isErro ? 'Erro' : 'Sucesso'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}