import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false;
  bool _isAnonymousLoading = false;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      _showSnackBar("Preencha e-mail e senha.");
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showSnackBar("Digite um e-mail válido.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Erro ao fazer login.");
    } catch (e) {
      _showSnackBar("Erro inesperado.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginAnonimo() async {
    setState(() => _isAnonymousLoading = true);

    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Erro ao entrar como visitante.");
    } catch (e) {
      _showSnackBar("Erro inesperado.");
    } finally {
      setState(() => _isAnonymousLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Faça parte da comunidade FURIA!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  // Parte esquerda - Formulário
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/logo.png', width: 100),
                            const SizedBox(height: 40),
                            _buildTextField(
                                _emailController, 'E-mail', Icons.email),
                            const SizedBox(height: 20),
                            _buildTextField(
                                _senhaController, 'Senha', Icons.lock,
                                obscureText: true),
                            const SizedBox(height: 30),
                            _buildLoginButton(),
                            const SizedBox(height: 10),
                            _buildAnonymousLoginButton(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Parte direita - Carrossel
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 1.0,
                          height: double.infinity,
                        ),
                        items: [
                          'assets/carrosel1.png',
                          'assets/carrosel2.png',
                          'assets/carrosel3.png',
                        ].map((imagePath) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[900],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
                'ENTRAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildAnonymousLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _isAnonymousLoading ? null : _loginAnonimo,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isAnonymousLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'ENTRAR COMO VISITANTE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
