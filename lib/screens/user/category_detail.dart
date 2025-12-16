import 'dart:ui'; // Necessário para o efeito de vidro (Blur)
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

  // Controlador de scroll para efeitos visuais se necessário no futuro
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = await DbHelper().database;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final gamesRes = await db.rawQuery(
        '''
        SELECT g.* FROM game g 
        JOIN category_game cg ON g.id = cg.game_id 
        WHERE cg.category_id = ?
        ''',
        [widget.categoryId],
      );

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
      debugPrint("Erro ao carregar dados: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVote(int gameId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Faça login para votar!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final db = await DbHelper().database;

    try {
      bool isRemovingVote = (_currentVoteGameId == gameId);

      if (isRemovingVote) {
        // Remover voto
        await db.delete(
          'user_vote',
          where: 'user_id = ? AND category_id = ?',
          whereArgs: [auth.user!.id, widget.categoryId],
        );
        setState(() => _currentVoteGameId = null);
      } else {
        // Atualizar ou Inserir novo voto
        if (_currentVoteGameId != null) {
          await db.update(
            'user_vote',
            {'vote_game_id': gameId},
            where: 'user_id = ? AND category_id = ?',
            whereArgs: [auth.user!.id, widget.categoryId],
          );
        } else {
          await db.insert('user_vote', {
            'user_id': auth.user!.id,
            'category_id': widget.categoryId,
            'vote_game_id': gameId,
          });
        }
        setState(() => _currentVoteGameId = gameId);

        // Feedback visual de sucesso
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Voto registrado com sucesso!"),
            backgroundColor: AppTheme.tgaGold,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint("Erro ao salvar voto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // AppBar com efeito "Glassmorphism" (Vidro fosco)
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: Text(
                widget.categoryTitle.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 16,
                  color: AppTheme.tgaGold, // Dourado no título
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.black.withOpacity(
                0.4,
              ), // Semi-transparente
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
        // Fundo sofisticado
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF000000)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.tgaGold),
              )
            : _games.isEmpty
            ? _buildEmptyState()
            : LayoutBuilder(
                builder: (context, constraints) {
                  // LÓGICA DE RESPONSIVIDADE
                  // Define quantas colunas baseado na largura da tela
                  int crossAxisCount = 2; // Celular (padrão)
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 5; // Desktop Grande
                  } else if (constraints.maxWidth > 900) {
                    crossAxisCount = 4; // Desktop/Laptop
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 3; // Tablet
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 30),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.58, // Proporção Poster
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      final game = _games[index];
                      final isSelected = _currentVoteGameId == game['id'];

                      return GameCard(
                        game: game,
                        isSelected: isSelected,
                        onTap: () => _handleVote(game['id']),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_esports,
            size: 60,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            "Nenhum jogo indicado nesta categoria.",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET DO CARD INTERATIVO ---
class GameCard extends StatefulWidget {
  final Map<String, dynamic> game;
  final bool isSelected;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  // Adicionei animação de escala para ficar suave
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent details) {
    setState(() => _isHovered = true);
    _controller.forward(); // Inicia o zoom
  }

  void _onExit(PointerEvent details) {
    setState(() => _isHovered = false);
    _controller.reverse(); // Volta ao tamanho normal
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = widget.game['image_url'];
    final String description =
        widget.game['description'] ?? 'Sem descrição disponível.';

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation, // Aplica o zoom suave
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // Borda: Se selecionado = Dourado. Se Hover = Branco fraco. Se normal = Transparente
              border: widget.isSelected
                  ? Border.all(color: AppTheme.tgaGold, width: 3)
                  : _isHovered
                  ? Border.all(color: Colors.white24, width: 1)
                  : Border.all(color: Colors.transparent),
              boxShadow: [
                // Sombra dinâmica
                BoxShadow(
                  color: widget.isSelected
                      ? AppTheme.tgaGold.withOpacity(0.3)
                      : Colors.black.withOpacity(0.5),
                  blurRadius: _isHovered ? 20 : 10, // Sombra cresce no hover
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. IMAGEM
                  _buildImageContent(imageUrl),

                  // 2. GRADIENTE ESCURO FIXO (Base)
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

                  // 3. CAMADA DE OVERLAY (Hover - Sinopse)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Container(
                      color: Colors.black.withOpacity(
                        0.85,
                      ), // Fundo escuro fosco
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "SINOPSE",
                            style: TextStyle(
                              color: AppTheme.tgaGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFE0E0E0),
                                  fontSize: 11,
                                  height: 1.4, // Melhor leitura
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "CLIQUE PARA VOTAR",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. CHECK DE "VOTADO" (Superior Direito)
                  if (widget.isSelected)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.tgaGold,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // 5. INFORMAÇÕES DO JOGO (Visível se NÃO estiver no hover)
                  if (!_isHovered)
                    Positioned(
                      bottom: 12,
                      left: 8,
                      right: 8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.game['name'] ?? 'Sem Nome',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.isSelected
                                  ? AppTheme.tgaGold
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 30,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 4),
          Text(
            "TGA",
            style: TextStyle(
              color: Colors.white.withOpacity(0.1),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
