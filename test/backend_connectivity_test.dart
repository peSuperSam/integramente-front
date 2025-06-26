import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

/// Script para testar a conectividade com o backend IntegraMente
///
/// Este arquivo testa se o backend está respondendo corretamente
/// e pode ser usado para validar o deploy em produção.
///
/// Para executar: dart test/backend_connectivity_test.dart

// Classe utilitária para logging estruturado
class TestLogger {
  static void info(String message) {
    developer.log(
      message,
      name: 'BackendConnectivityTest',
      level: 800, // INFO level
    );
  }

  static void success(String message) {
    developer.log(
      '✅ $message',
      name: 'BackendConnectivityTest',
      level: 800, // INFO level
    );
  }

  static void error(String message) {
    developer.log(
      '❌ $message',
      name: 'BackendConnectivityTest',
      level: 1000, // ERROR level
    );
  }

  static void warning(String message) {
    developer.log(
      '⚠️ $message',
      name: 'BackendConnectivityTest',
      level: 900, // WARNING level
    );
  }
}

/// Testa a conectividade com o backend IntegraMente
void main() async {
  TestLogger.info('🔍 Testando conectividade com backend IntegraMente\n');

  // URL de produção no Render
  const String backendUrl = 'https://integramente-backend.onrender.com';

  await _testHealthCheck(backendUrl);
  await _testAreaCalculation(backendUrl);
  await _testSymbolicCalculation(backendUrl);

  TestLogger.success('🎯 Teste de conectividade concluído!');
  TestLogger.info('🔗 Backend URL: $backendUrl');
  TestLogger.info('🚀 Hospedado no Render (Produção)');
}

/// Testa o endpoint de health check
Future<void> _testHealthCheck(String backendUrl) async {
  TestLogger.info('📡 Teste 1: Health Check');
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    final request = await client.getUrl(Uri.parse('$backendUrl/health'));
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      TestLogger.success('Health Check: Servidor online');
      TestLogger.info('📄 Resposta: $responseBody\n');
    } else {
      TestLogger.error(
        'Health Check: Falhou (Status: ${response.statusCode})\n',
      );
    }
    client.close();
  } catch (e) {
    TestLogger.error('Health Check: Erro - $e');
    TestLogger.warning(
      'O Render pode demorar até 30 segundos para "acordar" se inativo\n',
    );
  }
}

/// Testa o cálculo de área (integração numérica)
Future<void> _testAreaCalculation(String backendUrl) async {
  TestLogger.info('📊 Teste 2: Cálculo de Área');
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 30);

    final request = await client.postUrl(Uri.parse('$backendUrl/area'));
    request.headers.set('Content-Type', 'application/json');

    final testData = {'funcao': 'x^2', 'a': -2, 'b': 2, 'resolucao': 100};

    request.add(utf8.encode(jsonEncode(testData)));
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      TestLogger.success('Cálculo de Área: Funcionando');
      TestLogger.info('📊 Área Total: ${data['area_total']}');
      TestLogger.info('🔢 Valor Integral: ${data['valor_integral']}');
      final hasGraph = data['grafico_base64'] != null;
      TestLogger.info(
        '📈 Gráfico: ${hasGraph ? "Gerado (${data['grafico_base64'].toString().length} chars)" : "Não gerado"}\n',
      );
    } else {
      TestLogger.error(
        'Cálculo de Área: Falhou (Status: ${response.statusCode})\n',
      );
    }
    client.close();
  } catch (e) {
    TestLogger.error('Cálculo de Área: Erro - $e\n');
  }
}

/// Testa o cálculo simbólico (integração analítica)
Future<void> _testSymbolicCalculation(String backendUrl) async {
  TestLogger.info('🔣 Teste 3: Cálculo Simbólico');
  try {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 30);

    final request = await client.postUrl(Uri.parse('$backendUrl/simbolico'));
    request.headers.set('Content-Type', 'application/json');

    final testData = {
      'funcao': 'x^2',
      'mostrar_passos': true,
      'formato_latex': true,
    };

    request.add(utf8.encode(jsonEncode(testData)));
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);
      TestLogger.success('Cálculo Simbólico: Funcionando');
      TestLogger.info('∫ Antiderivada: ${data['antiderivada']}');
      TestLogger.info(
        '📚 Passos: ${data['passos_resolucao']?.length ?? 0} passos\n',
      );
    } else {
      TestLogger.error(
        'Cálculo Simbólico: Falhou (Status: ${response.statusCode})\n',
      );
    }
    client.close();
  } catch (e) {
    TestLogger.error('Cálculo Simbólico: Erro - $e\n');
  }
}
