import 'package:flutter/material.dart';

class BotaoSocial extends StatelessWidget {
  final IconData icone;
  final Color corIcone;
  final VoidCallback onPressed;

  const BotaoSocial({
    super.key,
    required this.icone,
    required this.corIcone,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icone, size: 40),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: corIcone,
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(60, 40),
      ),
    );
  }
}