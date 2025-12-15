import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../widgets/base_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Para mostrar um feedback visual

  void _handleLogin() async {
    // Validação básica
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha email e senha"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // 1. A tela pede ao Provider para tentar logar passando strings
    bool success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    // 2. Se falhar, mostramos erro.
    // Se tiver sucesso, NÃO precisamos fazer nada, pois o main.dart
    // vai detectar a mudança de estado (auth.user != null) e trocar a tela automaticamente.
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email ou senha incorretos"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return BaseLayout(
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
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // Botão Entrar com Loading
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _handleLogin,
                      child: const Text("ENTRAR"),
                    ),

              const SizedBox(height: 20),

              // Botão Cadastrar
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

              // Botão Continuar sem Cadastro
              TextButton(
                onPressed: () {
                  auth.loginAsGuest();
                  // Novamente: main.dart cuidará da navegação
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
