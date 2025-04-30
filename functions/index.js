const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

// Função para cadastrar usuário
exports.cadastrarUsuario = functions.https.onCall(async (data, context) => {
  try {
    // 1. Criar usuário no Auth
    const userRecord = await auth.createUser({
      email: data.email,
      password: data.senha,
      displayName: data.nome,
    });

    // 2. Salvar dados no Firestore
    await db.collection('usuarios').doc(userRecord.uid).set({
      nome: data.nome,
      email: data.email,
      cpf: data.cpf,
      jogadoresFavoritos: data.jogadores,
      assuntosInteresse: data.assuntos,
      imagemPerfil: data.imagemPath,
      uid: userRecord.uid,
      criadoEm: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, uid: userRecord.uid };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Função para adicionar comentário
exports.adicionarComentario = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuário não autenticado');
  }

  try {
    const docRef = await db
      .collection('noticias')
      .doc(data.idNoticia)
      .collection('comentarios')
      .add({
        autor: data.autor,
        texto: data.texto,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

    return { success: true, id: docRef.id };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Função para enviar mensagem no chat
exports.enviarMensagemChat = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuário não autenticado');
  }

  try {
    const docRef = await db
      .collection('chats')
      .doc(data.nomeChat)
      .collection('mensagens')
      .add({
        autor: data.autor,
        texto: data.texto,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

    return { success: true, id: docRef.id };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});