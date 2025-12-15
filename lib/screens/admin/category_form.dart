import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/base_layout.dart';

class CategoryForm extends StatefulWidget {
  final Map<String, dynamic>?
  category; // Nulo se for criação, preenchido se for edição

  const CategoryForm({super.key, this.category});

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  List<Map<String, dynamic>> _allGames = [];
  List<int> _selectedGameIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carrega a lista de todos os jogos e os jogos já associados a esta categoria
  Future<void> _loadData() async {
    final db = await DbHelper().database;

    // Busca todos os jogos disponíveis no sistema
    final games = await db.query('game');

    if (widget.category != null) {
      _titleController.text = widget.category!['title'];
      _descriptionController.text = widget.category!['description'] ?? '';
      _dateController.text = widget.category!['date'];

      // Busca quais jogos já estão associados a esta categoria (tabela category_game)
      final associatedGames = await db.query(
        'category_game',
        where: 'category_id = ?',
        whereArgs: [widget.category!['id']],
      );

      _selectedGameIds = associatedGames
          .map((g) => g['game_id'] as int)
          .toList();
    }

    setState(() {
      _allGames = games;
    });
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final db = await DbHelper().database;

    Map<String, dynamic> categoryData = {
      'user_id': auth.user!.id,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'date': _dateController.text, // Formato AAAA-MM-DD
    };

    int categoryId;

    if (widget.category == null) {
      // Inserção de nova categoria
      categoryId = await db.insert('category', categoryData);
    } else {
      // Atualização de categoria existente
      categoryId = widget.category!['id'];
      await db.update(
        'category',
        categoryData,
        where: 'id = ?',
        whereArgs: [categoryId],
      );

      // Limpa associações antigas para reinserir as novas
      await db.delete(
        'category_game',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );
    }

    // Salva as associações de jogos na tabela category_game
    for (int gameId in _selectedGameIds) {
      await db.insert('category_game', {
        'category_id': categoryId,
        'game_id': gameId,
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(
        title: Text(
          widget.category == null ? "Nova Categoria" : "Editar Categoria",
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Título da Categoria (ex: Game of the Year)",
              ),
              validator: (val) => val!.isEmpty ? "Campo obrigatório" : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Descrição"),
              maxLines: 2,
            ),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: "Data de Validade (AAAA-MM-DD)",
              ),
              validator: (val) => val!.isEmpty ? "Campo obrigatório" : null,
            ),
            SizedBox(height: 20),
            Text(
              "Associar Jogos Concorrentes:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(),
            // Lista de jogos com Checkbox para associação
            ..._allGames.map((game) {
              return CheckboxListTile(
                title: Text(game['name']),
                subtitle: Text("ID do Jogo: ${game['id']}"),
                value: _selectedGameIds.contains(game['id']),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedGameIds.add(game['id']);
                    } else {
                      _selectedGameIds.remove(game['id']);
                    }
                  });
                },
              );
            }),
            if (_allGames.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Nenhum jogo cadastrado. Cadastre jogos primeiro.",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveCategory,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("SALVAR CATEGORIA E ASSOCIAÇÕES"),
            ),
          ],
        ),
      ),
    );
  }
}
