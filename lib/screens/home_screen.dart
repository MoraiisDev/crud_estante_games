import 'package:flutter/material.dart';

import '../main.dart';
import '../models/game.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/game_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService();
  final _auth = AuthService();
  String _search = '';
  String _filter = 'Todos';

  Future<void> _confirmDelete(Game game) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir jogo'),
        content: Text('Deseja remover "${game.title}" da sua estante?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _db.deleteGame(game.id!);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Jogo excluído.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao excluir o jogo.')));
      }
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja encerrar a sessão?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (ok == true) await _auth.logout(); // AuthGate volta para o login
  }

  @override
  Widget build(BuildContext context) {
    final name = _auth.currentUser?.displayName;
    return Scaffold(
      appBar: AppBar(
        title: Text(name == null || name.isEmpty
            ? 'Minha Estante'
            : 'Estante de $name'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.gameForm),
        icon: const Icon(Icons.add),
        label: const Text('Novo jogo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por título...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: ['Todos', ...kStatuses]
                  .map((s) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: ChoiceChip(
                          label: Text(s),
                          selected: _filter == s,
                          onSelected: (_) => setState(() => _filter = s),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Game>>(
              stream: _db.watchGames(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar os jogos.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final games = snapshot.data!.where((g) {
                  final matchSearch = g.title.toLowerCase().contains(_search);
                  final matchFilter = _filter == 'Todos' || g.status == _filter;
                  return matchSearch && matchFilter;
                }).toList();

                if (games.isEmpty) {
                  return const Center(
                    child: Text('Nenhum jogo encontrado.\nToque em "Novo jogo" para adicionar.',
                        textAlign: TextAlign.center),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: games.length,
                  itemBuilder: (_, i) => GameCard(
                    game: games[i],
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.gameForm,
                        arguments: games[i]),
                    onDelete: () => _confirmDelete(games[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
