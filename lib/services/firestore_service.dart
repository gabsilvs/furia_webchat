import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // Salvar comentário em uma notícia
  static Future<void> adicionarComentario({
    required String idNoticia,
    required String autor,
    required String texto,
  }) async {
    await _db
        .collection('noticias')
        .doc(idNoticia)
        .collection('comentarios')
        .add({
      'autor': autor,
      'texto': texto,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream de comentários de uma notícia
  static Stream<QuerySnapshot> comentariosStream(String idNoticia) {
    return _db
        .collection('noticias')
        .doc(idNoticia)
        .collection('comentarios')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Enviar mensagem em um chat
  static Future<void> enviarMensagemChat({
    required String nomeChat,
    required String autor,
    required String texto,
  }) async {
    await _db
        .collection('chats')
        .doc(nomeChat)
        .collection('mensagens')
        .add({
      'autor': autor,
      'texto': texto,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream de mensagens de um chat
  static Stream<QuerySnapshot> mensagensChatStream(String nomeChat) {
    return _db
        .collection('chats')
        .doc(nomeChat)
        .collection('mensagens')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
