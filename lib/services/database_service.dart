// Camada de dados: todo acesso ao Firestore passa por aqui (CRUD dos jogos).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/game.dart';

/// CRUD dos jogos. Estrutura no Firestore: users/{uid}/games/{gameId}
/// Cada usuário só enxerga a própria estante.
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Referência à coleção de jogos do usuário logado. Como o caminho inclui
  /// o uid, cada usuário só acessa a própria estante.
  CollectionReference<Map<String, dynamic>> get _games {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('games');
  }

  /// READ: devolve a lista de jogos em tempo real, do mais recente ao mais antigo.
  /// A tela se atualiza sozinha quando algo muda no banco
  Stream<List<Game>> watchGames() {
    return _games
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Game.fromDoc).toList());
  }

  /// CREATE: adiciona um jogo; o Firestore gera o id automaticamente.
  Future<void> addGame(Game game) => _games.add(game.toMap());

    /// UPDATE: sobrescreve os campos do documento identificado por [game.id].
  Future<void> updateGame(Game game) => _games.doc(game.id).update(game.toMap());

  /// DELETE: remove o documento pelo [id].
  Future<void> deleteGame(String id) => _games.doc(id).delete();
}
