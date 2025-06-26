import 'dart:developer' as developer;

class BackendConfig {
  // Configurações de desenvolvimento (local)
  static const String _devBaseUrl = 'http://localhost:5000';

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

  // Endpoints
  static const String areaEndpoint = '/area';
  static const String simbolicoEndpoint = '/simbolico';
  static const String healthEndpoint = '/health';
  static const String validarEndpoint = '/validar';
  static const String exemplosEndpoint = '/exemplos';
  static const String graficoEndpoint = '/grafico';

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

  // URLs completas
  static String get areaUrl => '$baseUrl$areaEndpoint';
  static String get simbolicoUrl => '$baseUrl$simbolicoEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';
  static String get validarUrl => '$baseUrl$validarEndpoint';
  static String get exemplosUrl => '$baseUrl$exemplosEndpoint';
  static String get graficoUrl => '$baseUrl$graficoEndpoint';

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
