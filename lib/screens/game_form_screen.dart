import 'package:flutter/material.dart';

import '../models/game.dart';
import '../services/database_service.dart';
import '../widgets/app_text_field.dart';

/// Formulário usado para criar e editar jogos.
/// Se [game] for null cria um novo; se vier preenchido, edita o existente.
class GameFormScreen extends StatefulWidget {
  final Game? game;
  const GameFormScreen({super.key, this.game});

  @override
  State<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends State<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _genreCtrl;
  late final TextEditingController _notesCtrl;
  late String _platform;
  late String _status;
  late final TextEditingController _yearCtrl;
  late int _rating;
  bool _saving = false;

  /// Verdadeiro quando está editando um jogo já existente.
  bool get _isEditing => widget.game != null;

  @override
  void initState() {
    super.initState();
    final g = widget.game;
    _titleCtrl = TextEditingController(text: g?.title ?? '');
    _genreCtrl = TextEditingController(text: g?.genre ?? '');
    _notesCtrl = TextEditingController(text: g?.notes ?? '');
    _platform = g?.platform ?? kPlatforms.first;
    _status = g?.status ?? kStatuses.first;
    _yearCtrl = TextEditingController(text: g?.releaseYear?.toString() ?? '');
    _rating = g?.rating ?? 0;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _genreCtrl.dispose();
    _notesCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  /// Valida o formulário e grava no Firestore (add ou update conforme o modo).
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final game = Game(
        id: widget.game?.id,
        title: _titleCtrl.text.trim(),
        platform: _platform,
        genre: _genreCtrl.text.trim(),
        status: _status,
        releaseYear: int.tryParse(_yearCtrl.text.trim()),
        rating: _rating,
        notes: _notesCtrl.text.trim(),
        createdAt: widget.game?.createdAt, // mantém a data original ao editar
      );
      _isEditing ? await _db.updateGame(game) : await _db.addGame(game);
      if (!mounted) return;
      // Guarda o messenger antes do pop: depois que a tela fecha, o context
      // dela não pode mais ser usado com segurança.
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Jogo atualizado!' : 'Jogo adicionado!')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar o jogo.')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar jogo' : 'Novo jogo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Título *',
                icon: Icons.sports_esports,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _platform,
                decoration: const InputDecoration(labelText: 'Plataforma'),
                items: kPlatforms
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _platform = v!),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _genreCtrl,
                label: 'Gênero (ex.: RPG, Ação)',
                icon: Icons.category_outlined,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: kStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _yearCtrl,
                label: 'Ano de lançamento',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return null;
                  final year = int.tryParse(v.trim());
                  if (year == null) return 'Digite apenas números';
                  if (year < 1950 || year > DateTime.now().year + 2)
                    return 'Ano inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(
                  5,
                  (i) => IconButton(
                    onPressed: () =>
                        setState(() => _rating = (_rating == i + 1) ? 0 : i + 1),
                    icon: Icon(
                      i < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _notesCtrl,
                label: 'Anotações',
                icon: Icons.notes,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_isEditing ? 'Salvar alterações' : 'Adicionar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
