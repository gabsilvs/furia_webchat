import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PerfilFunctions {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  // Retorna o usuário atualmente logado
  static User? getUsuarioAtual() {
    return _auth.currentUser;
  }

  // Carrega os dados do Firestore do usuário atual
  static Future<Map<String, dynamic>?> carregarDadosUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    return doc.data();
  }

  // Faz o upload de nova foto de perfil
  static Future<String?> uploadFotoPerfil(File imagem) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final ref = _storage.ref().child('usuarios').child('${user.uid}.jpg');
    await ref.putFile(imagem);
    return await ref.getDownloadURL();
  }

  // Atualiza perfil do usuário no Firestore e FirebaseAuth
  static Future<void> atualizarPerfil({
    required String nome,
    required List<String> jogadoresFavoritos,
    required List<String> assuntosInteresse,
    File? novaImagem,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    String? imageUrl;
    if (novaImagem != null) {
      imageUrl = await uploadFotoPerfil(novaImagem);
      await user.updatePhotoURL(imageUrl);
    }

    if (nome != user.displayName) {
      await user.updateDisplayName(nome);
    }

    final updateData = {
      'nome': nome,
      'jogadoresFavoritos': jogadoresFavoritos,
      'assuntosInteresse': assuntosInteresse,
      'atualizadoEm': FieldValue.serverTimestamp(),
    };

    if (imageUrl != null) {
      updateData['fotoPerfil'] = imageUrl;
    }

    await _firestore.collection('usuarios').doc(user.uid).update(updateData);
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
