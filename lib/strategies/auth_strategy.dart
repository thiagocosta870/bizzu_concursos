import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

abstract class AuthStrategy {
  String get nomeProvedor; 
  Future<UserCredential> autenticar();
}

class AuthGoogleStrategy implements AuthStrategy {
  @override
  String get nomeProvedor => 'Google'; 

  @override
  Future<UserCredential> autenticar() async {
    await GoogleSignIn.instance.initialize();
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
    
    if (googleUser == null) throw Exception('Login com Google cancelado.');

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email']);

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: clientAuth.accessToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}

class AuthFacebookStrategy implements AuthStrategy {
  @override
  String get nomeProvedor => 'Facebook'; 

  @override
  Future<UserCredential> autenticar() async {
    final LoginResult result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
    
    if (result.status != LoginStatus.success) throw Exception('Login com Facebook cancelado.');

    final AccessToken accessToken = result.accessToken!;
    final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}