import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Para BackdropFilter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../widgets/tga_button.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Focus nodes para animar as bordas dos inputs
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _isLoading = false;

  // Controlador de Animação de Entrada
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configura animação de entrada
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _entryController, curve: Curves.easeIn);
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Começa um pouco abaixo
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    _entryController.forward(); // Inicia a animação

    // Listeners para atualizar a UI quando o foco mudar (para brilho dourado)
    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack("Preencha email e senha", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // Pequeno delay artificial para ver o loading (opcional, remove sensação de bug se for mt rápido)
    await Future.delayed(const Duration(milliseconds: 500)); 

    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (!success) {
        _showSnack("Email ou senha incorretos", isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? AppTheme.tgaError : AppTheme.tgaGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Ao tocar fora, fecha o teclado
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // 1. FUNDO ANIMADO (Partículas)
            const Positioned.fill(child: AnimatedBackground()),

            // 2. CONTEÚDO
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // --- LOGO ---
                        _buildLogo(),
                        
                        const SizedBox(height: 40),

                        // --- CARD DE VIDRO ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Blur mais forte
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03), // Quase transparente
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "BEM-VINDO DE VOLTA",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Campo Email
                                  _buildTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    label: "Email",
                                    icon: Icons.alternate_email,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Campo Senha
                                  _buildTextField(
                                    controller: _passwordController,
                                    focusNode: _passFocus,
                                    label: "Senha",
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                  ),
                                  
                                  const SizedBox(height: 30),

                                  // Botão LOGIN
                                  TgaButton(
                                    text: "ENTRAR",
                                    icon: Icons.login,
                                    isLoading: _isLoading,
                                    onPressed: _handleLogin,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // --- AÇÕES SECUNDÁRIAS ---
                        _buildFooterActions(context, auth),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.tgaGold.withOpacity(0.4),
                blurRadius: 60,
                spreadRadius: -5,
              )
            ],
            border: Border.all(color: AppTheme.tgaGold.withOpacity(0.3), width: 2),
          ),
          child: const Icon(Icons.emoji_events, size: 60, color: AppTheme.tgaGold),
        ),
        const SizedBox(height: 20),
        const Text(
          "THE GAME AWARDS",
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
            fontSize: 24,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4))],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    final isFocused = focusNode.hasFocus;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // Borda Dourada se focado, cinza transparente se não
          color: isFocused ? AppTheme.tgaGold : Colors.white10, 
          width: 1.5,
        ),
        boxShadow: isFocused 
            ? [BoxShadow(color: AppTheme.tgaGold.withOpacity(0.1), blurRadius: 8)] 
            : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        cursorColor: AppTheme.tgaGold,
        decoration: InputDecoration(
          icon: Icon(icon, color: isFocused ? AppTheme.tgaGold : Colors.white38),
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(color: isFocused ? AppTheme.tgaGold : Colors.white38),
        ),
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context, AuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
          child: const Text(
            "CRIAR CONTA",
            style: TextStyle(
              color: AppTheme.tgaGold,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Text("|", style: TextStyle(color: Colors.white.withOpacity(0.2))),
        TextButton(
          onPressed: () => auth.loginAsGuest(),
          child: const Text(
            "VISITANTE",
            style: TextStyle(
              color: Colors.white54,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

// --- CLASSE AUXILIAR: FUNDO ANIMADO COM PARTÍCULAS ---
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Inicializa 20 partículas
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(_random));
    }

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..addListener(() {
        setState(() {
          // Atualiza posição de cada partícula
          for (var p in _particles) {
            p.update();
            if (p.y < -0.1) { // Se saiu da tela por cima, recomeça em baixo
              p.reset(_random);
            }
          }
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.5,
          colors: [Color(0xFF2B2B2B), Color(0xFF000000)],
        ),
      ),
      child: CustomPaint(
        painter: ParticlePainter(_particles),
        child: Container(),
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;

  Particle(Random random) {
    reset(random);
    y = random.nextDouble(); // Posição inicial Y aleatória na primeira vez
  }

  void reset(Random random) {
    x = random.nextDouble();
    y = 1.2; // Começa abaixo da tela
    size = random.nextDouble() * 3 + 1; // Tamanho entre 1 e 4
    speed = random.nextDouble() * 0.002 + 0.001; // Velocidade lenta
    opacity = random.nextDouble() * 0.5 + 0.1; // Opacidade aleatória
  }

  void update() {
    y -= speed; // Sobe
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;

      // Desenha círculo (partícula)
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}