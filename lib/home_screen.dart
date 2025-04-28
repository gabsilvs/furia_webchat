import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Map<String, dynamic>> noticias = [
    {
      'id': 'noticia1',
      'titulo': 'FURIA vence a Team Liquid e avança na ESL Pro League',
      'descricao': 'Em uma atuação dominante, a FURIA superou a Team Liquid e garantiu vaga na próxima fase.',
      'imagem': 'assets/foto1.png',
    },
    {
      'id': 'noticia2',
      'titulo': 'FURIA anuncia chegada de novo coach para CS2',
      'descricao': 'A organização anunciou hoje a contratação de um novo treinador focado no cenário de Counter-Strike 2.',
      'imagem': 'assets/logo.png',
    },
    {
      'id': 'noticia3',
      'titulo': 'FalleN fala sobre evolução da FURIA após últimos torneios',
      'descricao': 'Em entrevista, FalleN destacou o crescimento e adaptação da equipe nos últimos meses.',
      'imagem': 'assets/foto3.png',
    },
  ];

  final List<String> chats = [
    'Discussão de Partidas',
    'Novidades e Transferências',
    'Dúvidas e Suporte',
    'Chat Furia Bot!',
  ];

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/perfil'),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 7,
            child: _buildNewsSection(),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              child: _buildChatsSection(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: noticias.length,
      itemBuilder: (context, index) {
        final noticia = noticias[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(noticia['imagem'], fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Text(
                  noticia['titulo'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  noticia['descricao'],
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                _buildCommentsSection(noticia['id']),
                const SizedBox(height: 8),
                _buildCommentField(noticia['id']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsSection(String noticiaId) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirestoreService.comentariosStream(noticiaId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox.shrink(); // <- Sem loading
      }

      final comentarios = snapshot.data!.docs;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: comentarios.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['autor'] ?? 'Anônimo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data['texto'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
}


  Widget _buildCommentField(String noticiaId) {
    final controller = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Escreva um comentário...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: () {
            if (controller.text.isNotEmpty) {
              FirestoreService.adicionarComentario(
                idNoticia: noticiaId,
                autor: FirebaseAuth.instance.currentUser?.displayName ?? 'Usuário',
                texto: controller.text,
              );
              controller.clear();
            }
          },
        ),
      ],
    );
  }

  Widget _buildChatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Chats da Comunidade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        for (final chatName in chats) _buildChatButton(context, chatName),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context, String chatName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () => _openChat(context, chatName),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(chatName),
      ),
    );
  }

  void _openChat(BuildContext context, String chatName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      chatName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white54, height: 1),
              Expanded(
                child: _buildChatMessages(chatName),
              ),
              _buildChatInputField(chatName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatMessages(String chatName) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirestoreService.mensagensChatStream(chatName),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox.shrink(); // <- Sem loading
      }

      final messages = snapshot.data!.docs;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final data = messages[index].data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle, color: Colors.white, size: 36),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['autor'] ?? 'Anônimo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data['texto'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  Widget _buildChatInputField(String chatName) {
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  FirestoreService.enviarMensagemChat(
                    nomeChat: chatName,
                    autor: FirebaseAuth.instance.currentUser?.displayName ?? 'Usuário',
                    texto: controller.text,
                  );
                  controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
