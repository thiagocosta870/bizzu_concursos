import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    "Notificação recebida em background: ${message.notification?.title}",
  );
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> inicializar() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🟢 Usuário deu permissão para notificações!');

      String? token = await _fcm.getToken();

      if (token != null) {
        await _salvarTokenNoBanco(token);
      }

      _fcm.onTokenRefresh.listen((novoToken) {
        _salvarTokenNoBanco(novoToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          '🔔 Mensagem recebida com o app ABERTO: ${message.notification?.title}',
        );
      });

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } else {
      debugPrint('🔴 Usuário negou as notificações.');
    }
  }

  Future<void> _salvarTokenNoBanco(String token) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _db.collection('usuarios').doc(userId).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        debugPrint('✅ Token salvo no Firestore com sucesso!');
      }
    } catch (e) {
      debugPrint('Erro ao salvar token no banco: $e');
    }
  }
}
