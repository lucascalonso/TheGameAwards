import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/user_model.dart';
import '../../widgets/base_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;

  void _register() async {
    final user = User(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _isAdmin ? 0 : 1,
    );

    final db = await DbHelper().database;
    await db.insert('user', user.toMap());
    Navigator.pop(context); // Volta para o login
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: AppBar(title: Text("Cadastro de Usuário")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            CheckboxListTile(
              title: Text("Sou Administrador"),
              value: _isAdmin,
              onChanged: (val) => setState(() => _isAdmin = val!),
            ),
            ElevatedButton(onPressed: _register, child: Text("Cadastrar")),
          ],
        ),
      ),
    );
  }
}
