import 'dart:ui'; // Para o Blur
import 'dart:math'; // Para as partículas
import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/tga_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // FocusNodes para o efeito de brilho
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _isAdmin = false;
  bool _isLoading = false;

  // Animações
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Setup da animação de entrada
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _entryController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    
    _entryController.forward();

    // Listeners para atualizar a borda dourada
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _register() async {
    // 1. Validação Básica
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      _showSnack("Preencha todos os campos", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    // Simular delay para UX (ver o loading)
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final user = User(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _isAdmin ? 0 : 1, // 0 = Admin, 1 = User
      );

      final db = await DbHelper().database;
      
      // Tenta inserir
      await db.insert('user', user.toMap());

      if (!mounted) return;
      
      _showSnack("Conta criada com sucesso!");
      
      // Espera o SnackBar aparecer antes de fechar
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context); // Volta pro Login

    } catch (e) {
      // Captura erro (ex: email duplicado se o banco tiver essa constraint)
      _showSnack("Erro ao criar conta. Tente outro email.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Seta de voltar branca
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // 1. Reutilizamos o Fundo de Partículas para consistência
            const Positioned.fill(child: AnimatedBackground()),

            // 2. Conteúdo
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Título
                        const Text(
                          "CRIAR CONTA",
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.tgaGold,
                            letterSpacing: 2.0,
                            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Junte-se à celebração dos melhores jogos",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        
                        const SizedBox(height: 30),

                        // Card de Vidro
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                              ),
                              child: Column(
                                children: [
                                  // Input Nome
                                  _buildTextField(
                                    controller: _nameController,
                                    focusNode: _nameFocus,
                                    label: "Nome Completo",
                                    icon: Icons.person_outline,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Input Email
                                  _buildTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    label: "Email",
                                    icon: Icons.email_outlined,
                                    inputType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),

                                  // Input Senha
                                  _buildTextField(
                                    controller: _passwordController,
                                    focusNode: _passFocus,
                                    label: "Senha",
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                  ),

                                  const SizedBox(height: 20),

                                  // Checkbox Estilizado
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: CheckboxListTile(
                                      activeColor: AppTheme.tgaGold,
                                      checkColor: Colors.black,
                                      title: const Text(
                                        "Conta de Administrador",
                                        style: TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                      subtitle: const Text(
                                        "Permite gerenciar categorias e jogos",
                                        style: TextStyle(color: Colors.white30, fontSize: 10),
                                      ),
                                      value: _isAdmin,
                                      onChanged: (val) => setState(() => _isAdmin = val!),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // Botão
                                  TgaButton(
                                    text: "FINALIZAR CADASTRO",
                                    icon: Icons.app_registration,
                                    isLoading: _isLoading,
                                    onPressed: _register,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Botão voltar texto simples
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Já tenho uma conta",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
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

  // Widget auxiliar de Input (Mesmo estilo do Login)
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    final isFocused = focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppTheme.tgaGold : Colors.white10,
          width: 1.5,
        ),
        boxShadow: isFocused 
            ? [BoxShadow(color: AppTheme.tgaGold.withOpacity(0.15), blurRadius: 8)] 
            : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        keyboardType: inputType,
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
}

// --- Background de Partículas (Mesmo do Login para evitar duplicidade de arquivo externo) ---
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
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(_random));
    }
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..addListener(() => setState(() {
        for (var p in _particles) {
          p.update();
          if (p.y < -0.1) p.reset(_random);
        }
      }))
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
          colors: [Color(0xFF202020), Color(0xFF000000)], // Um pouco mais claro que o login
        ),
      ),
      child: CustomPaint(painter: ParticlePainter(_particles)),
    );
  }
}

class Particle {
  late double x, y, size, speed, opacity;
  Particle(Random random) { reset(random); y = random.nextDouble(); }
  void reset(Random random) {
    x = random.nextDouble(); y = 1.2;
    size = random.nextDouble() * 3 + 1;
    speed = random.nextDouble() * 0.002 + 0.001;
    opacity = random.nextDouble() * 0.5 + 0.1;
  }
  void update() => y -= speed;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = Colors.white.withOpacity(p.opacity)..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}