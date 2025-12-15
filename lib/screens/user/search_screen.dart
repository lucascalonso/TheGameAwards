import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../widgets/base_layout.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DbHelper _dbHelper = DbHelper();

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _genres = [];
  List<Map<String, dynamic>> _searchResults = [];

  int? _selectedCategoryId;
  int? _selectedGenreId;
  int? _selectedPosition; // 1, 2, 3

  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    final cats = await _dbHelper.getAllCategories();
    final gens = await _dbHelper.getAllGenres();
    setState(() {
      _categories = cats;
      _genres = gens;
    });
  }

  Future<void> _performSearch() async {
    final results = await _dbHelper.searchGames(
      categoryId: _selectedCategoryId,
      genreId: _selectedGenreId,
      position: _selectedPosition,
    );
    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(title: const Text("Buscar Jogos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Filtro de Categoria
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Categoria"),
                  value: _selectedCategoryId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Todas")),
                    ..._categories.map(
                      (c) => DropdownMenuItem<int>(
                        value: c['id'],
                        child: Text(
                          c['title'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),

                // Filtro de Gênero
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Gênero"),
                  value: _selectedGenreId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Todos")),
                    ..._genres.map(
                      (g) => DropdownMenuItem<int>(
                        value: g['id'],
                        child: Text(g['name']),
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedGenreId = val),
                ),

                // Filtro de Posição (Só faz sentido se tiver categoria selecionada)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Posição (Requer Categoria)",
                  ),
                  value: _selectedPosition,
                  items: const [
                    DropdownMenuItem(value: null, child: Text("Qualquer")),
                    DropdownMenuItem(value: 1, child: Text("1º Lugar")),
                    DropdownMenuItem(value: 2, child: Text("2º Lugar")),
                    DropdownMenuItem(value: 3, child: Text("3º Lugar")),
                  ],
                  onChanged: _selectedCategoryId == null
                      ? null
                      : (val) => setState(() => _selectedPosition = val),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search),
                  label: const Text("Buscar"),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _hasSearched && _searchResults.isEmpty
                ? const Center(child: Text("Nenhum jogo encontrado."))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final game = _searchResults[index];
                      return ListTile(
                        title: Text(game['name']),
                        subtitle: Text(
                          game['description'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: const Icon(Icons.videogame_asset),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
