import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/base_layout.dart';

class GameForm extends StatefulWidget {
  final Map<String, dynamic>? game;
  const GameForm({super.key, this.game});

  @override
  _GameFormState createState() => _GameFormState();
}

class _GameFormState extends State<GameForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      _nameController.text = widget.game!['name'];
      _descController.text = widget.game!['description'];
      _dateController.text = widget.game!['release_date'];
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final db = await DbHelper().database;

    final data = {
      'name': _nameController.text,
      'description': _descController.text,
      'release_date': _dateController.text,
      'user_id': auth.user!.id, // Associa ao admin logado
    };

    if (widget.game == null) {
      await db.insert('game', data);
    } else {
      await db.update(
        'game',
        data,
        where: 'id = ?',
        whereArgs: [widget.game!['id']],
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(
        title: Text(widget.game == null ? "Novo Jogo" : "Editar Jogo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nome"),
                validator: (v) => v!.isEmpty ? "Obrigatório" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Descrição"),
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: "Data Lançamento (AAAA-MM-DD)",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text("Salvar")),
            ],
          ),
        ),
      ),
    );
  }
}
