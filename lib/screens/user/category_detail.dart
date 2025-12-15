import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../providers/auth_provider.dart';

class CategoryDetail extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;
  const CategoryDetail({super.key, required this.categoryId, required this.categoryTitle});

  @override
  _CategoryDetailState createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  int? _currentVoteGameId;
  List<Map<String, dynamic>> _games = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DbHelper().database;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Carregar jogos da categoria
    final gamesRes = await db.rawQuery(
      '''
      SELECT g.* FROM game g 
      JOIN category_game cg ON g.id = cg.game_id 
      WHERE cg.category_id = ?
    ''',
      [widget.categoryId],
    );

    // Verificar se o usuário já votou nesta categoria
    if (auth.user != null) {
      final voteRes = await db.query(
        'user_vote',
        where: 'user_id = ? AND category_id = ?',
        whereArgs: [auth.user!.id, widget.categoryId],
      );
      if (voteRes.isNotEmpty) {
        setState(
          () => _currentVoteGameId = voteRes.first['vote_game_id'] as int,
        );
      }
    }

    setState(() => _games = gamesRes);
  }

  Future<void> _handleVote(int gameId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isGuest) return;

    final db = await DbHelper().database;

    if (_currentVoteGameId == gameId) {
      // Retirar voto
      await db.delete(
        'user_vote',
        where: 'user_id = ? AND category_id = ?',
        whereArgs: [auth.user!.id, widget.categoryId],
      );
      setState(() => _currentVoteGameId = null);
    } else if (_currentVoteGameId != null) {
      // Mudar voto
      await db.update(
        'user_vote',
        {'vote_game_id': gameId},
        where: 'user_id = ? AND category_id = ?',
        whereArgs: [auth.user!.id, widget.categoryId],
      );
      setState(() => _currentVoteGameId = gameId);
    } else {
      // Novo voto
      await db.insert('user_vote', {
        'user_id': auth.user!.id,
        'category_id': widget.categoryId,
        'vote_game_id': gameId,
      });
      setState(() => _currentVoteGameId = gameId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryTitle)),
      body: ListView.builder(
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          bool isVoted = _currentVoteGameId == game['id'];

          return Card(
            color: isVoted ? Colors.deepPurple.shade900 : null,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                game['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(game['description'], maxLines: 2),
              trailing: auth.isGuest
                  ? null
                  : IconButton(
                      icon: Icon(
                        isVoted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      onPressed: () => _handleVote(game['id']),
                    ),
            ),
          );
        },
      ),
    );
  }
}
