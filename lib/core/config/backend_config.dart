import 'dart:developer' as developer;

class BackendConfig {
  // Configurações de desenvolvimento (local)
  static const String _devBaseUrl = 'http://localhost:8000';

  // Configurações de produção (Deploy no Render)
  static const String _prodBaseUrl =
      'https://integramente-backend.onrender.com';

  // URLs de fallback para produção (caso a principal falhe)
  static const List<String> _fallbackUrls = [
    'https://integramente-backend.onrender.com',
    // Adicionar outras URLs de backup se necessário
  ];

  // Flag para alternar entre dev e prod
  static const bool _isDevelopment = false; // ALTERADO PARA PRODUÇÃO

  // URL base atual
  static String get baseUrl => _isDevelopment ? _devBaseUrl : _prodBaseUrl;

  // URLs de fallback (para uso futuro com retry automático)
  static List<String> get fallbackUrls => _fallbackUrls;

  // Endpoints principais
  static const String areaEndpoint = '/area';
  static const String simbolicoEndpoint = '/simbolico';
  static const String derivadaEndpoint = '/derivada';
  static const String limiteEndpoint = '/limite';
  static const String healthEndpoint = '/health';
  static const String validarEndpoint = '/validar';
  static const String exemplosEndpoint = '/exemplos';
  static const String graficoEndpoint = '/grafico';

  // Novos endpoints - Visualização 3D
  static const String visualization3dSurfaceEndpoint = '/3d/surface';
  static const String visualization3dContourEndpoint = '/3d/contour';
  static const String visualization3dVectorFieldEndpoint = '/3d/vector-field';
  static const String visualization3dParametricEndpoint =
      '/3d/parametric-surface';
  static const String visualization3dVolumeEndpoint = '/3d/integration-volume';
  static const String visualization3dGradientEndpoint = '/3d/gradient-field';

  // Novos endpoints - Machine Learning
  static const String mlAnalyzeFunctionEndpoint = '/ml/analyze-function';
  static const String mlIntegrationDifficultyEndpoint =
      '/ml/integration-difficulty';
  static const String mlComputationTimeEndpoint = '/ml/computation-time';
  static const String mlOptimalResolutionEndpoint = '/ml/optimal-resolution';
  static const String mlModelInfoEndpoint = '/ml/model-info';

  // Novos endpoints - Performance
  static const String performanceSummaryEndpoint = '/performance/summary';
  static const String performanceCacheEndpoint = '/performance/cache';
  static const String performancePrecisionEndpoint = '/performance/precision';
  static const String performanceSlowestEndpoint = '/performance/slowest';
  static const String performanceIssuesEndpoint = '/performance/issues';
  static const String performanceExportEndpoint = '/performance/export';
  static const String performanceResetEndpoint = '/performance/reset';
  static const String securityStatsEndpoint = '/security/stats';

  // Configurações de timeout
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration healthTimeout = Duration(
    seconds: 10,
  ); // Aumentado para produção
  static const Duration imageTimeout = Duration(
    seconds: 15,
  ); // Aumentado para produção

  // Headers padrão
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Configurações específicas para desenvolvimento
  static const Map<String, dynamic> devConfig = {
    'debug': true,
    'showLogs': true,
    'fallbackToLocal': true, // Se não conseguir conectar, usa cálculos locais
  };

  // Configurações específicas para produção
  static const Map<String, dynamic> prodConfig = {
    'debug': false,
    'showLogs': true, // Mantido true para monitoramento inicial
    'fallbackToLocal': false, // Em produção, sempre tenta usar o backend
  };

  // Configuração atual
  static Map<String, dynamic> get currentConfig =>
      _isDevelopment ? devConfig : prodConfig;

  // Métodos utilitários
  static bool get isDebug => currentConfig['debug'] as bool;
  static bool get showLogs => currentConfig['showLogs'] as bool;
  static bool get fallbackToLocal => currentConfig['fallbackToLocal'] as bool;

  // URLs completas - Endpoints principais
  static String get areaUrl => '$baseUrl$areaEndpoint';
  static String get simbolicoUrl => '$baseUrl$simbolicoEndpoint';
  static String get derivadaUrl => '$baseUrl$derivadaEndpoint';
  static String get limiteUrl => '$baseUrl$limiteEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';
  static String get validarUrl => '$baseUrl$validarEndpoint';
  static String get exemplosUrl => '$baseUrl$exemplosEndpoint';
  static String get graficoUrl => '$baseUrl$graficoEndpoint';

  // URLs completas - Visualização 3D
  static String get visualization3dSurfaceUrl =>
      '$baseUrl$visualization3dSurfaceEndpoint';
  static String get visualization3dContourUrl =>
      '$baseUrl$visualization3dContourEndpoint';
  static String get visualization3dVectorFieldUrl =>
      '$baseUrl$visualization3dVectorFieldEndpoint';
  static String get visualization3dParametricUrl =>
      '$baseUrl$visualization3dParametricEndpoint';
  static String get visualization3dVolumeUrl =>
      '$baseUrl$visualization3dVolumeEndpoint';
  static String get visualization3dGradientUrl =>
      '$baseUrl$visualization3dGradientEndpoint';

  // URLs completas - Machine Learning
  static String get mlAnalyzeFunctionUrl =>
      '$baseUrl$mlAnalyzeFunctionEndpoint';
  static String get mlIntegrationDifficultyUrl =>
      '$baseUrl$mlIntegrationDifficultyEndpoint';
  static String get mlComputationTimeUrl =>
      '$baseUrl$mlComputationTimeEndpoint';
  static String get mlOptimalResolutionUrl =>
      '$baseUrl$mlOptimalResolutionEndpoint';
  static String get mlModelInfoUrl => '$baseUrl$mlModelInfoEndpoint';

  // URLs completas - Performance
  static String get performanceSummaryUrl =>
      '$baseUrl$performanceSummaryEndpoint';
  static String get performanceCacheUrl => '$baseUrl$performanceCacheEndpoint';
  static String get performancePrecisionUrl =>
      '$baseUrl$performancePrecisionEndpoint';
  static String get performanceSlowestUrl =>
      '$baseUrl$performanceSlowestEndpoint';
  static String get performanceIssuesUrl =>
      '$baseUrl$performanceIssuesEndpoint';
  static String get performanceExportUrl =>
      '$baseUrl$performanceExportEndpoint';
  static String get performanceResetUrl => '$baseUrl$performanceResetEndpoint';
  static String get securityStatsUrl => '$baseUrl$securityStatsEndpoint';

  // Método para testar conectividade com fallback
  static Future<String?> findWorkingUrl() async {
    // Primeiro tenta a URL principal
    try {
      // Implementar teste de conectividade aqui se necessário
      return _prodBaseUrl;
    } catch (e) {
      // Em caso de falha, pode implementar teste das URLs de fallback
      developer.log(
        'URL principal falhou, usando fallback',
        name: 'IntegraMente_Config',
        level: 900, // WARNING level
      );
      return _fallbackUrls.isNotEmpty ? _fallbackUrls.first : null;
    }
  }

  // Método para alternar rapidamente para desenvolvimento (para debug)
  static void switchToDevelopment() {
    developer.log(
      'ATENÇÃO: Alternado para modo desenvolvimento (apenas para debug)',
      name: 'IntegraMente_Config',
      level: 1000, // ERROR level para chamar atenção
    );
    // Note: Esta é apenas uma função de log. Para realmente alternar,
    // seria necessário alterar a constante _isDevelopment e rebuildar
  }

  // Método para log da configuração atual
  static void logCurrentConfig() {
    if (showLogs) {
      final configInfo = '''
=== INTEGRAMENTE BACKEND CONFIG ===
Mode: ${_isDevelopment ? 'DEVELOPMENT' : 'PRODUCTION'}
Base URL: $baseUrl
Debug: $isDebug
Fallback to Local: $fallbackToLocal
Health URL: $healthUrl
================================''';

      developer.log(
        configInfo,
        name: 'IntegraMente_Config',
        level: 800, // INFO level
      );
    }
  }
}
