import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/config/backend_config.dart';
import '../../core/utils/app_logger.dart';
import '../models/funcao_matematica.dart';
import '../models/calculo_response.dart';

class ApiService {
  // Configuração dinâmica do backend
  static String get _baseUrl => BackendConfig.baseUrl;
  static Duration get _timeout => BackendConfig.defaultTimeout;
  static Map<String, String> get _headers => BackendConfig.defaultHeaders;

  // Log da configuração atual no construtor
  ApiService() {
    BackendConfig.logCurrentConfig();
  }

  /// Calcula a área sob a curva de uma função em um intervalo
  Future<CalculoAreaResponse> calcularArea({
    required FuncaoMatematica funcao,
    required double intervaloA,
    required double intervaloB,
    int resolucao = AppConstants.chartResolutionDefault,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.areaUrl);

      final requestBody = {
        'funcao': funcao.expressao,
        'a': intervaloA, // Backend do Rafael usa 'a' e 'b'
        'b': intervaloB,
        'resolucao': resolucao,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(requestBody))
          .timeout(_timeout);

      return _handleAreaResponse(response);
    } catch (e) {
      return CalculoAreaResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Calcula a integral simbólica de uma função
  Future<CalculoSimbolicoResponse> calcularSimbolico({
    required FuncaoMatematica funcao,
    bool mostrarPassos = true,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.simbolicoUrl);

      final requestBody = {
        'funcao': funcao.expressao,
        'mostrar_passos': mostrarPassos,
        'formato_latex': true,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(requestBody))
          .timeout(_timeout);

      return _handleSimbolicoResponse(response);
    } catch (e) {
      return CalculoSimbolicoResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Valida se uma função matemática é válida no backend
  Future<bool> validarFuncao(String expressao) async {
    try {
      final url = Uri.parse(BackendConfig.validarUrl);

      final requestBody = {'funcao': expressao};

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(requestBody))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valida'] ?? false;
      }

      return false;
    } catch (e) {
      // Se não conseguir validar no backend, usa validação local
      return FuncaoMatematica.criarDaExpressao(expressao).isValida;
    }
  }

  /// Obtém exemplos de funções do backend
  Future<List<String>> obterExemplosFuncoes() async {
    try {
      final url = Uri.parse(BackendConfig.exemplosUrl);

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['exemplos'] ?? []);
      }

      return AppConstants.exemplosFuncoes;
    } catch (e) {
      // Fallback para exemplos locais
      return AppConstants.exemplosFuncoes;
    }
  }

  /// Verifica se o backend está disponível
  Future<bool> verificarConexao() async {
    try {
      final url = Uri.parse(BackendConfig.healthUrl);

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Verifica se a resposta tem o formato esperado do backend do Rafael
        return data['status'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtém a imagem do gráfico quando o backend retorna URL
  Future<String?> obterImagemGrafico(String graficoUrl) async {
    try {
      final url = Uri.parse('$_baseUrl$graficoUrl');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Converte a imagem para base64 para uso no Flutter
        final bytes = response.bodyBytes;
        return base64Encode(bytes);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Métodos privados para processamento de respostas

  CalculoAreaResponse _handleAreaResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Se o backend retornou URL do gráfico em vez de base64, buscar a imagem
        if (data['grafico_url'] != null && data['grafico_base64'] == null) {
          _processarGraficoUrl(data);
        }

        return CalculoAreaResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        return CalculoAreaResponse(
          sucesso: false,
          erro: errorData['erro'] ?? 'Erro desconhecido no servidor',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return CalculoAreaResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta do servidor: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Processa URL do gráfico em background (não bloqueia a resposta)
  void _processarGraficoUrl(Map<String, dynamic> data) {
    if (data['grafico_url'] != null) {
      // Processa em background para não bloquear a UI
      obterImagemGrafico(data['grafico_url'])
          .then((base64Image) {
            if (base64Image != null) {
              // Aqui poderia notificar observers ou salvar em cache
              AppLogger.api('Gráfico obtido com sucesso');
            }
          })
          .catchError((e) {
            AppLogger.error('Erro ao obter gráfico', error: e);
          });
    }
  }

  CalculoSimbolicoResponse _handleSimbolicoResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CalculoSimbolicoResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        return CalculoSimbolicoResponse(
          sucesso: false,
          erro: errorData['erro'] ?? 'Erro desconhecido no servidor',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return CalculoSimbolicoResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta do servidor: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  String _formatarErro(dynamic erro) {
    if (erro is http.ClientException) {
      return 'Erro de conexão: ${erro.message}';
    } else if (erro.toString().contains('TimeoutException')) {
      return 'Timeout: O servidor demorou muito para responder';
    } else if (erro.toString().contains('SocketException')) {
      return 'Erro de rede: Verifique sua conexão com a internet';
    } else {
      return 'Erro inesperado: ${erro.toString()}';
    }
  }

  /// Método para testes locais sem backend
  Future<CalculoAreaResponse> calcularAreaLocal({
    required FuncaoMatematica funcao,
    required double intervaloA,
    required double intervaloB,
  }) async {
    // Simula processamento
    await Future.delayed(const Duration(milliseconds: 800));

    // Gera resultado mockado baseado na função
    final area = _calcularAreaMockada(funcao.expressao, intervaloA, intervaloB);

    return CalculoAreaResponse(
      sucesso: true,
      valorIntegral: area,
      areaTotal: area.abs(),
      funcaoFormatada: funcao.expressaoFormatada,
      calculadoEm: DateTime.now(),
    );
  }

  Future<CalculoSimbolicoResponse> calcularSimbolicoLocal({
    required FuncaoMatematica funcao,
  }) async {
    // Simula processamento
    await Future.delayed(const Duration(milliseconds: 600));

    final antiderivada = _calcularAntiderivadaMockada(funcao.expressao);

    return CalculoSimbolicoResponse(
      sucesso: true,
      antiderivada: antiderivada,
      antiderivadaLatex: _converterParaLatex(antiderivada),
      passosResolucao: [
        'Identificando tipo de função: ${funcao.expressao}',
        'Aplicando regras de integração',
        'Resultado: $antiderivada',
      ],
      calculadoEm: DateTime.now(),
    );
  }

  // Métodos auxiliares para cálculos mockados
  double _calcularAreaMockada(String expressao, double a, double b) {
    // Cálculo simplificado para demonstração
    if (expressao.contains('x^2')) {
      return (b * b * b - a * a * a) / 3; // Integral de x²
    } else if (expressao.contains('x^3')) {
      return (b * b * b * b - a * a * a * a) / 4; // Integral de x³
    } else if (expressao.contains('x')) {
      return (b * b - a * a) / 2; // Integral de x
    } else {
      return (b - a); // Integral de constante
    }
  }

  String _calcularAntiderivadaMockada(String expressao) {
    if (expressao.contains('x^2')) {
      return 'x³/3 + C';
    } else if (expressao.contains('x^3')) {
      return 'x⁴/4 + C';
    } else if (expressao.contains('sin(x)')) {
      return '-cos(x) + C';
    } else if (expressao.contains('cos(x)')) {
      return 'sin(x) + C';
    } else if (expressao.contains('x')) {
      return 'x²/2 + C';
    } else {
      return '${expressao}x + C';
    }
  }

  String _converterParaLatex(String expressao) {
    return expressao
        .replaceAll('x³', 'x^3')
        .replaceAll('x²', 'x^2')
        .replaceAll('x⁴', 'x^4')
        .replaceAll('/', '\\frac{1}{')
        .replaceAll('sin', '\\sin')
        .replaceAll('cos', '\\cos');
  }
}
