import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/services/excel_import_service.dart';

class ExcelImportModal extends StatefulWidget {
  const ExcelImportModal({super.key});

  @override
  State<ExcelImportModal> createState() => _ExcelImportModalState();
}

class _ExcelImportModalState extends State<ExcelImportModal> {
  final ExcelImportService _importService = ExcelImportService();
  bool _isImporting = false;
  bool _showResult = false;
  ImportResult? _result;

  void _mostrarMensagem(String mensagem, Color cor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: cor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _importarArquivo() async {
    setState(() {
      _isImporting = true;
      _showResult = false;
    });

    try {
      final result = await _importService.selecionarEImportarArquivo();

      if (result != null) {
        setState(() {
          _result = result;
          _showResult = true;
        });

        if (result.temSucessos) {
          _mostrarMensagem(
            'Importação concluída! ${result.sucessos} membros importados.',
            const Color(0xFF4CAF50),
          );
        }
      } else {
        _mostrarMensagem(
          'Nenhum arquivo selecionado.',
          const Color(0xFFFF9800),
        );
      }
    } catch (e) {
      _mostrarMensagem('Erro na importação: $e', const Color(0xFFE53E3E));
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _gerarModelo() async {
    try {
      await _importService.gerarModeloPlanilha();
      _mostrarMensagem(
        'Modelo de planilha gerado com sucesso!',
        const Color(0xFF4CAF50),
      );
    } catch (e) {
      _mostrarMensagem('Erro ao gerar modelo: $e', const Color(0xFFE53E3E));
    }
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF424242)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Instruções para Importação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Formato da Planilha:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• A primeira linha deve conter os cabeçalhos\n'
            '• Colunas aceitas: Nome*, Email, Telefone, Status, Observações\n'
            '• Nome é obrigatório (marcado com *)\n'
            '• Status aceitos: ativo, inativo, pausado (padrão: ativo)\n'
            '• Formatos aceitos: .xlsx, .xls',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[300],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSummary() {
    if (!_showResult || _result == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: _result!.temErros
            ? const Color(0xFFE53E3E).withValues(alpha: 0.1)
            : const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _result!.temErros
              ? const Color(0xFFE53E3E).withValues(alpha: 0.3)
              : const Color(0xFF4CAF50).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _result!.temErros ? Icons.warning : Icons.check_circle,
                color: _result!.temErros
                    ? const Color(0xFFE53E3E)
                    : const Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Resultado da Importação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _result!.temErros
                      ? const Color(0xFFE53E3E)
                      : const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow('Total de linhas:', '${_result!.totalLinhas}'),
          _buildStatRow(
            'Sucessos:',
            '${_result!.sucessos}',
            color: const Color(0xFF4CAF50),
          ),
          if (_result!.erros > 0)
            _buildStatRow(
              'Erros:',
              '${_result!.erros}',
              color: const Color(0xFFE53E3E),
            ),

          if (_result!.mensagensErro.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Detalhes dos Erros:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _result!.mensagensErro.map((erro) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $erro',
                        style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[300])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF424242)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Importar Membros do Excel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Instruções
            _buildInstructions(),

            // Botões de ação
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isImporting ? null : _gerarModelo,
                    icon: const Icon(Icons.download),
                    label: const Text('Baixar Modelo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00BCD4),
                      side: const BorderSide(color: Color(0xFF00BCD4)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isImporting ? null : _importarArquivo,
                    icon: _isImporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.file_upload),
                    label: Text(
                      _isImporting ? 'Importando...' : 'Selecionar Arquivo',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Resultado
            _buildResultSummary(),

            // Botões do rodapé
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _showResult && _result?.temSucessos == true
                      ? () => Navigator.pop(context, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Concluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
