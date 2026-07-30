import 'package:flutter/material.dart';

class CampoTextoCustomizado extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icone;
  final bool isSenha;
  final String? Function(String?)? validator;
  final double paddingBottom;

  const CampoTextoCustomizado({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icone,
    this.isSenha = false,
    this.validator,
    this.paddingBottom = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: TextFormField(
        controller: controller,
        obscureText: isSenha,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icone, color: Colors.white54),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
