# 🎮 Estante Virtual de Jogos

Aplicativo desenvolvido em **Flutter** para organizar a coleção pessoal de jogos de cada usuário, com autenticação e banco de dados em nuvem via **Firebase**.

> **Autor:** João Vitor Morias Dias
> **Disciplina:** Programação para Dispositivos Móveis II
> **Professor(a):** Elias Carneiro De Oliveira

---

## 📖 Descrição do aplicativo

A **Estante Virtual de Jogos** permite que o usuário crie uma conta e monte a sua própria estante de jogos, registrando título, plataforma, gênero, status de progresso, nota e anotações pessoais. Cada usuário enxerga e gerencia **apenas os seus próprios jogos**, e os dados ficam salvos na nuvem, sincronizados em tempo real.

---

## ✅ Funcionalidades principais

**Autenticação**
- Cadastro de usuário (nome, e-mail e senha)
- Login com e-mail e senha
- Logout com confirmação
- Proteção de telas: somente usuários autenticados acessam a estante
- Tratamento de erros (e-mail já cadastrado, senha incorreta, senha fraca, e-mail inválido, sem conexão, etc.)

**CRUD de jogos**
- **Criar:** adicionar um novo jogo à estante
- **Ler:** listar os jogos em tempo real
- **Atualizar:** editar qualquer informação do jogo (toque no card)
- **Deletar:** remover um jogo, com confirmação

**Extras**
- Busca por título
- Filtro por status (Todos, Quero jogar, Jogando, Zerado, Abandonado)
- Avaliação por estrelas (0 a 5)
- Validação de formulários (campos obrigatórios, formato de e-mail, tamanho mínimo e confirmação de senha)

---

## 🛠️ Tecnologias utilizadas

| Tecnologia | Uso |
|---|---|
| [Flutter](https://flutter.dev) | Framework de interface |
| [Dart](https://dart.dev) | Linguagem de programação |
| [Firebase Authentication](https://firebase.google.com/docs/auth) | Login, cadastro e sessão do usuário |
| [Cloud Firestore](https://firebase.google.com/docs/firestore) | Banco de dados NoSQL em nuvem |
| Rotas nomeadas (`Navigator` / `onGenerateRoute`) | Gerenciamento de telas |

**Pacotes:** `firebase_core`, `firebase_auth`, `cloud_firestore`

---

## 📁 Estrutura do projeto

```
lib/
 ├── main.dart                      # Inicialização, rotas e AuthGate (proteção de telas)
 ├── firebase_options.dart          # Gerado pelo FlutterFire CLI
 ├── models/
 │    └── game.dart                 # Modelo Game (toMap / fromDoc)
 ├── services/
 │    ├── auth_service.dart         # Login, cadastro, logout e tradução de erros
 │    └── database_service.dart     # CRUD no Firestore
 ├── screens/
 │    ├── login_screen.dart
 │    ├── register_screen.dart
 │    ├── home_screen.dart          # Listagem, busca, filtro, exclusão e logout
 │    └── game_form_screen.dart     # Formulário de criar/editar jogo
 └── widgets/
      ├── app_text_field.dart       # Campo de texto reutilizável
      └── game_card.dart            # Card de exibição do jogo
```

A lógica está separada em camadas: **UI** (`screens` e `widgets`), **serviços** (`services`) e **modelos** (`models`).

---

## ▶️ Instruções para executar o projeto

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (`flutter doctor` sem erros)
- Um emulador Android, dispositivo físico ou navegador (Chrome)
- Uma conta Google para usar o Firebase
- [Node.js](https://nodejs.org) (necessário para o Firebase CLI)

### 1. Clonar o projeto e instalar as dependências
```bash
git clone <url-do-repositorio>
cd estante_virtual_jogos
flutter pub get
```

### 2. Criar e configurar o projeto no Firebase
1. Acesse o [Console do Firebase](https://console.firebase.google.com) e crie um projeto (plano **Spark**, gratuito).
2. Em **Authentication > Método de login**, ative **E-mail/senha**.
3. Em **Firestore Database**, clique em **Criar banco de dados**.
4. Em **Firestore Database > Regras**, cole o conteúdo do arquivo `firestore.rules` e publique.

### 3. Conectar o app ao Firebase
```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```
Selecione o projeto criado e as plataformas desejadas. Isso gera o arquivo `lib/firebase_options.dart`.

> **Windows:** se o comando `flutterfire` não for reconhecido, use
> `dart pub global run flutterfire_cli:flutterfire configure`
> ou adicione `C:\Users\<seu-usuario>\AppData\Local\Pub\Cache\bin` ao PATH.

### 4. Executar
```bash
flutter run
```

> **Android:** se houver erro de build, verifique se o `minSdkVersion` em `android/app/build.gradle` é **23 ou superior**.

---

## 🔐 Autenticação

A autenticação usa o **Firebase Authentication** com o provedor **E-mail e senha**.

- No **cadastro**, a conta é criada e o nome do usuário é salvo no perfil (`displayName`). Após cadastrar, o usuário já entra logado.
- No **login**, as credenciais são verificadas pelo Firebase. Em caso de falha, uma mensagem amigável é exibida.
- A **proteção de telas** é feita pelo widget `AuthGate`, que escuta `authStateChanges()`: se há usuário logado exibe a `HomeScreen`, caso contrário exibe a `LoginScreen`. As rotas protegidas (`/home` e `/game-form`) também redirecionam para o login quando não há sessão.
- No **logout**, a sessão é encerrada e o app volta automaticamente para o login.

---

## 🗄️ Base de dados

O banco de dados é o **Cloud Firestore** (NoSQL, em nuvem, tempo real). Os jogos de cada usuário ficam em uma subcoleção dentro do documento dele:

```
users (coleção)
 └── {uid} (documento do usuário)
      └── games (subcoleção)
           └── {gameId} (documento do jogo)
                ├── title      : string
                ├── platform   : string
                ├── genre      : string
                ├── status     : string   (Quero jogar | Jogando | Zerado | Abandonado)
                ├── rating     : number   (0 a 5)
                ├── notes      : string
                └── createdAt  : timestamp
```

A listagem usa `snapshots()`, então qualquer alteração aparece na tela imediatamente.

**Segurança:** as regras do Firestore (`firestore.rules`) garantem que cada usuário só leia e escreva os próprios dados:

```
match /users/{userId}/games/{gameId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

---

## 📄 Licença

Projeto desenvolvido para fins acadêmicos.
