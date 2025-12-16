import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class CategoryDetail extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;

  const CategoryDetail({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  _CategoryDetailState createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  int? _currentVoteGameId;
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = await DbHelper().database;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 1. Carregar jogos da categoria (Mantendo sua lógica de JOIN)
      final gamesRes = await db.rawQuery(
        '''
        SELECT g.* FROM game g 
        JOIN category_game cg ON g.id = cg.game_id 
        WHERE cg.category_id = ?
        ''',
        [widget.categoryId],
      );

      // 2. Verificar se o usuário já votou (Mantendo tabela user_vote)
      if (auth.user != null) {
        final voteRes = await db.query(
          'user_vote',
          where: 'user_id = ? AND category_id = ?',
          whereArgs: [auth.user!.id, widget.categoryId],
        );
        if (voteRes.isNotEmpty) {
          setState(() {
            _currentVoteGameId = voteRes.first['vote_game_id'] as int;
          });
        }
      }

      setState(() {
        _games = gamesRes;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar dados: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVote(int gameId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Bloqueia convidados
    if (auth.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Faça login para votar!"),
          backgroundColor: AppTheme.tgaError,
        ),
      );
      return;
    }

    final db = await DbHelper().database;

    try {
      if (_currentVoteGameId == gameId) {
        // Lógica: Retirar voto (Toggle Off)
        await db.delete(
          'user_vote',
          where: 'user_id = ? AND category_id = ?',
          whereArgs: [auth.user!.id, widget.categoryId],
        );
        setState(() => _currentVoteGameId = null);
      } else if (_currentVoteGameId != null) {
        // Lógica: Mudar voto (Update)
        await db.update(
          'user_vote',
          {'vote_game_id': gameId},
          where: 'user_id = ? AND category_id = ?',
          whereArgs: [auth.user!.id, widget.categoryId],
        );
        setState(() => _currentVoteGameId = gameId);
      } else {
        // Lógica: Novo voto (Insert)
        await db.insert('user_vote', {
          'user_id': auth.user!.id,
          'category_id': widget.categoryId,
          'vote_game_id': gameId,
        });
        setState(() => _currentVoteGameId = gameId);
      }
    } catch (e) {
      print("Erro ao salvar voto: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao registrar voto.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.categoryTitle.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // Fundo com Gradiente Radial (Holofote)
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF2A2A2A), Color(0xFF000000)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.tgaGold))
            : _games.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum jogo indicado ainda.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 20), // Topo maior por causa da AppBar transparente
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 colunas
                      childAspectRatio: 0.7, // Formato Poster (Vertical)
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      final game = _games[index];
                      final isSelected = _currentVoteGameId == game['id'];
                      return _buildGamePoster(game, isSelected);
                    },
                  ),
      ),
    );
  }

  Widget _buildGamePoster(Map<String, dynamic> game, bool isSelected) {
    // Tenta pegar a imagem, se a coluna não existir, retorna null
    final String? imageUrl = game['image_url']; 

    return GestureDetector(
      onTap: () => _handleVote(game['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Borda Dourada se selecionado, transparente se não
          border: isSelected
              ? Border.all(color: AppTheme.tgaGold, width: 3)
              : Border.all(color: Colors.white12),
          // Sombra Dourada se selecionado
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.tgaGold.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)]
              : [const BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. IMAGEM DE FUNDO
              _buildImageContent(imageUrl),

              // 2. GRADIENTE ESCURO (Para o texto ficar legível)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                    stops: [0.5, 1.0],
                  ),
                ),
              ),

              // 3. OVERLAY DE SELEÇÃO ("VOTADO")
              if (isSelected)
                Container(
                  color: AppTheme.tgaGold.withOpacity(0.15),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.tgaGold, size: 40),
                        SizedBox(height: 4),
                        Text(
                          "VOTADO",
                          style: TextStyle(
                            color: AppTheme.tgaGold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

              // 4. TEXTOS (Título e Info)
              Positioned(
                bottom: 12,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game['name'] ?? 'Sem Nome', // Usando 'name' conforme seu DB antigo
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game['description'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(String? url) {
    if (url != null && url.isNotEmpty && url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videogame_asset, size: 40, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 8),
          Text(
            "THE GAME AWARDS",
            style: TextStyle(
              color: Colors.white.withOpacity(0.1),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}