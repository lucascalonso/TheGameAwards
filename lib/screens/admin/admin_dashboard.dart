import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/tga_button.dart'; // Se tiver o botão customizado

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DbHelper _dbHelper = DbHelper();
  
  // Listas para armazenar os dados do banco
  List<Map<String, dynamic>> _games = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  // Busca dados atualizados do banco
  void _refreshData() async {
    setState(() => _isLoading = true);
    final db = await _dbHelper.database;
    
    // Busca tudo
    final gamesData = await db.query('game');
    final categoriesData = await db.query('category');

    setState(() {
      _games = gamesData;
      _categories = categoriesData;
      _isLoading = false;
    });
  }

  // Lógica para deletar itens
  Future<void> _deleteItem(String table, int id) async {
    final db = await _dbHelper.database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
    
    // Se deletar um jogo, também removemos as vinculações dele nas categorias
    if (table == 'game') {
      await db.delete('category_game', where: 'game_id = ?', whereArgs: [id]);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item removido"), backgroundColor: AppTheme.tgaError),
    );
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("PAINEL ADMIN TGA"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.tgaError),
            onPressed: () {
              auth.logout();
              // O main.dart cuidará do redirecionamento
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.tgaGold,
          labelColor: AppTheme.tgaGold,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.videogame_asset), text: "JOGOS (BIBLIOTECA)"),
            Tab(icon: Icon(Icons.emoji_events), text: "CATEGORIAS"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.tgaGold))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGamesTab(),
                _buildCategoriesTab(),
              ],
            ),
    );
  }

  // --- ABA 1: GERENCIAR JOGOS (COM IMAGENS) ---
  Widget _buildGamesTab() {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: _games.length,
          itemBuilder: (context, index) {
            final game = _games[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                // Exibe a miniatura da imagem
                leading: Container(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                    image: (game['image_url'] != null && game['image_url'].toString().isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(game['image_url']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (game['image_url'] == null || game['image_url'].toString().isEmpty)
                      ? const Icon(Icons.image_not_supported, size: 20, color: Colors.white24)
                      : null,
                ),
                title: Text(
                  game['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.tgaGold),
                ),
                subtitle: Text(
                  game['description'] ?? "Sem descrição",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: () => _showGameDialog(game: game),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.tgaError),
                      onPressed: () => _deleteItem('game', game['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            backgroundColor: AppTheme.tgaGold,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text("NOVO JOGO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () => _showGameDialog(),
          ),
        ),
      ],
    );
  }

  // --- ABA 2: GERENCIAR CATEGORIAS ---
  Widget _buildCategoriesTab() {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.emoji_events, color: AppTheme.tgaGold, size: 30),
                title: Text(cat['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(cat['description'] ?? ""),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão para vincular jogos a categoria
                    IconButton(
                      icon: const Icon(Icons.link, color: Colors.white),
                      tooltip: "Vincular Jogos",
                      onPressed: () => _showLinkGamesDialog(cat),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.tgaError),
                      onPressed: () => _deleteItem('category', cat['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            backgroundColor: AppTheme.tgaGold,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text("NOVA CATEGORIA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () => _showCategoryDialog(),
          ),
        ),
      ],
    );
  }

  // --- DIALOGS (FORMULÁRIOS) ---

  // 1. Criar/Editar Jogo
  void _showGameDialog({Map<String, dynamic>? game}) {
    final nameCtrl = TextEditingController(text: game?['name']);
    final descCtrl = TextEditingController(text: game?['description']);
    final imgCtrl = TextEditingController(text: game?['image_url']); // CAMPO NOVO

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.tgaSurface,
        title: Text(game == null ? "Adicionar Jogo" : "Editar Jogo", style: const TextStyle(color: AppTheme.tgaGold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Nome do Jogo"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Desenvolvedora / Descrição"),
              ),
              const SizedBox(height: 10),
              // CAMPO DA IMAGEM
              TextField(
                controller: imgCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "URL da Imagem (Capa)",
                  hintText: "https://...",
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Dica: Copie o link da imagem (Poster Vertical) do Google.",
                style: TextStyle(fontSize: 10, color: Colors.white54),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            child: const Text("SALVAR"),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                final db = await _dbHelper.database;
                final data = {
                  'name': nameCtrl.text,
                  'description': descCtrl.text,
                  'image_url': imgCtrl.text,
                };

                if (game == null) {
                  await db.insert('game', data);
                } else {
                  await db.update('game', data, where: 'id = ?', whereArgs: [game['id']]);
                }
                _refreshData();
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  // 2. Criar Categoria
  void _showCategoryDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.tgaSurface,
        title: const Text("Nova Categoria", style: TextStyle(color: AppTheme.tgaGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Título (ex: JOGO DO ANO)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Descrição"),
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            child: const Text("CRIAR"),
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                final db = await _dbHelper.database;
                // Ajuste a data para o futuro para a categoria aparecer como ativa
                await db.insert('category', {
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'date': DateTime.now().add(const Duration(days: 30)).toIso8601String(), 
                });
                _refreshData();
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

 void _showLinkGamesDialog(Map<String, dynamic> category) async {
    final db = await _dbHelper.database;
    
    // Buscar todos os jogos
    final allGames = await db.query('game');
    
    // Buscar jogos já vinculados a esta categoria
    final linkedResult = await db.query(
      'category_game',
      where: 'category_id = ?',
      whereArgs: [category['id']],
    );
    
    // Convertendo explicitamente para int para evitar erros
    final linkedIds = linkedResult.map((e) => e['game_id'] as int).toList();

    // Estado local para o Dialog
    List<int> selectedIds = List.from(linkedIds);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppTheme.tgaSurface,
            title: Text(
              // Correção aqui também para o título da categoria
              "Indicados: ${category['title']}", 
              style: const TextStyle(fontSize: 16, color: AppTheme.tgaGold)
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: allGames.isEmpty 
                  ? const Center(child: Text("Cadastre jogos primeiro na outra aba!"))
                  : ListView.builder(
                      itemCount: allGames.length,
                      itemBuilder: (context, index) {
                        final game = allGames[index];
                        // Correção 1: Garantindo que id é int
                        final int gameId = game['id'] as int;
                        final isSelected = selectedIds.contains(gameId);
                        
                        return CheckboxListTile(
                          // Correção 2: Garantindo que name é String
                          title: Text(
                            game['name'] as String, 
                            style: const TextStyle(color: Colors.white)
                          ),
                          activeColor: AppTheme.tgaGold,
                          checkColor: Colors.black,
                          value: isSelected,
                          onChanged: (bool? value) {
                            setStateDialog(() {
                              if (value == true) {
                                selectedIds.add(gameId);
                              } else {
                                selectedIds.remove(gameId);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(context)),
              ElevatedButton(
                child: const Text("SALVAR INDICADOS"),
                onPressed: () async {
                  // 1. Limpar vinculações antigas dessa categoria
                  await db.delete('category_game', where: 'category_id = ?', whereArgs: [category['id']]);
                  
                  // 2. Inserir novas
                  for (int idToSave in selectedIds) {
                    await db.insert('category_game', {
                      'category_id': category['id'],
                      'game_id': idToSave
                    });
                  }
                  
                  Navigator.pop(context); // Fecha o dialog
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lista de indicados atualizada!"), 
                        backgroundColor: AppTheme.tgaGold
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}