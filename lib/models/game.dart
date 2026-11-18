import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> kStatuses = ['Quero jogar', 'Jogando', 'Zerado', 'Abandonado'];
const List<String> kPlatforms = [
  'PC', 'PlayStation', 'Xbox', 'Nintendo Switch', 'Mobile', 'Outro'
];

class Game {
  final String? id;
  final String title;
  final String platform;
  final String genre;
  final String status;
  final int rating; // 0 a 5
  final String notes;
  final DateTime createdAt;

  Game({
    this.id,
    required this.title,
    required this.platform,
    required this.genre,
    required this.status,
    this.rating = 0,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Game.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Game(
      id: doc.id,
      title: d['title'] ?? '',
      platform: d['platform'] ?? kPlatforms.first,
      genre: d['genre'] ?? '',
      status: d['status'] ?? kStatuses.first,
      rating: (d['rating'] ?? 0) as int,
      notes: d['notes'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'platform': platform,
        'genre': genre,
        'status': status,
        'rating': rating,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
