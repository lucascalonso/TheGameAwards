import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../providers/auth_provider.dart';
import '../../models/genre_model.dart';

class GameForm extends StatefulWidget {
  final Map<String, dynamic>? game; // Nulo para novo, preenchido para edição
  const GameForm({super.key, this.game});

  @override
  _GameFormState createState() => _GameFormState();
}

class _GameFormState extends State<GameForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  List<Genre> _allGenres = [];
  final List<int> _selectedGenres = [];

  @override
  void initState() {
    super.initState();
    _loadGenres();
    if (widget.game != null) {
      _nameController.text = widget.game!['name'];
      _descController.text = widget.game!['description'];
      _dateController.text = widget.game!['release_date'];
    }
  }

  Future<void> _loadGenres() async {
    final db = await DbHelper().database;
    final res = await db.query('genre');
    setState(() => _allGenres = res.map((m) => Genre.fromMap(m)).toList());
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final db = await DbHelper().database;

    Map<String, dynamic> gameData = {
      'user_id': auth.user!.id,
      'name': _nameController.text,
      'description': _descController.text,
      'release_date': _dateController.text,
    };

    if (widget.game == null) {
      int gameId = await db.insert('game', gameData);
      for (int gId in _selectedGenres) {
        await db.insert('game_genre', {'game_id': gameId, 'genre_id': gId});
      }
    } else {
      await db.update(
        'game',
        gameData,
        where: 'id = ?',
        whereArgs: [widget.game!['id']],
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game == null ? "Novo Jogo" : "Editar Jogo"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nome do Jogo"),
            ),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(labelText: "Descrição"),
              maxLines: 3,
            ),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: "Data de Lançamento (AAAA-MM-DD)",
              ),
            ),
            SizedBox(height: 20),
            Text("Selecione os Gêneros:"),
            Wrap(
              children: _allGenres.map((genre) {
                return FilterChip(
                  label: Text(genre.name),
                  selected: _selectedGenres.contains(genre.id),
                  onSelected: (val) {
                    setState(
                      () => val
                          ? _selectedGenres.add(genre.id!)
                          : _selectedGenres.remove(genre.id),
                    );
                  },
                );
              }).toList(),
            ),
            ElevatedButton(onPressed: _saveGame, child: Text("Salvar Jogo")),
          ],
        ),
      ),
    );
  }
}
