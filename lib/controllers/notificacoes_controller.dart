import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificacoesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot>? streamNotificacoes() {
    if (_uid == null) return null;
    return _firestore
        .collection('usuarios')
        .doc(_uid)
        .collection('notificacoes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> marcarComoLida(String id) async {
    if (_uid != null) {
      await _firestore
          .collection('usuarios')
          .doc(_uid)
          .collection('notificacoes')
          .doc(id)
          .update({'lida': true});
    }
  }

  Future<void> apagarNotificacao(String id) async {
    if (_uid != null) {
      await _firestore
          .collection('usuarios')
          .doc(_uid)
          .collection('notificacoes')
          .doc(id)
          .delete();
    }
  }
}
