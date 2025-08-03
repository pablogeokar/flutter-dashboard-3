import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints para diferentes tamanhos de tela
  static const double _smallScreenWidth = 1024; // 15-17 polegadas
  static const double _mediumScreenWidth = 1366; // 18-20 polegadas
  static const double _largeScreenWidth = 1920; // 21+ polegadas

  // Verificar o tamanho da tela
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < _smallScreenWidth;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _smallScreenWidth && width < _mediumScreenWidth;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= _largeScreenWidth;
  }

  // Obter fator de escala baseado no tamanho da tela
  static double getScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _smallScreenWidth) {
      return 0.8; // Reduzir em 20% para telas pequenas
    } else if (width < _mediumScreenWidth) {
      return 0.9; // Reduzir em 10% para telas médias
    } else {
      return 1.0; // Tamanho normal para telas grandes
    }
  }

  // Espaçamentos responsivos
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    return baseSpacing * getScaleFactor(context);
  }

  // Tamanhos de fonte responsivos
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    return baseFontSize * getScaleFactor(context);
  }

  // Padding responsivo
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double horizontal = 24.0,
    double vertical = 16.0,
  }) {
    final scale = getScaleFactor(context);
    return EdgeInsets.symmetric(
      horizontal: horizontal * scale,
      vertical: vertical * scale,
    );
  }

  // Margem responsiva
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    double all = 0.0,
    double? horizontal,
    double? vertical,
  }) {
    final scale = getScaleFactor(context);
    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: (horizontal ?? all) * scale,
        vertical: (vertical ?? all) * scale,
      );
    }
    return EdgeInsets.all(all * scale);
  }

  // Largura da sidebar responsiva
  static double getSidebarWidth(BuildContext context) {
    if (isSmallScreen(context)) {
      return 240; // Reduzir de 280 para 240
    } else if (isMediumScreen(context)) {
      return 260; // Reduzir de 280 para 260
    } else {
      return 280; // Manter tamanho original
    }
  }

  // Altura de elementos responsiva
  static double getResponsiveHeight(BuildContext context, double baseHeight) {
    return baseHeight * getScaleFactor(context);
  }

  // Border radius responsivo
  static double getResponsiveRadius(BuildContext context, double baseRadius) {
    return baseRadius * getScaleFactor(context);
  }

  // Icon size responsivo
  static double getResponsiveIconSize(
    BuildContext context,
    double baseIconSize,
  ) {
    return baseIconSize * getScaleFactor(context);
  }

  // Grid columns responsivo
  static int getResponsiveGridColumns(BuildContext context) {
    if (isSmallScreen(context)) {
      return 1; // Uma coluna para telas pequenas
    } else if (isMediumScreen(context)) {
      return 2; // Duas colunas para telas médias
    } else {
      return 3; // Três colunas para telas grandes
    }
  }

  // Card height responsivo
  static double getResponsiveCardHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 120;
    } else if (isMediumScreen(context)) {
      return 140;
    } else {
      return 160;
    }
  }

  // Table row height responsivo
  static double getResponsiveTableRowHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 48;
    } else if (isMediumScreen(context)) {
      return 52;
    } else {
      return 56;
    }
  }

  // Button height responsivo
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 36;
    } else if (isMediumScreen(context)) {
      return 40;
    } else {
      return 44;
    }
  }

  // Input field height responsivo
  static double getResponsiveInputHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 40;
    } else if (isMediumScreen(context)) {
      return 44;
    } else {
      return 48;
    }
  }
}
