import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

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
      // Primeiro cria o usuário no Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Depois salva no Firestore
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'cpf': cpf,
          'jogadoresFavoritos': jogadores,
          'assuntosInteresse': assuntos,
          'imagemPerfil': imagemPath,
          'uid': user.uid,
          'criadoEm': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
