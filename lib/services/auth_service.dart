// Camada de autenticação: encapsula o Firebase Auth para que as telas não dependam diretamente dele.   
import 'package:firebase_auth/firebase_auth.dart';

/// Erro de autenticação com mensagem já traduzida e pronta para exibir ao usuário.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Emite um evento sempre que o usuário entra ou sai. Usado pelo AuthGate.
  Stream<User?> get authState => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Cria a conta e grava o nome no perfil (displayName).
  /// Lança [AuthException] se o cadastro falhar (e-mail em uso, senha fraca, etc.)
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_translate(e.code));
    }
  }

  /// Autentica com e-mail e senha. Lança [AuthException] em caso de falha.
  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_translate(e.code));
    }
  }
  
  /// Encerra a sessão. O AuthGate leva o app de volta ao login.
  Future<void> logout() => _auth.signOut();

  /// Traduz os códigos de erro do Firebase para mensagens em português.
  String _translate(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Erro de autenticação ($code).';
    }
  }
}
