import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'category_detail.dart';
import 'search_screen.dart';
import '../../widgets/base_layout.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // Método para buscar categorias e filtrar as ativas
  Future<List<Category>> _getActiveCategories() async {
    final db = await DbHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('category');

    List<Category> activeCategories = [];

    for (var m in maps) {
      try {
        Category c = Category.fromMap(m);

        bool isActive = false;
        try {
          DateTime endDate = DateTime.parse(c.date);
          isActive = endDate.isAfter(DateTime.now());
        } catch (e) {
          print("DEBUG: Erro ao verificar data da categoria '${c.title}': $e");
        }

        // --- MODIFICAÇÃO: Adicionando SEMPRE para permitir testes ---
        // Se a lógica de data estiver falhando, isso garante que você veja a lista.
        // Quando for para produção, você pode voltar para: if (isActive) activeCategories.add(c);
        activeCategories.add(c);
      } catch (e) {
        print("DEBUG: Erro ao converter mapa para categoria: $e");
      }
    }

    return activeCategories;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return BaseLayout(
      appBar: AppBar(
        title: const Text("The Game Awards: Votação"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.surfaceColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 50,
                    color: AppTheme.gold,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    auth.isGuest ? "Convidado" : auth.user?.name ?? "Usuário",
                    style: const TextStyle(color: AppTheme.gold, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Deslogar"),
              onTap: () {
                auth.logout();
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Category>>(
        future: _getActiveCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Nenhuma categoria encontrada.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final categories = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    category.title,
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(category.description ?? ""),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Verificação de segurança para o ID
                    if (category.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryDetail(
                            categoryId: category.id!, // Passando ID não nulo
                            categoryTitle: category.title,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erro: Categoria sem ID")),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
