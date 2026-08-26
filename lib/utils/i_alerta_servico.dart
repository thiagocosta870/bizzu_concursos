import 'package:flutter/material.dart';

abstract class IAlertaServico {
  void exibir(BuildContext context, String mensagem, {required bool isErro});
}