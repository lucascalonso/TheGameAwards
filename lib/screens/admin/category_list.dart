import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'category_form.dart';
import '../../widgets/base_layout.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = await _dbHelper.database;
    final list = await db.query('category');
    setState(() => _categories = list);
  }

  Future<void> _deleteCategory(int id) async {
    await _dbHelper.deleteCategory(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(title: const Text("Gerenciar Categorias")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryForm()),
          );
          _loadCategories();
        },
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return ListTile(
            title: Text(cat['title']),
            subtitle: Text("Validade: ${cat['date']}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCategory(cat['id']),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryForm(category: cat),
                ),
              );
              _loadCategories();
            },
          );
        },
      ),
    );
  }
}
