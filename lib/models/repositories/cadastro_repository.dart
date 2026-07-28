import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../usuario_model.dart';

class CadastroRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> cadastrarUsuarioComEmail(UsuarioModel usuario) async {
    
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: usuario.email,
      password: usuario.senha,
    );

    String uid = userCredential.user!.uid;

    
    await _firestore.collection('usuarios').doc(uid).set({
      'uid': uid,
      'nome': usuario.nome,
      'email': usuario.email,
      'criadoEm': Timestamp.now(),
    });

    return uid;
  }
}