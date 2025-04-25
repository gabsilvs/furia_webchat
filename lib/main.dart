import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'cadastro_screen.dart';
//import 'package:your_project/home_screen.dart';
import 'env_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Env.apiKey,
      appId: Env.appId,
      messagingSenderId: Env.messagingSenderId,
      projectId: Env.projectId,
      authDomain: Env.authDomain,
      storageBucket: Env.storageBucket,
    ),
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FURIA Social App',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),  // Rota inicial (Login)
        '/cadastro': (context) => const CadastroScreen(),  // Rota para cadastro
        //'/home': (context) => const HomeScreen(),  // Rota para a tela principal (após login)
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
