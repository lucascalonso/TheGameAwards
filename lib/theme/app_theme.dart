import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de Cores inspirada no TGA
  static const Color gold = Color(0xFFC4A459); // Dourado da estatueta
  static const Color darkBackground = Color(0xFF0A0A0A); // Preto profundo
  static const Color surfaceColor = Color(0xFF1A1A1A); // Cinza para Cards
  static const Color accentPurple = Color(
    0xFF3D2C5E,
  ); // Roxo escuro para detalhes

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
        onPrimary: Colors.black,
      ),

      // Estilo da AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: gold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: gold),
      ),

      // Estilo dos Cards (Jogos e Categorias)
      cardTheme: CardThemeData(
        // Alterado de CardTheme para CardThemeData
        color: surfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),

      // Estilo dos Inputs (Formulários)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        labelStyle: const TextStyle(color: gold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
      ),

      // Estilo dos Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),

      // Estilo de Texto
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: gold, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }
}
