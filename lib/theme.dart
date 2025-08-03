import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/utils/responsive_utils.dart';

class AppTheme {
  // Cores principais
  //static const Color primary = Color(0xFF1C2D4A); // Azul profundo
  static const Color primary = Color(0xFFd35400);
  static const Color secondary = Color(0xFFD4AF37); // Dourado maçônico
  //static const Color primaryColor = Color(0xFF1C2D4A);
  static const Color primaryColor = Color(0xFFcc8e35);
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

  // Design System - Espaçamentos
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Design System - Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;

  // Design System - Elevation
  static const double elevationS = 1.0;
  static const double elevationM = 2.0;
  static const double elevationL = 4.0;
  static const double elevationXL = 8.0;

  // Design System - Tipografia
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Tipografia responsiva
  static TextStyle getResponsiveHeadline1(BuildContext context) {
    return headline1.copyWith(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 32),
    );
  }

  static TextStyle getResponsiveHeadline2(BuildContext context) {
    return headline2.copyWith(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
    );
  }

  static TextStyle getResponsiveHeadline3(BuildContext context) {
    return headline3.copyWith(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
    );
  }

  static TextStyle getResponsiveHeadline4(BuildContext context) {
    return headline4.copyWith(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
    );
  }

  static TextStyle getResponsiveBody1(BuildContext context) {
    return body1.copyWith(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
    );
  }

  static TextStyle getResponsiveBody2(BuildContext context) {
    return body2.copyWith(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
    );
  }

  static TextStyle getResponsiveCaption(BuildContext context) {
    return caption.copyWith(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
    );
  }

  static TextStyle getResponsiveButton(BuildContext context) {
    return button.copyWith(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
    );
  }

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

  // Tema claro melhorado
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: const Color(0xFFE2E8F0),
      surfaceContainerLowest: background,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: elevationS,
      scrolledUnderElevation: elevationM,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: elevationM,
      margin: const EdgeInsets.all(spacingM),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusL)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: elevationS,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusL),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusL),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusL),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    ),
  );

  // Tema escuro melhorado
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: const Color(0xFF1A1A1A),
      surfaceContainerLowest: const Color(0xFF0F0F0F),
      onSurface: textOnDark,
      onSurfaceVariant: Colors.grey,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: elevationS,
      scrolledUnderElevation: elevationM,
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: elevationM,
      margin: const EdgeInsets.all(spacingM),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusL)),
      ),
      color: const Color(0xFF1E1E1E),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: elevationS,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusL)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusL),
        borderSide: const BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusL),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusL),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
    ),
  );
}
