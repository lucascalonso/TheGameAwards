import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Necessário para o efeito de blur (BackdropFilter)

import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../widgets/tga_button.dart'; // Importe o botão personalizado criado anteriormente
// import '../../widgets/base_layout.dart'; // Não vamos usar o BaseLayout aqui para ter controle total do fundo

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Preencha email e senha"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!success && mounted) {
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
    final theme = Theme.of(context);

    return Scaffold(
      // Estende o corpo atrás da AppBar para imersão total
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. FUNDO IMERSIVO
          // Se tiver uma imagem de fundo (ex: assets/bg_tga.jpg), use Image.asset com BoxFit.cover
          // Como não temos, faremos um gradiente sofisticado
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4), // O "holofote" vem de cima
                radius: 1.5,
                colors: [
                  Color(0xFF2A2A2A), // Cinza médio no centro
                  Color(0xFF000000), // Preto total nas bordas
                ],
              ),
            ),
          ),
          
          // Efeito de partículas ou textura (opcional, simulado com ruído ou opacidade)
          Container(color: Colors.black.withOpacity(0.3)),

          // 2. CONTEÚDO CENTRALIZADO
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ÍCONE GLOW (Brilhante)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.5),
                          blurRadius: 50,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 100,
                      color: theme.primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    "THE GAME AWARDS",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: 'Cinzel', // Se tiver importado, senão usa padrão
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 50),

                  // CARD COM EFEITO DE VIDRO (Glassmorphism)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Campo Email
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Campo Senha
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Senha",
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Botão LOGIN (Usando nosso Widget TgaButton)
                            TgaButton(
                              text: "ACESSAR SISTEMA",
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Ações Secundárias
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text(
                          "CRIAR CONTA",
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Text(
                        "|",
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                      TextButton(
                        onPressed: () {
                          auth.loginAsGuest();
                        },
                        child: const Text(
                          "VISITANTE",
                          style: TextStyle(
                            color: Colors.white70,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}