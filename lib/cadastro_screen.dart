// CadastroScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_auth.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  File? _imagem;
  bool _isLoading = false;

  List<String> _jogadoresSelecionados = [];
  List<String> _assuntosSelecionados = [];

  final List<String> jogadores = [
    'yuurih',
    'KSCERATO',
    'FalleN',
    'molodoy',
    'YEKINDAR',
    'sidde',
    'Hepa',
  ];

  final List<String> assuntos = [
    'Transações',
    'Jogos Ao vivo',
    'Torneios',
    'Interagir com a comunidade Furia',
    'Dúvidas',
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagem = File(pickedFile.path);
      });
    }
  }

  Future<void> _cadastrar() async {
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _senhaController.text.isEmpty ||
        _cpfController.text.isEmpty ||
        _jogadoresSelecionados.isEmpty ||
        _assuntosSelecionados.isEmpty) {
      _showSnackBar("Por favor, preencha todos os campos.");
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showSnackBar("Digite um e-mail válido.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuthService.cadastrarUsuario(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        cpf: _cpfController.text,
        jogadores: _jogadoresSelecionados,
        assuntos: _assuntosSelecionados,
        imagem: _imagem,
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnackBar("Erro ao cadastrar: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
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
                            _buildImagePicker(),
                            const SizedBox(height: 20),
                            _buildTextField(_nomeController, 'Nome', Icons.person),
                            const SizedBox(height: 20),
                            _buildTextField(_cpfController, 'CPF', Icons.badge),
                            const SizedBox(height: 20),
                            _buildTextField(_emailController, 'E-mail', Icons.email),
                            const SizedBox(height: 20),
                            _buildTextField(_senhaController, 'Senha', Icons.lock, obscureText: true),
                            const SizedBox(height: 20),
                            _buildMultiSelectJogadores(),
                            const SizedBox(height: 20),
                            _buildMultiSelectAssuntos(),
                            const SizedBox(height: 30),
                            _buildCadastroButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
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

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_imagem != null)
          CircleAvatar(
            radius: 50,
            backgroundImage: FileImage(_imagem!),
          )
        else
          const Icon(Icons.account_circle, size: 100, color: Colors.white70),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.camera_alt, color: Colors.black),
          label: const Text('Escolher Foto', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
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

  Widget _buildMultiSelectJogadores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jogadores Favoritos', style: TextStyle(color: Colors.white70)),
        Wrap(
          spacing: 8,
          children: jogadores.map((jogador) {
            final isSelected = _jogadoresSelecionados.contains(jogador);
            return FilterChip(
              label: Text(jogador),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _jogadoresSelecionados.add(jogador);
                  } else {
                    _jogadoresSelecionados.remove(jogador);
                  }
                });
              },
              selectedColor: Colors.white,
              backgroundColor: Colors.grey[800],
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiSelectAssuntos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Assuntos de Interesse', style: TextStyle(color: Colors.white70)),
        Wrap(
          spacing: 8,
          children: assuntos.map((assunto) {
            final isSelected = _assuntosSelecionados.contains(assunto);
            return FilterChip(
              label: Text(assunto),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _assuntosSelecionados.add(assunto);
                  } else {
                    _assuntosSelecionados.remove(assunto);
                  }
                });
              },
              selectedColor: Colors.white,
              backgroundColor: Colors.grey[800],
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
            );
          }).toList(),
        ),
      ],
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
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text(
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
    _cpfController.dispose();
    super.dispose();
  }
}
