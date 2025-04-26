import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'firebase_auth.dart'; // Seu arquivo de funções FirebaseAuthService

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _jogadorController = TextEditingController();
  final TextEditingController _assuntoController = TextEditingController();
  File? _imagem;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    // Aqui você pode implementar o image_picker
  }

  Future<void> _cadastrar() async {
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _senhaController.text.isEmpty ||
        _jogadorController.text.isEmpty ||
        _assuntoController.text.isEmpty) {
      _showSnackBar("Por favor, preencha todos os campos.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuthService.cadastrarUsuario(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        jogador: _jogadorController.text,
        assunto: _assuntoController.text,
        imagem: _imagem,
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnackBar("Erro ao cadastrar.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red[400],
    ));
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
                                _nomeController, 'Nome', Icons.person),
                            const SizedBox(height: 20),
                            _buildTextField(
                                _emailController, 'E-mail', Icons.email),
                            const SizedBox(height: 20),
                            _buildTextField(
                                _senhaController, 'Senha', Icons.lock,
                                obscureText: true),
                            const SizedBox(height: 20),
                            _buildTextField(_jogadorController,
                                'Jogador Favorito', Icons.sports_esports),
                            const SizedBox(height: 20),
                            _buildTextField(_assuntoController,
                                'Assunto de Interesse', Icons.chat),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.image, color: Colors.black),
                              label: Text('Escolher Imagem'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildCadastroButton(),
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
      style: TextStyle(color: Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.black,
      ),
    );
  }

  Widget _buildCadastroButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _cadastrar,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.black)
            : Text(
                'CADASTRAR',
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
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _jogadorController.dispose();
    _assuntoController.dispose();
    super.dispose();
  }
}
