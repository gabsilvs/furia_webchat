import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseAuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  // Verifica se o usuário está autenticado e retorna
  static Future<User?> autoLogin() async {
    return _auth.currentUser;
  }

  // Cadastra um novo usuário
  static Future<User?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String jogador,
    required String assunto,
    String? twitter,
    String? instagram,
    File? imagem,
  }) async {
    try {
      final credenciais = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      String? imageUrl;
      if (imagem != null) {
        final ref = _storage
            .ref()
            .child('usuarios')
            .child('${credenciais.user!.uid}.jpg');
        await ref.putFile(imagem);
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection('usuarios').doc(credenciais.user!.uid).set({
        'uid': credenciais.user!.uid,
        'nome': nome,
        'email': email,
        'jogadorFavorito': jogador,
        'assuntoInteresse': assunto,
        'twitter': twitter,
        'instagram': instagram,
        'fotoPerfil': imageUrl,
        'criadoEm': Timestamp.now(),
      });

      return credenciais.user;
    } catch (e) {
      rethrow;
    }
  }

  // Faz o logout do usuário
  static Future<void> logout() async {
    await _auth.signOut();
  }
}
