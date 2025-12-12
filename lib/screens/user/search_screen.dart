import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? _selectedGenreId;
  int? _selectedCategoryId;
  int? _selectedRank;
  List<Map<String, dynamic>> _results = [];

  _performSearch() async {
    final db = await DbHelper().database;

    // Query complexa para calcular ranking e filtrar
    String query = '''
      SELECT g.name as game_name, c.title as cat_title, COUNT(v.id) as votes,
      RANK() OVER (PARTITION BY c.id ORDER BY COUNT(v.id) DESC) as position
      FROM game g
      JOIN category_game cg ON g.id = cg.game_id
      JOIN category c ON cg.category_id = c.id
      LEFT JOIN user_vote v ON g.id = v.vote_game_id AND c.id = v.category_id
      LEFT JOIN game_genre gg ON g.id = gg.game_id
      WHERE 1=1
    ''';

    List<dynamic> args = [];
    if (_selectedCategoryId != null) {
      query += " AND c.id = ?";
      args.add(_selectedCategoryId);
    }
    if (_selectedGenreId != null) {
      query += " AND gg.genre_id = ?";
      args.add(_selectedGenreId);
    }

    query += " GROUP BY g.id, c.id";

    if (_selectedRank != null) {
      query = "SELECT * FROM ($query) WHERE position = ?";
      args.add(_selectedRank);
    }

    final res = await db.rawQuery(query, args);
    setState(() => _results = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pesquisa e Ranking")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    hint: Text("Posição"),
                    value: _selectedRank,
                    items: [1, 2, 3]
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text("$rº Lugar"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedRank = val),
                  ),
                ),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return ListTile(
                  leading: CircleAvatar(child: Text("${item['position']}º")),
                  title: Text(item['game_name']),
                  subtitle: Text(
                    "Categoria: ${item['cat_title']} | Votos: ${item['votes']}",
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
