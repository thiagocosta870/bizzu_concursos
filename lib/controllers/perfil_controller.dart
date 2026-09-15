import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PerfilController {
  User? get _usuario => FirebaseAuth.instance.currentUser;

  String get email => _usuario?.email ?? 'Email não encontrado';

  String get nomeExibicao {
    final nomeOriginal = _usuario?.displayName;
    String nomeCalculado = nomeOriginal ?? email.split('@').first;

    if (nomeCalculado.isNotEmpty) {
      nomeCalculado =
          '${nomeCalculado[0].toUpperCase()}${nomeCalculado.substring(1)}';
    }
    return nomeCalculado;
  }

  String get inicialAvatar {
    final nome = nomeExibicao;
    return nome.isNotEmpty ? nome[0].toUpperCase() : 'U';
  }

  Future<bool> atualizarNome(String novoNome) async {
    if (_usuario == null || novoNome.trim().isEmpty) return false;

    try {
      await _usuario!.updateDisplayName(novoNome.trim());
      await _usuario!.reload();
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar nome: $e');
      return false;
    }
  }

  Future<String?> excluirConta() async {
    if (_usuario == null) return 'Usuário não encontrado.';

    try {
      final uid = _usuario!.uid;

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();

      await _usuario!.delete();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Por segurança, você precisa sair do aplicativo, fazer login novamente e tentar excluir a conta em seguida.';
      }
      return 'Erro ao excluir conta: ${e.message}';
    } catch (e) {
      return 'Ocorreu um erro inesperado ao tentar excluir a conta.';
    }
  }
}
