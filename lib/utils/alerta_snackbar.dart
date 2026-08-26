import 'package:flutter/material.dart';
import 'i_alerta_servico.dart';

class AlertaSnackBar implements IAlertaServico {
  @override
  void exibir(BuildContext context, String mensagem, {required bool isErro}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isErro ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}