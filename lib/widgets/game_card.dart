import 'package:flutter/material.dart';

import '../models/game.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (game.status) {
      case 'Jogando':
        return Colors.blue;
      case 'Zerado':
        return Colors.green;
      case 'Abandonado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _statusColor(),
          child: const Icon(Icons.sports_esports, color: Colors.white),
        ),
        title: Text(game.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text([game.platform, if (game.genre.isNotEmpty) game.genre].join(' • ')),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(game.status,
                      style: TextStyle(color: _statusColor(), fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < game.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Excluir',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
