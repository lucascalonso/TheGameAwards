import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'category_detail.dart';
import 'search_screen.dart'; // Para o botão de busca com filtros

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Future<List<Category>> _getActiveCategories() async {
    final db = await DbHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('category');
    // Filtra apenas as categorias ativas baseadas na data
    return maps
        .map((m) => Category.fromMap(m))
        .where((c) => c.isActive)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("TGA - VOTAÇÃO"),
        actions: [
          // Botão de busca/filtros conforme pedido no enunciado
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            ),
          ),
        ],
      ),
      // Menu lateral com a opção de Deslogar
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
                Navigator.pop(context); // Fecha o drawer
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Seção de Filtros (Pode ser um botão que leva à SearchScreen ou dropdowns rápidos)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Categorias Ativas",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  ),
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text("Filtros"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _getActiveCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.gold),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Nenhuma categoria ativa no momento."),
                  );
                }

                final categories = snapshot.data!;
                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          cat.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text("Votação até: ${cat.date}"),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.gold,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetail(
                                categoryId: cat.id!,
                                categoryTitle: cat.title,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
