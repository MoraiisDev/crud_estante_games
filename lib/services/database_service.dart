import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/game.dart';

/// CRUD dos jogos. Estrutura no Firestore: users/{uid}/games/{gameId}
/// Cada usuário só enxerga a própria estante.
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _games {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('games');
  }

  // READ (tempo real)
  Stream<List<Game>> watchGames() {
    return _games
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Game.fromDoc).toList());
  }

  // CREATE
  Future<void> addGame(Game game) => _games.add(game.toMap());

  // UPDATE
  Future<void> updateGame(Game game) => _games.doc(game.id).update(game.toMap());

  // DELETE
  Future<void> deleteGame(String id) => _games.doc(id).delete();
}
