import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../usuario_model.dart';
import 'IAuthenticationRepository.dart';
import 'IUserPersistenceRepository.dart';

class CadastroRepository
    implements IAuthenticationRepository, IUserPersistenceRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
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

  @override
  Future<void> salvarUsuarioNoFirestore(
    String uid,
    String nome,
    String email,
  ) async {
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      'uid': uid,
      'nome': nome,
      'email': email,
      'criadoEm': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
