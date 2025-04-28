import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart'; // Adicionada a importação

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _jogadorController = TextEditingController();
  final TextEditingController _assuntoController = TextEditingController();
  File? _novaImagem;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        _nomeController.text = doc.data()?['nome'] ?? '';
        _jogadorController.text = doc.data()?['jogadorFavorito'] ?? '';
        _assuntoController.text = doc.data()?['assuntoInteresse'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _novaImagem = File(pickedFile.path);
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Atualizar imagem se necessário
      String? imageUrl;
      if (_novaImagem != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('usuarios')
            .child('${user.uid}.jpg');
        await ref.putFile(_novaImagem!);
        imageUrl = await ref.getDownloadURL();
        await user.updatePhotoURL(imageUrl);
      }

      // Atualizar nome no Auth
      if (_nomeController.text != user.displayName) {
        await user.updateDisplayName(_nomeController.text);
      }

      // Atualizar dados no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({
        'nome': _nomeController.text,
        'jogadorFavorito': _jogadorController.text,
        'assuntoInteresse': _assuntoController.text,
        if (imageUrl != null) 'fotoPerfil': imageUrl,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      setState(() => _isEditing = false);
      _showSnackBar('Perfil atualizado com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao atualizar perfil: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon:
                Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: () {
              if (_isEditing) {
                _salvarAlteracoes();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Foto de perfil
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: _novaImagem != null
                              ? FileImage(_novaImagem!)
                              : (user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : null)
                                  as ImageProvider<
                                      Object>?, // Corrigido: forçando o tipo para ImageProvider
                          child: user?.photoURL == null && _novaImagem == null
                              ? const Icon(Icons.person,
                                  size: 60, color: Colors.white70)
                              : null,
                        ),
                        if (_isEditing)
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt,
                                color: Colors.black, size: 20),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nome
                  _isEditing
                      ? _buildEditableField(
                          _nomeController, 'Nome', Icons.person)
                      : _buildProfileInfo('Nome',
                          user?.displayName ?? 'Não informado', Icons.person),
                  const SizedBox(height: 16),
                  // E-mail (não editável)
                  _buildProfileInfo(
                      'E-mail', user?.email ?? 'Não informado', Icons.email),
                  const SizedBox(height: 16),
                  // Jogador favorito
                  _isEditing
                      ? _buildEditableField(_jogadorController,
                          'Jogador Favorito', Icons.sports_esports)
                      : _buildProfileInfo(
                          'Jogador Favorito',
                          _jogadorController.text.isNotEmpty
                              ? _jogadorController.text
                              : 'Não informado',
                          Icons.sports_esports),
                  const SizedBox(height: 16),
                  // Assunto de interesse
                  _isEditing
                      ? _buildEditableField(_assuntoController,
                          'Assunto de Interesse', Icons.chat)
                      : _buildProfileInfo(
                          'Assunto de Interesse',
                          _assuntoController.text.isNotEmpty
                              ? _assuntoController.text
                              : 'Não informado',
                          Icons.chat),
                  const SizedBox(height: 32),
                  // Botão de logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('SAIR DA CONTA'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfo(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _jogadorController.dispose();
    _assuntoController.dispose();
    super.dispose();
  }
}
