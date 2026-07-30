import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/bem_vindo_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BizzuApp());
}

class BizzuApp extends StatelessWidget {
  const BizzuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bizzu Concursos',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF415A77),
          primary: const Color(0xFF415A77),
          secondary: const Color(0xFF778DA9),
        ),
      ),
      home: const BemVindoView(),
    );
  }
}
