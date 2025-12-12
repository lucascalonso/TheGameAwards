import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/db_helper.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'register_screen.dart'; // Import necessário
import '../user/user_dashboard.dart'; // Import necessário
import '../admin/admin_dashboard.dart'; // Import necessário

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Tenta buscar o usuário no banco
    var userMap = await DbHelper().login(
      _emailController.text,
      _passwordController.text,
    );

    if (userMap != null) {
      User user = User.fromMap(userMap);
      auth.login(user); // Atualiza o estado global para logado

      // A navegação automática acontece no main.dart via Consumer,
      // mas se você preferir forçar aqui:
      if (user.role == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserDashboard()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email ou senha incorretos"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("The Game Awards")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 80,
                color: Color(0xFFC4A459),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // Botão Entrar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _handleLogin,
                child: const Text("ENTRAR"),
              ),

              const SizedBox(height: 20),

              // Botão Cadastrar - AGORA FUNCIONAL
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: const Text(
                  "Criar nova conta",
                  style: TextStyle(color: Color(0xFFC4A459)),
                ),
              ),

              // Botão Continuar sem Cadastro - AGORA FUNCIONAL
              TextButton(
                onPressed: () {
                  auth.loginAsGuest(); // Define o estado como convidado
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserDashboard()),
                  );
                },
                child: const Text(
                  "Continuar sem cadastro",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
