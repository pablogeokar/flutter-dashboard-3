import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais
  static const Color primary = Color(0xFF1C2D4A); // Azul profundo
  static const Color secondary = Color(0xFFD4AF37); // Dourado maçônico
  static const Color primaryColor = Color(0xFF1C2D4A);
  static const Color secondaryColor = Color(0xFFD4AF37);
  static const Color errorColor = Color(0xFFDC2626);

  // Texto
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnDark = Color(0xFFF2F4F8);

  // Backgrounds - Melhor contraste e hierarquia
  static const Color background = Color(
    0xFFF1F5F9,
  ); // Fundo principal mais neutro
  static const Color card = Color(0xFFFFFFFF); // Cartões brancos para contraste

  // Sidebar com mais contraste
  static const Color sidebarBackground = Color(
    0xFFFFFFFF,
  ); // Sidebar branca pura
  static const Color sidebarShadow = Color(0xFF1C2D4A); // Sombra mais definida

  // Surfaces com melhor hierarquia
  static const Color surface = Color(
    0xFFE2E8F0,
  ); // Botões e elementos interativos
  static const Color surfaceVariant = Color(0xFFCBD5E1);
  static const Color surfaceAccent = Color(0xFFDCECF9);

  // Cores de estado
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0284C7);

  // Cores específicas para navegação - Mais contrastadas
  static const Color navHover = Color(0xFFF8FAFC);
  static const Color navSelected = Color(
    0xFFE0F2FE,
  ); // Azul claro para selecionado
  static const Color navBorder = Color(0xFFE2E8F0); // Bordas mais visíveis

  // Cores para separação visual
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF374151);

  // Gradientes atualizados
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C2D4A), Color(0xFF2563EB)],
  );

  // Gradiente mais sutil para a sidebar
  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF), // Branco puro no topo
      Color(0xFFFAFBFC), // Levemente cinza no fundo
    ],
  );

  // Gradiente para o header da sidebar
  static const LinearGradient sidebarHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1C2D4A), // Azul escuro
      Color(0xFF2563EB), // Azul mais claro
    ],
  );

  // ThemeData claro
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: card,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: secondary,
        error: error,
        surface: surface,
      ),
    );
  }

  // ThemeData escuro
  static ThemeData get darkThemeData {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardColor: const Color(0xFF1E1E1E),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textOnDark),
        bodySmall: TextStyle(color: Colors.grey),
      ),
      colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
        secondary: secondary,
        error: error,
        surface: const Color(0xFF1A1A1A),
      ),
    );
  }

  // Tema claro
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: const Color(0xFFE2E8F0),
      surfaceContainerLowest: background,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 1,
      scrolledUnderElevation: 2,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  // Tema escuro
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: const Color(0xFF1A1A1A),
      surfaceContainerLowest: const Color(0xFF0F0F0F),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 1,
      scrolledUnderElevation: 2,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
