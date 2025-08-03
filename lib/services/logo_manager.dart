// services/logo_manager.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class LogoManager {
  static final LogoManager _instance = LogoManager._internal();
  factory LogoManager() => _instance;
  LogoManager._internal();

  // ValueNotifier para notificar mudanças na logo
  final ValueNotifier<String?> logoPathNotifier = ValueNotifier<String?>(null);

  // Atualiza o caminho da logo e notifica todos os ouvintes
  void updateLogoPath(String? newPath) {
    logoPathNotifier.value = newPath;
  }

  // Obtém o caminho atual da logo
  String? get currentLogoPath => logoPathNotifier.value;

  // Widget que exibe a logo atual (reutilizável)
  Widget buildLogoWidget({
    double width = 120,
    double height = 120,
    BoxFit fit = BoxFit.contain,
  }) {
    return ValueListenableBuilder<String?>(
      valueListenable: logoPathNotifier,
      builder: (context, logoPath, child) {
        return _buildLogoImage(
          logoPath: logoPath,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }

  Widget _buildLogoImage({
    String? logoPath,
    required double width,
    required double height,
    required BoxFit fit,
  }) {
    // Primeiro, verificar se há um logo personalizado
    if (logoPath != null && logoPath.isNotEmpty) {
      final logoFile = File(logoPath);
      if (logoFile.existsSync()) {
        return Image.file(
          logoFile,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              print('Erro ao carregar imagem personalizada: $error');
            }
            return _getDefaultLogo(width, height, fit);
          },
        );
      }
    }

    // Usar logo padrão
    return _getDefaultLogo(width, height, fit);
  }

  Widget _getDefaultLogo(double width, double height, BoxFit fit) {
    return Image.asset(
      'assets/images/logo-loja.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          print('Erro ao carregar logo padrão: $error');
        }
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.business, size: width * 0.5, color: Colors.grey),
        );
      },
    );
  }

  // Limpa os recursos
  void dispose() {
    logoPathNotifier.dispose();
  }
}
