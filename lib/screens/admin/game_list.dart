import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'game_form.dart'; // Você precisará criar/ajustar este arquivo também
import '../../widgets/base_layout.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> _games = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    final db = await _dbHelper.database;
    final list = await db.query('game');
    setState(() => _games = list);
  }

  Future<void> _deleteGame(int id) async {
    await _dbHelper.deleteGame(id);
    _loadGames();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(title: const Text("Gerenciar Jogos")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GameForm()),
          );
          _loadGames();
        },
      ),
      body: ListView.builder(
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return ListTile(
            title: Text(game['name']),
            subtitle: Text(game['release_date']),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteGame(game['id']),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameForm(game: game)),
              );
              _loadGames();
            },
          );
        },
      ),
    );
  }
}
