import 'package:flutter/material.dart';

class BotaoCustomizado extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final Color? corFundo;

  const BotaoCustomizado({
    super.key,
    required this.texto,
    required this.onPressed,
    this.corFundo,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: corFundo ?? const Color(0xFF415A77),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}