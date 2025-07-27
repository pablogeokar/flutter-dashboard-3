import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dashboard_3/models/membro.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';

/// Resultado da importação
class ImportResult {
  final int totalLinhas;
  final int sucessos;
  final int erros;
  final List<String> mensagensErro;
  final List<Membro> membrosImportados;

  ImportResult({
    required this.totalLinhas,
    required this.sucessos,
    required this.erros,
    required this.mensagensErro,
    required this.membrosImportados,
  });

  bool get temErros => erros > 0;
  bool get temSucessos => sucessos > 0;
}

class ExcelImportService {
  static final ExcelImportService _instance = ExcelImportService._internal();
  factory ExcelImportService() => _instance;
  ExcelImportService._internal();

  final DatabaseService _db = DatabaseService();

  /// Seleciona e importa arquivo Excel
  Future<ImportResult?> selecionarEImportarArquivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return await importarArquivoExcel(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao selecionar arquivo: $e');
    }
  }

  /// Importa membros de um arquivo Excel
  Future<ImportResult> importarArquivoExcel(String caminhoArquivo) async {
    try {
      var bytes = File(caminhoArquivo).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Pega a primeira planilha
      var tabela = excel.tables.keys.first;
      var planilha = excel.tables[tabela];

      if (planilha == null || planilha.rows.isEmpty) {
        throw Exception('Planilha vazia ou não encontrada');
      }

      return await _processarPlanilha(planilha);
    } catch (e) {
      throw Exception('Erro ao processar arquivo Excel: $e');
    }
  }

  /// Processa as linhas da planilha
  Future<ImportResult> _processarPlanilha(Sheet planilha) async {
    List<String> mensagensErro = [];
    List<Membro> membrosImportados = [];
    int sucessos = 0;
    int erros = 0;

    // Assume que a primeira linha são os cabeçalhos
    var linhas = planilha.rows;
    if (linhas.isEmpty) {
      throw Exception('Planilha não contém dados');
    }

    // Mapeia os índices das colunas baseado no cabeçalho
    Map<String, int> colunas = _mapearColunas(linhas.first);

    // Processa cada linha (pula o cabeçalho)
    for (int i = 1; i < linhas.length; i++) {
      try {
        var linha = linhas[i];

        // Pula linhas vazias
        if (_linhaVazia(linha)) continue;

        var membro = _criarMembroDaLinha(linha, colunas, i + 1);

        if (membro != null) {
          // Verifica se já existe um membro com o mesmo email (se fornecido)
          if (membro.email != null && membro.email!.isNotEmpty) {
            bool emailExiste = await _db.existeEmailMembro(membro.email!);
            if (emailExiste) {
              mensagensErro.add(
                'Linha ${i + 1}: Email ${membro.email} já existe no sistema',
              );
              erros++;
              continue;
            }
          }

          // Insere o membro no banco
          int id = await _db.insertMembro(membro);
          membro = Membro(
            id: id,
            nome: membro.nome,
            email: membro.email,
            telefone: membro.telefone,
            status: membro.status,
            observacoes: membro.observacoes,
          );

          membrosImportados.add(membro);
          sucessos++;
        }
      } catch (e) {
        mensagensErro.add('Linha ${i + 1}: $e');
        erros++;
      }
    }

    return ImportResult(
      totalLinhas: linhas.length - 1, // Exclui cabeçalho
      sucessos: sucessos,
      erros: erros,
      mensagensErro: mensagensErro,
      membrosImportados: membrosImportados,
    );
  }

  /// Mapeia as colunas baseado no cabeçalho
  Map<String, int> _mapearColunas(List<Data?> cabecalho) {
    Map<String, int> colunas = {};

    for (int i = 0; i < cabecalho.length; i++) {
      var celula = cabecalho[i];
      if (celula?.value != null) {
        String coluna = celula!.value.toString().toLowerCase().trim();

        // Mapeia possíveis variações dos nomes das colunas
        if (coluna.contains('nome')) {
          colunas['nome'] = i;
        } else if (coluna.contains('email') || coluna.contains('e-mail')) {
          colunas['email'] = i;
        } else if (coluna.contains('telefone') ||
            coluna.contains('fone') ||
            coluna.contains('celular')) {
          colunas['telefone'] = i;
        } else if (coluna.contains('status') || coluna.contains('situação')) {
          colunas['status'] = i;
        } else if (coluna.contains('observação') ||
            coluna.contains('observacao') ||
            coluna.contains('obs')) {
          colunas['observacoes'] = i;
        }
      }
    }

    return colunas;
  }

  /// Verifica se a linha está vazia
  bool _linhaVazia(List<Data?> linha) {
    return linha.every(
      (celula) =>
          celula?.value == null || celula!.value.toString().trim().isEmpty,
    );
  }

  /// Cria um objeto Membro a partir de uma linha da planilha
  Membro? _criarMembroDaLinha(
    List<Data?> linha,
    Map<String, int> colunas,
    int numeroLinha,
  ) {
    // Nome é obrigatório
    if (!colunas.containsKey('nome')) {
      throw Exception('Coluna "Nome" não encontrada no cabeçalho');
    }

    var nomeIndex = colunas['nome']!;
    if (nomeIndex >= linha.length || linha[nomeIndex]?.value == null) {
      throw Exception('Nome é obrigatório');
    }

    String nome = linha[nomeIndex]!.value.toString().trim();
    if (nome.isEmpty) {
      throw Exception('Nome não pode estar vazio');
    }

    // Campos opcionais
    String? email;
    if (colunas.containsKey('email') &&
        colunas['email']! < linha.length &&
        linha[colunas['email']!]?.value != null) {
      email = linha[colunas['email']!]!.value.toString().trim();
      if (email.isEmpty) email = null;

      // Validação básica de email
      if (email != null && !_validarEmail(email)) {
        throw Exception('Email inválido: $email');
      }
    }

    String? telefone;
    if (colunas.containsKey('telefone') &&
        colunas['telefone']! < linha.length &&
        linha[colunas['telefone']!]?.value != null) {
      telefone = linha[colunas['telefone']!]!.value.toString().trim();
      if (telefone.isEmpty) telefone = null;
    }

    String status = 'ativo'; // Status padrão
    if (colunas.containsKey('status') &&
        colunas['status']! < linha.length &&
        linha[colunas['status']!]?.value != null) {
      String statusTemp = linha[colunas['status']!]!.value
          .toString()
          .toLowerCase()
          .trim();
      if (['ativo', 'inativo', 'pausado'].contains(statusTemp)) {
        status = statusTemp;
      }
    }

    String? observacoes;
    if (colunas.containsKey('observacoes') &&
        colunas['observacoes']! < linha.length &&
        linha[colunas['observacoes']!]?.value != null) {
      observacoes = linha[colunas['observacoes']!]!.value.toString().trim();
      if (observacoes.isEmpty) observacoes = null;
    }

    return Membro(
      nome: nome,
      email: email,
      telefone: telefone,
      status: status,
      observacoes: observacoes,
    );
  }

  /// Validação básica de email
  bool _validarEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Gera um modelo de planilha Excel para download
  Future<String> gerarModeloPlanilha() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Modelo_Membros'];

    // Adiciona cabeçalhos
    sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue(
      "Nome",
    );
    sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue(
      "Email",
    );
    sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue(
      "Telefone",
    );
    sheetObject.cell(CellIndex.indexByString("D1")).value = TextCellValue(
      "Status",
    );
    sheetObject.cell(CellIndex.indexByString("E1")).value = TextCellValue(
      "Observações",
    );

    // Adiciona exemplos
    sheetObject.cell(CellIndex.indexByString("A2")).value = TextCellValue(
      "PABLO GEORGE CARDOSO CAMPOS BORGES",
    );
    sheetObject.cell(CellIndex.indexByString("B2")).value = TextCellValue(
      "pablogeokar@gmail.com",
    );
    sheetObject.cell(CellIndex.indexByString("C2")).value = TextCellValue(
      "(75) 99999-9999",
    );
    sheetObject.cell(CellIndex.indexByString("D2")).value = TextCellValue(
      "ativo",
    );
    sheetObject.cell(CellIndex.indexByString("E2")).value = TextCellValue(
      "Obreiro nota mil",
    );

    // Remove a planilha padrão
    excel.delete('Sheet1');

    // Salva o arquivo
    var bytes = excel.save();
    if (bytes != null) {
      String path = 'modelo_importacao_membros.xlsx';
      File(path).writeAsBytesSync(bytes);
      return path;
    }

    throw Exception('Erro ao gerar modelo de planilha');
  }
}
