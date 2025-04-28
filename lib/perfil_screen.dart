import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'perfil_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? _dadosUsuario;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    User? usuarioAtual = PerfilFunctions.getUsuarioAtual();
    if (usuarioAtual != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioAtual.uid)
          .get();
      setState(() {
        _dadosUsuario = snapshot.data() as Map<String, dynamic>?;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await PerfilFunctions.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dadosUsuario == null
              ? const Center(
                  child: Text(
                    'Usuário não encontrado.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _dadosUsuario!['fotoPerfil'] != null
                            ? NetworkImage(_dadosUsuario!['fotoPerfil'])
                            : const AssetImage('assets/perfis/default.png') as ImageProvider,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _dadosUsuario!['nome'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _dadosUsuario!['email'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      if (_dadosUsuario!['jogadoresFavoritos'] != null)
                        Wrap(
                          spacing: 6,
                          children: (_dadosUsuario!['jogadoresFavoritos'] as List<dynamic>)
                              .map((j) => Chip(
                                    label: Text(j),
                                    backgroundColor: Colors.grey[800],
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 10),
                      if (_dadosUsuario!['assuntosInteresse'] != null)
                        Wrap(
                          spacing: 6,
                          children: (_dadosUsuario!['assuntosInteresse'] as List<dynamic>)
                              .map((a) => Chip(
                                    label: Text(a),
                                    backgroundColor: Colors.grey[700],
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
    );
  }
}
