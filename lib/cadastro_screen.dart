import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _jogadorController = TextEditingController();
  final TextEditingController _assuntoController = TextEditingController();
  File? _imagem;
  bool _isLoading = false;

  // Função para escolher a imagem (pode usar o pacote image_picker)
  Future<void> _pickImage() async {
    // Aqui você pode usar o `image_picker` para pegar a imagem da galeria ou câmera
    // Exemplo: _imagem = await ImagePicker().getImage(source: ImageSource.gallery);
  }

  // Função para cadastrar o usuário
  Future<void> _cadastrar() async {
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _senhaController.text.isEmpty ||
        _jogadorController.text.isEmpty ||
        _assuntoController.text.isEmpty) {
      _showSnackBar("Por favor, preencha todos os campos.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Erro ao cadastrar.");
    } catch (e) {
      _showSnackBar("Erro inesperado.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para mostrar mensagens de erro
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Logo
              Image.asset(
                'assets/furia_logo.png',
                height: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 40),
              // Título
              Text(
                'CADASTRAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              // Campos de texto para cadastro
              _buildTextField(_nomeController, 'Nome'),
              const SizedBox(height: 20),
              _buildTextField(_emailController, 'E-mail'),
              const SizedBox(height: 20),
              _buildTextField(_senhaController, 'Senha', obscureText: true),
              const SizedBox(height: 20),
              _buildTextField(_jogadorController, 'Jogador Favorito'),
              const SizedBox(height: 20),
              _buildTextField(_assuntoController, 'Assunto de Interesse'),
              const SizedBox(height: 30),
              // Botão de escolha de imagem de perfil
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image, color: Colors.black),
                label: Text('Escolher Imagem'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
              const SizedBox(height: 20),
              // Botão de cadastro
              SizedBox(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Campo de texto reutilizável
  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.edit, color: Colors.white70),
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
