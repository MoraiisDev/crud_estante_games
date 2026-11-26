import 'package:cloud_firestore/cloud_firestore.dart';

// Opções fixas de status, usadas no formulário e no filtro da Home.
const List<String> kStatuses = ['Quero jogar', 'Jogando', 'Zerado', 'Abandonado'];
const List<String> kPlatforms = [
  'PC', 'PlayStation', 'Xbox', 'Nintendo Switch', 'Mobile', 'Outro'
];

/// Representa um jogo da estante. É imutável: para alterar um jogo,
/// cria-se uma nova instância com os novos valores. 
class Game {
  /// Id do documento no Firestore. É null enquanto o jogo ainda não foi salvo.
  final String? id;
  final String title;
  final String platform;
  final String genre;
  final int? releaseYear;
  final String status;
  final int rating; // 0 a 5
  final String notes;
  /// Data de criação. Mantida na edição para a ordem da lista não mudar.
  final DateTime createdAt;

  Game({
    this.id,
    required this.title,
    required this.platform,
    required this.genre,
    this.releaseYear, 
    required this.status,
    this.rating = 0,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Converte um documento do Firestore em [Game], usando valores padrão
  /// caso algum campo esteja ausente.
  factory Game.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Game(
      id: doc.id,
      title: d['title'] ?? '',
      platform: d['platform'] ?? kPlatforms.first,
      genre: d['genre'] ?? '',
      status: d['status'] ?? kStatuses.first,
      releaseYear: d['releaseYear'] as int?,
      rating: (d['rating'] ?? 0) as int,
      notes: d['notes'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converte o [Game] em Map para gravar no Firestore.
  /// O id não entra aqui porque é o nome do documento, não um campo dele.
  Map<String, dynamic> toMap() => {
        'title': title,
        'platform': platform,
        'genre': genre,
        'status': status,
        'releaseYear': releaseYear,
        'rating': rating,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
