import 'package:flutter_dashboard_3/models/membro.dart';
import 'package:flutter_dashboard_3/models/configuracao.dart';
import 'package:flutter_dashboard_3/models/contribuicao.dart';
import 'package:flutter_dashboard_3/services/contribuicao_service.dart';
import 'package:flutter_dashboard_3/database/repositories/membro_repository.dart';
import 'package:flutter_dashboard_3/database/repositories/configuracao_repository.dart';
import 'package:flutter_dashboard_3/database/repositories/contribuicao_repository.dart';
import 'package:flutter_dashboard_3/database/database_helper.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Repositories
  final MembroRepository _membroRepository = MembroRepository();
  final ConfiguracaoRepository _configuracaoRepository =
      ConfiguracaoRepository();
  final ContribuicaoRepository _contribuicaoRepository =
      ContribuicaoRepository();

  // Services
  final ContribuicaoService _contribuicaoService = ContribuicaoService();

  // Database Helper
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // ============ MEMBROS ============

  Future<int> insertMembro(Membro membro) => _membroRepository.insert(membro);
  Future<List<Membro>> getMembros() => _membroRepository.getAll();
  Future<Membro?> getMembroById(int id) => _membroRepository.getById(id);
  Future<List<Membro>> getMembrosByStatus(String status) =>
      _membroRepository.getByStatus(status);
  Future<List<Membro>> getMembrosByNome(String nome) =>
      _membroRepository.getByNome(nome);
  Future<int> updateMembro(Membro membro) => _membroRepository.update(membro);
  Future<int> deleteMembro(int id) => _membroRepository.delete(id);
  Future<int> contarMembros() => _membroRepository.count();
  Future<Map<String, int>> contarMembrosPorStatus() =>
      _membroRepository.countByStatus();
  Future<bool> existeEmailMembro(String email, {int? excluirId}) =>
      _membroRepository.existsEmail(email, excludeId: excluirId);

  // ============ CONFIGURAÇÕES ============

  Future<int> insertConfiguracao(Configuracao configuracao) =>
      _configuracaoRepository.insert(configuracao);
  Future<List<Configuracao>> getConfiguracoes() =>
      _configuracaoRepository.getAll();
  Future<Configuracao?> getConfiguracaoPorChave(String chave) =>
      _configuracaoRepository.getByChave(chave);
  Future<String?> getValorConfiguracao(String chave) =>
      _configuracaoRepository.getValor(chave);
  Future<double> getValorContribuicaoMensal() =>
      _configuracaoRepository.getValorContribuicaoMensal();
  Future<int> updateConfiguracao(
    String chave,
    String novoValor, {
    String? descricao,
  }) => _configuracaoRepository.updateByChave(
    chave,
    novoValor,
    descricao: descricao,
  );
  Future<int> deleteConfiguracao(String chave) =>
      _configuracaoRepository.deleteByChave(chave);

  // ============ CONTRIBUIÇÕES ============

  Future<int> insertContribuicao(Contribuicao contribuicao) =>
      _contribuicaoRepository.insert(contribuicao);
  Future<List<Contribuicao>> getContribuicoes({
    int? membroId,
    int? mesReferencia,
    int? anoReferencia,
    String? status,
  }) => _contribuicaoRepository.get(
    membroId: membroId,
    mesReferencia: mesReferencia,
    anoReferencia: anoReferencia,
    status: status,
  );
  Future<Contribuicao?> getContribuicaoById(int id) =>
      _contribuicaoRepository.getById(id);
  Future<int> updateContribuicao(Contribuicao contribuicao) =>
      _contribuicaoRepository.update(contribuicao);
  Future<int> deleteContribuicao(int id) => _contribuicaoRepository.delete(id);
  Future<bool> existemContribuicoesPeriodo(int mes, int ano) =>
      _contribuicaoRepository.existsForPeriod(mes, ano);
  Future<Map<String, dynamic>> getEstatisticasContribuicoes({
    int? mesReferencia,
    int? anoReferencia,
  }) => _contribuicaoRepository.getEstatisticas(
    mesReferencia: mesReferencia,
    anoReferencia: anoReferencia,
  );

  // ============ SERVIÇOS DE CONTRIBUIÇÃO ============

  Future<Map<String, dynamic>> gerarContribuicoesMensais({
    int? mesReferencia,
    int? anoReferencia,
  }) => _contribuicaoService.gerarContribuicoesMensais(
    mesReferencia: mesReferencia,
    anoReferencia: anoReferencia,
  );

  Future<bool> marcarContribuicaoPaga(
    int contribuicaoId, {
    String? observacoes,
  }) => _contribuicaoService.marcarContribuicaoPaga(
    contribuicaoId,
    observacoes: observacoes,
  );

  Future<bool> cancelarContribuicao(
    int contribuicaoId, {
    String? motivoCancelamento,
  }) => _contribuicaoService.cancelarContribuicao(
    contribuicaoId,
    motivoCancelamento: motivoCancelamento,
  );

  // ============ OPERAÇÕES GERAIS ============

  Future<void> limparDados() => _databaseHelper.limparDados();
  Future<void> fecharDatabase() => _databaseHelper.fecharDatabase();
}
