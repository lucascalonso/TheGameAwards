import 'dart:ui'; // Para o Blur
import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/tga_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final DbHelper _dbHelper = DbHelper();

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _genres = [];
  List<Map<String, dynamic>> _searchResults = [];

  int? _selectedCategoryId;
  int? _selectedGenreId;
  int? _selectedPosition; // 1, 2, 3

  bool _hasSearched = false;
  bool _isLoading = false;

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
    setState(() => _isLoading = true);
    
    // Simula um delay rápido para dar feedback visual de "buscando"
    await Future.delayed(const Duration(milliseconds: 600));

    final results = await _dbHelper.searchGames(
      categoryId: _selectedCategoryId,
      genreId: _selectedGenreId,
      position: _selectedPosition,
    );

    if (mounted) {
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isLoading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedGenreId = null;
      _selectedPosition = null;
      _hasSearched = false;
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: const Text(
                "BUSCAR JOGOS",
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontWeight: FontWeight.bold,
                  color: AppTheme.tgaGold,
                  letterSpacing: 1.5,
                  fontSize: 16,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.black.withOpacity(0.5),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                if (_selectedCategoryId != null || _selectedGenreId != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white54),
                    tooltip: "Limpar Filtros",
                    onPressed: _clearFilters,
                  )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF000000)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100), // Espaço para a AppBar
            
            // --- ÁREA DE FILTROS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Linha 1: Categoria e Gênero
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown<int>(
                                label: "Categoria",
                                value: _selectedCategoryId,
                                items: _categories.map((c) => DropdownMenuItem<int>(
                                  value: c['id'],
                                  child: Text(c['title'], overflow: TextOverflow.ellipsis),
                                )).toList(),
                                onChanged: (val) => setState(() {
                                  _selectedCategoryId = val;
                                  if (val == null) _selectedPosition = null; // Reseta posição se limpar cat
                                }),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown<int>(
                                label: "Gênero",
                                value: _selectedGenreId,
                                items: _genres.map((g) => DropdownMenuItem<int>(
                                  value: g['id'],
                                  child: Text(g['name']),
                                )).toList(),
                                onChanged: (val) => setState(() => _selectedGenreId = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Linha 2: Posição (Condicional)
                        Opacity(
                          opacity: _selectedCategoryId != null ? 1.0 : 0.5,
                          child: IgnorePointer(
                            ignoring: _selectedCategoryId == null,
                            child: _buildDropdown<int>(
                              label: "Classificação (Requer Categoria)",
                              value: _selectedPosition,
                              items: const [
                                DropdownMenuItem(value: 1, child: Text("1º Lugar (Vencedor)")),
                                DropdownMenuItem(value: 2, child: Text("2º Lugar")),
                                DropdownMenuItem(value: 3, child: Text("3º Lugar")),
                              ],
                              onChanged: (val) => setState(() => _selectedPosition = val),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Botão Buscar
                        TgaButton(
                          text: "PESQUISAR",
                          isLoading: _isLoading,
                          onPressed: _performSearch,
                          icon: Icons.search,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Divider(color: Colors.white10),

            // --- LISTA DE RESULTADOS ---
            Expanded(
              child: _isLoading 
                  ? const Center(child: SizedBox()) // O loading já está no botão
                  : _hasSearched && _searchResults.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final game = _searchResults[index];
                            return _buildResultCard(game, index);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para Dropdowns estilizados
  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.tgaGold),
              hint: const Text("Selecione...", style: TextStyle(color: Colors.white24)),
              items: [
                DropdownMenuItem<T>(
                  value: null,
                  child: Text("Todos/Qualquer", style: TextStyle(color: AppTheme.tgaGold.withOpacity(0.7))),
                ),
                ...items,
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text(
            "Nenhum jogo encontrado com estes filtros.",
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> game, int index) {
    // Animação simples de slide para cada item
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Imagem Pequena (Thumbnail)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: SizedBox(
                width: 80,
                height: 80,
                child: game['image_url'] != null
                    ? Image.network(
                        game['image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderIcon(),
                      )
                    : _placeholderIcon(),
              ),
            ),
            
            // Informações
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      game['name'] ?? "Sem Nome",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game['description'] ?? "Sem descrição",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),

            // Ícone lateral
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.videogame_asset, color: Colors.white24),
      ),
    );
  }
}