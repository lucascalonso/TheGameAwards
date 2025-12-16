import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Certifique-se de ter essa dependência no pubspec.yaml

class AppTheme {
  // --- PALETA DE CORES ORIGINAL ---
  static const Color gold = Color(0xFFC4A459); // Dourado da estatueta
  static const Color darkBackground = Color(0xFF0A0A0A); // Preto profundo
  static const Color surfaceColor = Color(0xFF1A1A1A); // Cinza para Cards
  static const Color accentPurple = Color(0xFF3D2C5E); // Roxo escuro para detalhes
  static const Color errorColor = Color(0xFFCF6679);   // Vermelho suave para erros

  // --- ALIASES (APELIDOS) PARA COMPATIBILIDADE ---
  // Isso faz o código novo (tgaGold) funcionar com suas cores originais (gold)
  static const Color tgaGold = gold;
  static const Color tgaBackground = darkBackground;
  static const Color tgaSurface = surfaceColor;
  static const Color tgaError = errorColor;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: gold,
      scaffoldBackgroundColor: darkBackground,

      // Esquema de cores global
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: gold,
        surface: surfaceColor,
        background: darkBackground,
        onPrimary: Colors.black,
        error: errorColor,
      ),

      // Tipografia (Adicionando Google Fonts ao seu tema)
      // Se der erro aqui, verifique se adicionou 'google_fonts' no pubspec.yaml
      textTheme: GoogleFonts.montserratTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: gold, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),

      // Estilo da AppBar (Mantendo o seu estilo original)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // Mudei para transparent para ficar moderno
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: gold,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0, // Aumentei um pouco o espaçamento (cinematográfico)
          fontFamily: 'Cinzel', // Se não tiver a fonte, ele usa a padrão
        ),
        iconTheme: IconThemeData(color: gold),
      ),

      // Estilo dos Cards (Mantendo o seu estilo original)
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 8, // Aumentei um pouco a sombra
        shadowColor: Colors.black54,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),

      // Estilo dos Inputs (Mantendo o seu estilo original)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        labelStyle: const TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // Removi a borda padrão para ficar mais limpo
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        prefixIconColor: gold, // Adicionei cor para os ícones dentro do input
      ),

      // Estilo dos Botões (Mantendo o seu estilo original)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.montserrat( // Aplicando fonte no botão
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            letterSpacing: 1.0,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 5,
        ),
      ),
    );
  }
}