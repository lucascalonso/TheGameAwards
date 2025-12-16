import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatar datas se necessário

import '../../database/db_helper.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart'; // Certifique-se que o AppTheme tem as cores definidas
import 'category_detail.dart';
import 'search_screen.dart';
// import '../../widgets/base_layout.dart'; // Vamos usar o Scaffold direto para controlar o design

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  
  // Lógica original mantida
  Future<List<Category>> _getActiveCategories() async {
    final db = await DbHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('category');
    List<Category> activeCategories = [];

    for (var m in maps) {
      try {
        Category c = Category.fromMap(m);
        // Lógica de data mantida conforme seu pedido (sempre adicionando para testes)
        activeCategories.add(c); 
      } catch (e) {
        print("Erro ao converter: $e");
      }
    }
    return activeCategories;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar transparente para dar destaque ao conteúdo
      appBar: AppBar(
        title: Text(
          "VOTAÇÃO",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppTheme.tgaGold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
      // Menu Lateral Estilizado
      drawer: _buildCustomDrawer(context, auth),
      
      // Corpo com Fundo Gradiente (leve)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
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
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildCategoryCard(context, categories[index]);
              },
            );
          },
        ),
      ),
    );
  }

  // Widget do Card de Categoria
  Widget _buildCategoryCard(BuildContext context, Category category) {
    return GestureDetector(
      onTap: () {
        if (category.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetail(
                categoryId: category.id!,
                categoryTitle: category.title,
              ),
            ),
          );
        }
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Fundo do card
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10), // Borda sutil
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Elemento Decorativo de Fundo (Troféu Gigante Opaco)
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.emoji_events,
                  size: 150,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
              
              // Barra lateral Dourada (Identidade Visual)
              Container(
                width: 6,
                color: AppTheme.tgaGold,
              ),

              // Conteúdo do Card
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge de "VOTAÇÃO ABERTA"
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.tgaGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.tgaGold.withOpacity(0.5)),
                      ),
                      child: Text(
                        "VOTAÇÃO ABERTA",
                        style: TextStyle(
                          color: AppTheme.tgaGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Título da Categoria
                    Text(
                      category.title.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Cinzel', // Ou a fonte padrão do tema
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Descrição curta
                    Text(
                      category.description ?? "Escolha o melhor nesta categoria.",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Ícone de Seta "Ir"
              const Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.tgaGold,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget do Estado Vazio
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            "Nenhuma categoria ativa no momento.",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // Drawer Customizado
  Widget _buildCustomDrawer(BuildContext context, AuthProvider auth) {
    return Drawer(
      backgroundColor: const Color(0xFF121212), // Fundo escuro
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF1E1E1E)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              border: Border(bottom: BorderSide(color: AppTheme.tgaGold, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.tgaGold,
                  child: const Icon(Icons.person, size: 35, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.isGuest ? "Visitante" : (auth.user?.name ?? "Usuário"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  auth.isGuest ? "Modo de visualização" : (auth.user?.email ?? ""),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.white70),
            title: const Text("Categorias", style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context), // Já estamos aqui
          ),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.tgaError),
            title: const Text("Sair da conta", style: TextStyle(color: AppTheme.tgaError)),
            onTap: () {
              Navigator.pop(context); // Fecha drawer
              auth.logout(); // O main.dart vai redirecionar para login
            },
          ),
        ],
      ),
    );
  }
}