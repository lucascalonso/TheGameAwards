import 'dart:ui'; // Para o efeito de vidro (Blur)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_helper.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'category_detail.dart';
import 'search_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Controlador para animações globais da tela, se necessário
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // Lógica original de busca no DB
  Future<List<Category>> _getActiveCategories() async {
    final db = await DbHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('category');
    List<Category> activeCategories = [];

    for (var m in maps) {
      try {
        Category c = Category.fromMap(m);
        activeCategories.add(c); 
      } catch (e) {
        debugPrint("Erro ao converter: $e");
      }
    }
    return activeCategories;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // Permite que o corpo passe por trás da AppBar
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: const Text(
                "THE GAME AWARDS",
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: AppTheme.tgaGold,
                  fontSize: 18,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.black.withOpacity(0.3),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.tgaGold),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildCustomDrawer(context, auth),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F0F), Color(0xFF181818), Color(0xFF050505)],
          ),
        ),
        child: FutureBuilder<List<Category>>(
          future: _getActiveCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.tgaGold));
            } else if (snapshot.hasError) {
              return Center(child: Text("Erro: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final categories = snapshot.data!;
            
            // ListView com animação de entrada
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 30), // Topo maior para AppBar
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                // Animação stagger (um item entra depois do outro)
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)), // Delay baseado no index
                  curve: Curves.easeOutQuad,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)), // Vem de baixo para cima
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: CategoryCard(category: categories[index]),
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
          Icon(Icons.inbox, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text(
            "Nenhuma categoria ativa.",
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  // Drawer (Mantido clean, mas com ajustes de cor)
  Widget _buildCustomDrawer(BuildContext context, AuthProvider auth) {
    return Drawer(
      backgroundColor: const Color(0xFF101010),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey[900]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: const Border(bottom: BorderSide(color: AppTheme.tgaGold, width: 0.5)),
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppTheme.tgaGold,
                  child: Text(
                    auth.user?.name.isNotEmpty == true ? auth.user!.name[0].toUpperCase() : "G",
                    style: const TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  auth.isGuest ? "Visitante" : (auth.user?.name ?? "Usuário"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Cinzel',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  auth.isGuest ? "Apenas visualização" : (auth.user?.email ?? ""),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: const Icon(Icons.emoji_events, color: AppTheme.tgaGold),
            title: const Text("Votação", style: TextStyle(color: Colors.white, fontSize: 16)),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Divider(color: Colors.white10),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            leading: const Icon(Icons.logout, color: Color(0xFFCF6679)),
            title: const Text("Sair da conta", style: TextStyle(color: Color(0xFFCF6679), fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              auth.logout();
            },
          ),
        ],
      ),
    );
  }
}

// --- WIDGET DO CARD DE CATEGORIA (Extraído e melhorado) ---
class CategoryCard extends StatefulWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Controlador para o efeito "Pulsar" do badge "LIVE"
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.5,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (widget.category.id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetail(
                  categoryId: widget.category.id!,
                  categoryTitle: widget.category.title,
                ),
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 160,
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0), // Zoom leve
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: _isHovered 
                ? Border.all(color: AppTheme.tgaGold.withOpacity(0.5), width: 1.5)
                : Border.all(color: Colors.white10, width: 1),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? AppTheme.tgaGold.withOpacity(0.15) : Colors.black.withOpacity(0.5),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // 1. ÍCONE DECORATIVO GIGANTE (Fundo)
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      Icons.emoji_events,
                      size: 180,
                      color: Colors.white.withOpacity(0.03),
                    ),
                  ),
                ),
                
                // 2. GRADIENTE LATERAL (Para dar profundidade)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),

                // 3. BARRA DE DESTAQUE DOURADA
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isHovered ? 8 : 4,
                  height: double.infinity,
                  color: AppTheme.tgaGold,
                ),

                // 4. CONTEÚDO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge "VOTAÇÃO ABERTA" com ponto pulsante
                      Row(
                        children: [
                          FadeTransition(
                            opacity: _pulseController,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent, // Verde para indicar ativo
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 5)],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "VOTAÇÃO ABERTA",
                            style: TextStyle(
                              color: AppTheme.tgaGold.withOpacity(0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Título da Categoria
                      Text(
                        widget.category.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          height: 1.1,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Descrição
                      Text(
                        widget.category.description ?? "Clique para ver os indicados.",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // 5. BOTÃO "IR" (Seta)
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isHovered ? AppTheme.tgaGold : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: _isHovered ? Colors.black : Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}