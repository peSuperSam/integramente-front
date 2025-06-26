import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/performance/performance_config.dart';
import '../models/historico_item.dart';

class StorageService {
  static const String _historicoKey = AppConstants.storageHistoricoKey;
  static const String _favoritosKey = AppConstants.storageFavoritosKey;
  static const String _configKey = AppConstants.storageConfiguracaoKey;

  late final SharedPreferences _prefs;

  // Cache em memória para melhor performance
  List<HistoricoItem>? _historicoCache;
  Map<String, dynamic>? _configCache;
  DateTime? _lastHistoricoUpdate;
  DateTime? _lastConfigUpdate;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Histórico com cache otimizado
  Future<List<HistoricoItem>> getHistorico() async {
    // Verifica cache em memória
    if (_historicoCache != null &&
        _lastHistoricoUpdate != null &&
        DateTime.now().difference(_lastHistoricoUpdate!).inMinutes < 5) {
      return _historicoCache!;
    }

    try {
      final jsonString = _prefs.getString(_historicoKey);
      if (jsonString == null) {
        _historicoCache = [];
        _lastHistoricoUpdate = DateTime.now();
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      _historicoCache =
          jsonList.map((json) => HistoricoItem.fromJson(json)).toList();
      _lastHistoricoUpdate = DateTime.now();

      return _historicoCache!;
    } catch (e) {
      _historicoCache = [];
      _lastHistoricoUpdate = DateTime.now();
      return [];
    }
  }

  Future<void> salvarHistorico(List<HistoricoItem> historico) async {
    try {
      // Limita o histórico para performance
      final historicoLimitado =
          historico.take(PerformanceConfig.maxHistoricoItems).toList();

      final jsonList = historicoLimitado.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_historicoKey, jsonString);

      // Atualiza cache
      _historicoCache = historicoLimitado;
      _lastHistoricoUpdate = DateTime.now();
    } catch (e) {
      throw Exception('Erro ao salvar histórico: $e');
    }
  }

  Future<void> limparHistorico() async {
    try {
      await _prefs.remove(_historicoKey);
      await _prefs.remove(_favoritosKey);
    } catch (e) {
      throw Exception('Erro ao limpar histórico: $e');
    }
  }

  // Configurações gerais com cache
  Future<Map<String, dynamic>> getConfiguracoes() async {
    // Verifica cache em memória
    if (_configCache != null &&
        _lastConfigUpdate != null &&
        DateTime.now().difference(_lastConfigUpdate!).inMinutes < 10) {
      return _configCache!;
    }

    try {
      final jsonString = _prefs.getString(_configKey);
      if (jsonString == null) {
        _configCache = _getDefaultConfig();
        _lastConfigUpdate = DateTime.now();
        return _configCache!;
      }

      _configCache = jsonDecode(jsonString);
      _lastConfigUpdate = DateTime.now();
      return _configCache!;
    } catch (e) {
      _configCache = _getDefaultConfig();
      _lastConfigUpdate = DateTime.now();
      return _configCache!;
    }
  }

  Future<void> salvarConfiguracoes(Map<String, dynamic> config) async {
    try {
      final jsonString = jsonEncode(config);
      await _prefs.setString(_configKey, jsonString);

      // Atualiza cache
      _configCache = config;
      _lastConfigUpdate = DateTime.now();
    } catch (e) {
      throw Exception('Erro ao salvar configurações: $e');
    }
  }

  Map<String, dynamic> _getDefaultConfig() {
    return {
      'tema': 'escuro',
      'animacoes': true,
      'notificacoes': true,
      'intervaloDefaultA': 0.0,
      'intervaloDefaultB': 1.0,
      'resolucaoGrafico': 1000,
      'formatoNumero': 'decimal',
      'linguagem': 'pt_BR',
    };
  }

  // Utilitários para configurações específicas
  Future<double> getIntervaloDefaultA() async {
    final config = await getConfiguracoes();
    return config['intervaloDefaultA'] ?? 0.0;
  }

  Future<double> getIntervaloDefaultB() async {
    final config = await getConfiguracoes();
    return config['intervaloDefaultB'] ?? 1.0;
  }

  Future<void> setIntervaloDefault(double a, double b) async {
    final config = await getConfiguracoes();
    config['intervaloDefaultA'] = a;
    config['intervaloDefaultB'] = b;
    await salvarConfiguracoes(config);
  }

  Future<int> getResolucaoGrafico() async {
    final config = await getConfiguracoes();
    return config['resolucaoGrafico'] ?? 1000;
  }

  Future<void> setResolucaoGrafico(int resolucao) async {
    final config = await getConfiguracoes();
    config['resolucaoGrafico'] = resolucao;
    await salvarConfiguracoes(config);
  }

  Future<bool> getAnimacoesHabilitadas() async {
    final config = await getConfiguracoes();
    return config['animacoes'] ?? true;
  }

  Future<void> setAnimacoesHabilitadas(bool habilitadas) async {
    final config = await getConfiguracoes();
    config['animacoes'] = habilitadas;
    await salvarConfiguracoes(config);
  }

  // Cache para resultados (opcional)
  Future<String?> getCacheResultado(String chave) async {
    try {
      return _prefs.getString('cache_$chave');
    } catch (e) {
      return null;
    }
  }

  Future<void> setCacheResultado(String chave, String valor) async {
    try {
      await _prefs.setString('cache_$chave', valor);
    } catch (e) {
      // Ignorar erros de cache
    }
  }

  Future<void> limparCache() async {
    try {
      final keys = _prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith('cache_'));

      for (final key in cacheKeys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      // Ignorar erros ao limpar cache
    }
  }

  // Estatísticas de uso
  Future<Map<String, int>> getEstatisticasUso() async {
    try {
      final jsonString = _prefs.getString('estatisticas_uso');
      if (jsonString == null) return _getDefaultStats();

      final Map<String, dynamic> data = jsonDecode(jsonString);
      return data.cast<String, int>();
    } catch (e) {
      return _getDefaultStats();
    }
  }

  Future<void> incrementarContador(String acao) async {
    try {
      final stats = await getEstatisticasUso();
      stats[acao] = (stats[acao] ?? 0) + 1;

      final jsonString = jsonEncode(stats);
      await _prefs.setString('estatisticas_uso', jsonString);
    } catch (e) {
      // Ignorar erros de estatísticas
    }
  }

  Map<String, int> _getDefaultStats() {
    return {
      'calculosArea': 0,
      'calculosSimbolico': 0,
      'favoritosAdicionados': 0,
      'historicoLimpo': 0,
      'acessosHome': 0,
      'acessosArea': 0,
      'acessosCalculadora': 0,
    };
  }
}
