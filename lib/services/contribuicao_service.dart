import 'package:flutter_dashboard_3/models/contribuicao.dart';
import 'package:flutter_dashboard_3/database/repositories/membro_repository.dart';
import 'package:flutter_dashboard_3/database/repositories/contribuicao_repository.dart';
import 'package:flutter_dashboard_3/database/repositories/configuracao_repository.dart';

class ContribuicaoService {
  final MembroRepository _membroRepository = MembroRepository();
  final ContribuicaoRepository _contribuicaoRepository =
      ContribuicaoRepository();
  final ConfiguracaoRepository _configuracaoRepository =
      ConfiguracaoRepository();

  /// Gera contribuições mensais para todos os membros ativos
  Future<Map<String, dynamic>> gerarContribuicoesMensais({
    int? mesReferencia,
    int? anoReferencia,
  }) async {
    final agora = DateTime.now();
    final mes = mesReferencia ?? agora.month;
    final ano = anoReferencia ?? agora.year;

    // Buscar membros ativos
    final membrosAtivos = await _membroRepository.getByStatus('ativo');

    if (membrosAtivos.isEmpty) {
      return {
        'sucesso': false,
        'mensagem': 'Nenhum membro ativo encontrado',
        'geradas': 0,
        'existentes': 0,
      };
    }

    // Obter valor da contribuição
    final valorContribuicao = await _configuracaoRepository
        .getValorContribuicaoMensal();

    int geradas = 0;
    int existentes = 0;

    for (var membro in membrosAtivos) {
      // Verificar se já existe contribuição para este membro neste período
      final contribuicoesExistentes = await _contribuicaoRepository.get(
        membroId: membro.id!,
        mesReferencia: mes,
        anoReferencia: ano,
      );

      if (contribuicoesExistentes.isEmpty) {
        final novaContribuicao = Contribuicao(
          membroId: membro.id!,
          valor: valorContribuicao,
          mesReferencia: mes,
          anoReferencia: ano,
          status: 'pendente',
          dataGeracao: DateTime.now(),
        );

        await _contribuicaoRepository.insert(novaContribuicao);
        geradas++;
      } else {
        existentes++;
      }
    }

    return {
      'sucesso': true,
      'mensagem': 'Contribuições geradas com sucesso',
      'geradas': geradas,
      'existentes': existentes,
      'total_membros': membrosAtivos.length,
    };
  }

  /// Marcar contribuição como paga
  Future<bool> marcarContribuicaoPaga(
    int contribuicaoId, {
    String? observacoes,
  }) async {
    try {
      final contribuicao = await _contribuicaoRepository.getById(
        contribuicaoId,
      );
      if (contribuicao == null) return false;

      final contribuicaoAtualizada = contribuicao.copyWith(
        status: 'pago',
        dataPagamento: DateTime.now(),
        observacoes: observacoes,
      );

      final resultado = await _contribuicaoRepository.update(
        contribuicaoAtualizada,
      );
      return resultado > 0;
    } catch (e) {
      return false;
    }
  }

  /// Cancelar contribuição
  Future<bool> cancelarContribuicao(
    int contribuicaoId, {
    String? motivoCancelamento,
  }) async {
    try {
      final contribuicao = await _contribuicaoRepository.getById(
        contribuicaoId,
      );
      if (contribuicao == null) return false;

      final contribuicaoAtualizada = contribuicao.copyWith(
        status: 'cancelado',
        observacoes: motivoCancelamento,
      );

      final resultado = await _contribuicaoRepository.update(
        contribuicaoAtualizada,
      );
      return resultado > 0;
    } catch (e) {
      return false;
    }
  }
}
