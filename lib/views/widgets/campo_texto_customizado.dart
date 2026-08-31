import 'package:flutter/material.dart';
import 'package:bizzu_concursos/theme/appCores.dart';

class CampoTextoCustomizado extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icone;
  final bool isSenha;
  final double paddingBottom;
  final String? Function(String?)? validator;

  final bool readOnly;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;

  final Widget? suffixIcon;

  const CampoTextoCustomizado({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icone,
    this.isSenha = false,
    this.paddingBottom = 20.0,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,

    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: TextFormField(
        controller: controller,
        obscureText: isSenha,
        readOnly: readOnly,
        onTap: onTap, 
        textCapitalization: textCapitalization,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icone, color: const Color(0xFF415A77)),

          suffixIcon: suffixIcon,

          filled: true,
          fillColor: const Color(0xFF101820),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppCores.amareloBizzu,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
