// services/logo_upload_service.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class LogoUploadService {
  static final LogoUploadService _instance = LogoUploadService._internal();
  factory LogoUploadService() => _instance;
  LogoUploadService._internal();

  // Configurações de diretório
  static const String _logoFolderName = 'logos';
  static const String _defaultLogoFileName = 'logo-loja.png';

  /// Opção 1: Salvar na pasta do executável da aplicação
  Future<String?> uploadLogoToAppDirectory() async {
    try {
      // Selecionar arquivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      final selectedFile = File(result.files.single.path!);

      // Obter diretório do executável
      final executableDir = File(Platform.resolvedExecutable).parent;
      final logoDir = Directory(path.join(executableDir.path, _logoFolderName));

      // Criar diretório se não existir
      if (!await logoDir.exists()) {
        await logoDir.create(recursive: true);
      }

      // Caminho de destino
      final destinationPath = path.join(logoDir.path, _defaultLogoFileName);

      // Copiar arquivo
      await selectedFile.copy(destinationPath);

      if (kDebugMode) {
        print('Logo salva em: $destinationPath');
      }
      return destinationPath;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao fazer upload da logo: $e');
      }
      return null;
    }
  }

  /// Opção 2: Salvar em uma pasta específica do sistema
  Future<String?> uploadLogoToCustomDirectory(String customPath) async {
    try {
      // Selecionar arquivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      final selectedFile = File(result.files.single.path!);

      // Criar diretório customizado
      final logoDir = Directory(path.join(customPath, _logoFolderName));

      // Criar diretório se não existir
      if (!await logoDir.exists()) {
        await logoDir.create(recursive: true);
      }

      // Caminho de destino
      final destinationPath = path.join(logoDir.path, _defaultLogoFileName);

      // Copiar arquivo
      await selectedFile.copy(destinationPath);

      if (kDebugMode) {
        print('Logo salva em: $destinationPath');
      }
      return destinationPath;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao fazer upload da logo: $e');
      }
      return null;
    }
  }

  /// Opção 3: Salvar em pasta assets (para incluir no build)
  Future<String?> uploadLogoToAssets() async {
    try {
      // Selecionar arquivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      final selectedFile = File(result.files.single.path!);

      // Obter diretório do projeto (assumindo estrutura padrão Flutter)
      final currentDir = Directory.current;
      final assetsDir = Directory(
        path.join(currentDir.path, 'assets', 'images', 'custom'),
      );

      // Criar diretório se não existir
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }

      // Caminho de destino
      final destinationPath = path.join(assetsDir.path, _defaultLogoFileName);

      // Copiar arquivo
      await selectedFile.copy(destinationPath);

      if (kDebugMode) {
        print('Logo salva em assets: $destinationPath');
      }

      // Retornar path relativo para usar com AssetImage
      return 'assets/images/custom/$_defaultLogoFileName';
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao fazer upload da logo para assets: $e');
      }
      return null;
    }
  }

  /// Opção 4: Salvar em pasta específica do sistema (Windows/Linux/Mac)
  Future<String?> uploadLogoToSystemDirectory() async {
    try {
      // Selecionar arquivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      final selectedFile = File(result.files.single.path!);

      // Determinar pasta do sistema baseado na plataforma
      String systemPath;
      if (Platform.isWindows) {
        systemPath = path.join('C:', 'ProgramData', 'LojaApp', _logoFolderName);
      } else if (Platform.isLinux) {
        systemPath = path.join('/opt', 'loja-app', _logoFolderName);
      } else if (Platform.isMacOS) {
        systemPath = path.join('/Applications', 'LojaApp', _logoFolderName);
      } else {
        // Fallback para pasta do usuário
        systemPath = path.join(
          Platform.environment['HOME'] ?? '.',
          '.loja-app',
          _logoFolderName,
        );
      }

      final logoDir = Directory(systemPath);

      // Criar diretório se não existir
      if (!await logoDir.exists()) {
        await logoDir.create(recursive: true);
      }

      // Caminho de destino
      final destinationPath = path.join(logoDir.path, _defaultLogoFileName);

      // Copiar arquivo
      await selectedFile.copy(destinationPath);

      if (kDebugMode) {
        print('Logo salva em pasta do sistema: $destinationPath');
      }
      return destinationPath;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao fazer upload da logo para sistema: $e');
      }
      return null;
    }
  }

  /// Opção 5: Salvar com bytes (para controle total)
  Future<String?> uploadLogoWithBytes(String destinationDirectory) async {
    try {
      // Selecionar arquivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Importante para obter os bytes
      );

      if (result == null || result.files.single.bytes == null) {
        return null;
      }

      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      // Criar diretório de destino
      final logoDir = Directory(
        path.join(destinationDirectory, _logoFolderName),
      );

      if (!await logoDir.exists()) {
        await logoDir.create(recursive: true);
      }

      // Usar extensão original ou padrão
      final extension = path.extension(fileName).isNotEmpty
          ? path.extension(fileName)
          : '.png';

      final destinationPath = path.join(logoDir.path, 'logo-loja$extension');

      // Escrever bytes no arquivo
      final file = File(destinationPath);
      await file.writeAsBytes(fileBytes);

      if (kDebugMode) {
        print('Logo salva com bytes em: $destinationPath');
      }
      return destinationPath;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao fazer upload da logo com bytes: $e');
      }
      return null;
    }
  }

  /// Verificar se a logo existe no caminho
  Future<bool> logoExists(String logoPath) async {
    try {
      final file = File(logoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Remover logo
  Future<bool> removeLogo(String logoPath) async {
    try {
      final file = File(logoPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao remover logo: $e');
      }
      return false;
    }
  }

  /// Obter lista de logos disponíveis em um diretório
  Future<List<String>> getAvailableLogos(String directoryPath) async {
    try {
      final logoDir = Directory(path.join(directoryPath, _logoFolderName));

      if (!await logoDir.exists()) {
        return [];
      }

      final files = await logoDir.list().toList();
      final imageFiles = files
          .whereType<File>()
          .where((file) {
            final extension = path.extension(file.path).toLowerCase();
            return [
              '.png',
              '.jpg',
              '.jpeg',
              '.gif',
              '.bmp',
            ].contains(extension);
          })
          .map((file) => file.path)
          .toList();

      return imageFiles;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao listar logos: $e');
      }
      return [];
    }
  }
}
