
# FURIA Community App

O **FURIA Community App** é uma plataforma mobile desenvolvida com Flutter, voltada para fãs da organização de esports **FURIA**. O aplicativo permite aos usuários se conectarem com outros torcedores, acompanharem notícias da equipe e interagirem por meio de comentários e chats em tempo real.

---

## 📱 Funcionalidades

- Cadastro de usuários e login (incluindo login anônimo)
- Visualização de notícias e comentários
- Chat entre membros da comunidade
- Personalização de perfil com jogadores favoritos e assuntos de interesse

---

## 🏗️ Arquitetura do Projeto

### 🧰 Tecnologias Utilizadas

- **Flutter**: Framework principal para desenvolvimento mobile
- **Firebase** (BaaS):
  - **Authentication** (Autenticação por e-mail/senha e anônima)
  - **Firestore** (Banco de dados NoSQL em tempo real)
  - **Cloud Functions** (Lógica de backend personalizada)
- **Carousel Slider**: Biblioteca para carrossel de imagens

---

## 📁 Estrutura de Pastas

```
lib/
├── screens/
│   ├── cadastro_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── perfil_screen.dart
├── services/
│   ├── firebase_api_service.dart
│   ├── firebase_auth_service.dart
│   └── firestore_service.dart
├── main.dart
└── ...
```

---

## 🖥️ Telas Principais

### 1. **Login Screen** (`login_screen.dart`)

- Autenticação por e-mail/senha ou login anônimo
- Validação básica de campos
- Carrossel de imagens promocionais

### 2. **Cadastro Screen** (`cadastro_screen.dart`)

- Cadastro de novos usuários
- Seleção de jogadores favoritos e assuntos de interesse (Chips)
- Integração com Firebase + validação

### 3. **Home Screen** (`home_screen.dart`)

- Listagem de notícias com comentários
- Lista de chats disponíveis
- Modal de chat em tempo real

### 4. **Perfil Screen** (`perfil_screen.dart`)

- Visualização de informações do usuário
- Jogadores favoritos e interesses em destaque
- Botão de logout

---

## 🔌 Serviços (Backend)

### 1. **FirebaseApiService** (`firebase_api_service.dart`)

Responsável por comunicação com as Cloud Functions do Firebase:

- `cadastrarUsuario()`
- `adicionarComentario()`
- `enviarMensagemChat()`

### 2. **FirebaseAuthService** (`firebase_auth_service.dart`)

Gerencia a autenticação:

- `autoLogin()`
- `cadastrarUsuario()`
- `logout()`

### 3. **FirestoreService** (`firestore_service.dart`)

Gerencia operações diretas com o Firestore:

- `comentariosStream()` — Comentários em tempo real
- `mensagensChatStream()` — Mensagens em tempo real
- Métodos para adicionar mensagens e comentários

---

## 🔄 Fluxo de Navegação

```
Login Screen
  ├── Cadastro Screen
  └── Home Screen
        └── Perfil Screen
```

---

## 📦 Dependências (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.15.1
  firebase_auth: ^4.9.1
  cloud_firestore: ^4.9.0
  firebase_cloud_functions: ^4.5.0
  carousel_slider: ^4.2.1
```

---

## ☁️ Configuração do Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione o aplicativo Flutter ao projeto
3. Baixe o `google-services.json` e adicione à pasta `android/app/`
4. Habilite os serviços:
   - Authentication (E-mail/Senha, Anônimo)
   - Firestore
   - Cloud Functions

---

## 🔧 Exemplo de Cloud Function

```javascript
exports.cadastrarUsuario = functions.https.onCall(async (data, context) => {
  // 1. Validar dados
  // 2. Criar usuário no Auth
  // 3. Salvar dados adicionais no Firestore
  // 4. Retornar resultado
});
```

---

