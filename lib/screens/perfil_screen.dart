import 'package:flutter/material.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  final Map<String, dynamic> _dadosUsuarioFake = const {
    'nome': 'Gabriel “FalleN” Toledo',
    'email': 'fallen@furia.gg',
    'jogadoresFavoritos': ['FalleN', 'KSCERATO', 'yuurih'],
    'assuntosInteresse': ['CS2', 'Treinamentos', 'Estratégias de jogo'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  _dadosUsuarioFake['nome'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _dadosUsuarioFake['email'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Jogadores Favoritos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_dadosUsuarioFake['jogadoresFavoritos'] as List<dynamic>)
                      .map((j) => Chip(
                            label: Text(j),
                            backgroundColor: Colors.grey[800],
                            labelStyle: const TextStyle(color: Colors.white),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Assuntos de Interesse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_dadosUsuarioFake['assuntosInteresse'] as List<dynamic>)
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
        ),
      ),
    );
  }
}
