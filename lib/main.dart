import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:bizzu_concursos/theme/appCores.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/bem_vindo_view.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const BizzuApp());
}

class BizzuApp extends StatelessWidget {
  const BizzuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bizzu Concursos',
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      theme: ThemeData(
        scaffoldBackgroundColor: AppCores.fundoPrimario,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF415A77),
          primary: const Color(0xFF415A77),
          secondary: const Color(0xFF778DA9),
        ),
      ),
      home: const RoteadorTela(),
    );
  }
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF02080C),
            body: Center(
              child: CircularProgressIndicator(color: AppCores.amareloBizzu),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeView();
        }

        return const BemVindoView();
      },
    );
  }
}
