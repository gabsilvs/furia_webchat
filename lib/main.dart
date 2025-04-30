// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:furia_webchat/perfil_screen.dart';
import 'login_screen.dart';
import 'cadastro_screen.dart';
import 'home_screen.dart';
import 'env.dart';
import 'firebase_options.dart';
import 'firebase_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseApiService.configure();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FURIA Social App',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/home': (context) => HomeScreen(),
        '/perfil': (context) => PerfilScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}