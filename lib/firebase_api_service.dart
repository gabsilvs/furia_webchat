import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class FirebaseApiService {
  static final _auth = FirebaseAuth.instance;
  static final _functions = FirebaseFunctions.instance;

  // Configurar emulador se estiver em desenvolvimento
  static void configure() {
    if (kDebugMode) {
      _functions.useFunctionsEmulator('localhost', 5001);
    }
  }

  static Future<User?> autoLogin() async {
    return _auth.currentUser;
  }

  static Future<void> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    required List<String> jogadores,
    required List<String> assuntos,
    String? imagemPath,
  }) async {
    try {
      final callable = _functions.httpsCallable('cadastrarUsuario');
      final result = await callable.call({
        'nome': nome,
        'email': email,
        'senha': senha,
        'cpf': cpf,
        'jogadores': jogadores,
        'assuntos': assuntos,
        'imagemPath': imagemPath,
      });

      // Loga o usuário automaticamente após cadastro
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> adicionarComentario({
    required String idNoticia,
    required String autor,
    required String texto,
  }) async {
    try {
      final callable = _functions.httpsCallable('adicionarComentario');
      await callable.call({
        'idNoticia': idNoticia,
        'autor': autor,
        'texto': texto,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> enviarMensagemChat({
    required String nomeChat,
    required String autor,
    required String texto,
  }) async {
    try {
      final callable = _functions.httpsCallable('enviarMensagemChat');
      await callable.call({
        'nomeChat': nomeChat,
        'autor': autor,
        'texto': texto,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}