import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/config/backend_config.dart';
import '../../core/utils/app_logger.dart';
import '../models/funcao_matematica.dart';
import '../models/calculo_response.dart';
import '../models/visualization_3d_models.dart';
import '../models/ml_models.dart';
import '../models/performance_models.dart';

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

  /// Calcula a derivada de uma função
  Future<CalculoDerivadaResponse> calcularDerivada({
    required FuncaoMatematica funcao,
    bool mostrarPassos = true,
    String tipoDerivada = 'primeira',
  }) async {
    try {
      final url = Uri.parse(BackendConfig.derivadaUrl);

      final requestBody = {
        'funcao': funcao.expressao,
        'mostrar_passos': mostrarPassos,
        'formato_latex': true,
        'tipo_derivada': tipoDerivada,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(requestBody))
          .timeout(_timeout);

      return _handleDerivadaResponse(response);
    } catch (e) {
      return CalculoDerivadaResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Calcula o limite de uma função
  Future<CalculoLimiteResponse> calcularLimite({
    required FuncaoMatematica funcao,
    required double pontoLimite,
    bool mostrarPassos = true,
    String tipoLimite = 'bilateral',
  }) async {
    try {
      final url = Uri.parse(BackendConfig.limiteUrl);

      final requestBody = {
        'funcao': funcao.expressao,
        'ponto_limite': pontoLimite,
        'mostrar_passos': mostrarPassos,
        'formato_latex': true,
        'tipo_limite': tipoLimite,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(requestBody))
          .timeout(_timeout);

      return _handleLimiteResponse(response);
    } catch (e) {
      return CalculoLimiteResponse(
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

  CalculoDerivadaResponse _handleDerivadaResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CalculoDerivadaResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        return CalculoDerivadaResponse(
          sucesso: false,
          erro: errorData['erro'] ?? 'Erro desconhecido no servidor',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return CalculoDerivadaResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta do servidor: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  CalculoLimiteResponse _handleLimiteResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CalculoLimiteResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        return CalculoLimiteResponse(
          sucesso: false,
          erro: errorData['erro'] ?? 'Erro desconhecido no servidor',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return CalculoLimiteResponse(
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

  Future<CalculoDerivadaResponse> calcularDerivadaLocal({
    required FuncaoMatematica funcao,
    String tipoDerivada = 'primeira',
  }) async {
    // Simula processamento
    await Future.delayed(const Duration(milliseconds: 500));

    final derivada = _calcularDerivadaMockada(funcao.expressao);

    return CalculoDerivadaResponse(
      sucesso: true,
      derivada: derivada,
      derivadaLatex: _converterParaLatex(derivada),
      derivadaSimplificada: derivada,
      tipoDerivada: tipoDerivada,
      funcaoOriginal: funcao.expressao,
      passosResolucao: [
        'Função original: ${funcao.expressao}',
        'Aplicando regras de derivação',
        'Derivada: $derivada',
      ],
      calculadoEm: DateTime.now(),
    );
  }

  Future<CalculoLimiteResponse> calcularLimiteLocal({
    required FuncaoMatematica funcao,
    required double pontoLimite,
    String tipoLimite = 'bilateral',
  }) async {
    // Simula processamento
    await Future.delayed(const Duration(milliseconds: 700));

    final valorLimite = _calcularLimiteMockado(funcao.expressao, pontoLimite);
    final existeLimite = valorLimite.isFinite;

    return CalculoLimiteResponse(
      sucesso: true,
      valorLimite: existeLimite ? valorLimite : null,
      limiteLatex: existeLimite ? valorLimite.toString() : '∄',
      tipoLimite: tipoLimite,
      existeLimite: existeLimite,
      funcaoOriginal: funcao.expressao,
      pontoLimite: pontoLimite,
      passosResolucao: [
        'Função: ${funcao.expressao}',
        'Calculando limite quando x → $pontoLimite',
        existeLimite ? 'Limite = $valorLimite' : 'Limite não existe',
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

  String _calcularDerivadaMockada(String expressao) {
    if (expressao.contains('x^3')) {
      return '3x²';
    } else if (expressao.contains('x^2')) {
      return '2x';
    } else if (expressao.contains('sin(x)')) {
      return 'cos(x)';
    } else if (expressao.contains('cos(x)')) {
      return '-sin(x)';
    } else if (expressao.contains('ln(x)')) {
      return '1/x';
    } else if (expressao.contains('e^x')) {
      return 'e^x';
    } else if (expressao.contains('x')) {
      return '1';
    } else {
      return '0'; // Derivada de constante
    }
  }

  double _calcularLimiteMockado(String expressao, double ponto) {
    // Simulação simples de cálculo de limite
    try {
      if (expressao.contains('sin(x)/x') && ponto == 0) {
        return 1.0; // Limite famoso lim(x→0) sin(x)/x = 1
      } else if (expressao.contains('(x^2-1)/(x-1)') && ponto == 1) {
        return 2.0; // lim(x→1) (x²-1)/(x-1) = 2
      } else if (expressao.contains('(e^x-1)/x') && ponto == 0) {
        return 1.0; // lim(x→0) (e^x-1)/x = 1
      } else if (expressao.contains('1/x') && ponto == 0) {
        return double.infinity; // Limite infinito
      } else if (expressao.contains('x^2')) {
        return ponto * ponto;
      } else if (expressao.contains('x^3')) {
        return ponto * ponto * ponto;
      } else if (expressao.contains('x')) {
        return ponto;
      } else {
        // Função constante
        return double.tryParse(expressao) ?? 1.0;
      }
    } catch (e) {
      return double.nan; // Limite indeterminado
    }
  }

  // ========================================
  // NOVOS MÉTODOS - VISUALIZAÇÃO 3D
  // ========================================

  /// Gera superfície 3D para função f(x,y)
  Future<Visualization3DResponse> gerarSuperficie3D({
    required String funcao,
    required List<double> xRange,
    required List<double> yRange,
    int resolution = 50,
    Map<String, dynamic>? opcoes,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.visualization3dSurfaceUrl);

      final request = Visualization3DRequest(
        funcao: funcao,
        xRange: xRange,
        yRange: yRange,
        resolution: resolution,
        opcoes: opcoes,
      );

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleVisualization3DResponse(response);
    } catch (e) {
      return Visualization3DResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Gera contornos 3D para função f(x,y)
  Future<Visualization3DResponse> gerarContorno3D({
    required String funcao,
    required List<double> xRange,
    required List<double> yRange,
    int resolution = 50,
    Map<String, dynamic>? opcoes,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.visualization3dContourUrl);

      final request = Visualization3DRequest(
        funcao: funcao,
        xRange: xRange,
        yRange: yRange,
        resolution: resolution,
        opcoes: opcoes,
      );

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleVisualization3DResponse(response);
    } catch (e) {
      return Visualization3DResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Gera campo vetorial 3D
  Future<Visualization3DResponse> gerarCampoVetorial3D({
    required String fx,
    required String fy,
    required String fz,
    required List<double> xRange,
    required List<double> yRange,
    required List<double> zRange,
    int resolution = 20,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.visualization3dVectorFieldUrl);

      final request = VectorField3DRequest(
        fx: fx,
        fy: fy,
        fz: fz,
        xRange: xRange,
        yRange: yRange,
        zRange: zRange,
        resolution: resolution,
      );

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleVisualization3DResponse(response);
    } catch (e) {
      return Visualization3DResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Gera superfície paramétrica 3D
  Future<Visualization3DResponse> gerarSuperficieParametrica3D({
    required String fx,
    required String fy,
    required String fz,
    required List<double> uRange,
    required List<double> vRange,
    int resolution = 50,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.visualization3dParametricUrl);

      final request = ParametricSurface3DRequest(
        fx: fx,
        fy: fy,
        fz: fz,
        uRange: uRange,
        vRange: vRange,
        resolution: resolution,
      );

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleVisualization3DResponse(response);
    } catch (e) {
      return Visualization3DResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Gera volume de integração 3D
  Future<Visualization3DResponse> gerarVolumeIntegracao3D({
    required String funcao,
    required List<double> xRange,
    required List<double> yRange,
    int resolution = 50,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.visualization3dVolumeUrl);

      final request = IntegrationVolume3DRequest(
        funcao: funcao,
        xRange: xRange,
        yRange: yRange,
        resolution: resolution,
      );

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleVisualization3DResponse(response);
    } catch (e) {
      return Visualization3DResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Gera campo gradiente 3D
  Future<Visualization3DResponse> gerarCampoGradiente3D({
    required String funcao,
    required List<double> xRange,
    required List<double> yRange,
    int resolution = 20,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.visualization3dGradientUrl);

      final request = Visualization3DRequest(
        funcao: funcao,
        xRange: xRange,
        yRange: yRange,
        resolution: resolution,
      );

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleVisualization3DResponse(response);
    } catch (e) {
      return Visualization3DResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  // ========================================
  // NOVOS MÉTODOS - MACHINE LEARNING
  // ========================================

  /// Análise completa de função com ML
  Future<MLAnalysisResponse> analisarFuncaoML({
    required String funcao,
    Map<String, dynamic>? opcoes,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.mlAnalyzeFunctionUrl);

      final request = MLAnalysisRequest(funcao: funcao, opcoes: opcoes);

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleMLAnalysisResponse(response);
    } catch (e) {
      return MLAnalysisResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Predição de dificuldade de integração
  Future<MLIntegrationDifficultyResponse> predizerDificuldadeIntegracao({
    required String funcao,
    List<double>? interval,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.mlIntegrationDifficultyUrl);

      final request = MLIntegrationDifficultyRequest(
        funcao: funcao,
        interval: interval,
      );

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleMLIntegrationDifficultyResponse(response);
    } catch (e) {
      return MLIntegrationDifficultyResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Estimativa de tempo de computação
  Future<MLComputationTimeResponse> estimarTempoComputacao({
    required String funcao,
    int? resolution,
    List<double>? interval,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.mlComputationTimeUrl);

      final request = MLComputationTimeRequest(
        funcao: funcao,
        resolution: resolution,
        interval: interval,
      );

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleMLComputationTimeResponse(response);
    } catch (e) {
      return MLComputationTimeResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Predição de resolução ótima
  Future<MLOptimalResolutionResponse> predizerResolucaoOtima({
    required String funcao,
    List<double>? interval,
    double? tolerancia,
  }) async {
    try {
      final url = Uri.parse(BackendConfig.mlOptimalResolutionUrl);

      final request = MLOptimalResolutionRequest(
        funcao: funcao,
        interval: interval,
        tolerancia: tolerancia,
      );

      final response = await http
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      return _handleMLOptimalResolutionResponse(response);
    } catch (e) {
      return MLOptimalResolutionResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Informações dos modelos ML
  Future<MLModelInfoResponse> obterInfoModelosML() async {
    try {
      final url = Uri.parse(BackendConfig.mlModelInfoUrl);

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _handleMLModelInfoResponse(response);
    } catch (e) {
      return MLModelInfoResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  // ========================================
  // NOVOS MÉTODOS - PERFORMANCE
  // ========================================

  /// Resumo de performance do sistema
  Future<PerformanceSummaryResponse> obterResumoPerformance() async {
    try {
      final url = Uri.parse(BackendConfig.performanceSummaryUrl);

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _handlePerformanceSummaryResponse(response);
    } catch (e) {
      return PerformanceSummaryResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Estatísticas de cache
  Future<CacheStatsResponse> obterEstatisticasCache() async {
    try {
      final url = Uri.parse(BackendConfig.performanceCacheUrl);

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _handleCacheStatsResponse(response);
    } catch (e) {
      return CacheStatsResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Análise de precisão
  Future<PrecisionAnalysisResponse> obterAnalisesPrecisao() async {
    try {
      final url = Uri.parse(BackendConfig.performancePrecisionUrl);

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _handlePrecisionAnalysisResponse(response);
    } catch (e) {
      return PrecisionAnalysisResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Estatísticas de segurança
  Future<SecurityStatsResponse> obterEstatisticasSeguranca() async {
    try {
      final url = Uri.parse(BackendConfig.securityStatsUrl);

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _handleSecurityStatsResponse(response);
    } catch (e) {
      return SecurityStatsResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  // ========================================
  // NOVOS ENDPOINTS ADICIONAIS DE PERFORMANCE
  // ========================================

  /// Obter cálculos mais lentos
  Future<SlowestCalculationsResponse> obterCalculosMaisLentos({
    int limit = 5,
  }) async {
    try {
      final url = Uri.parse(
        '${BackendConfig.performanceSlowestUrl}?limit=$limit',
      );

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _handleSlowestCalculationsResponse(response);
    } catch (e) {
      return SlowestCalculationsResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Detectar problemas de performance
  Future<PerformanceIssuesResponse> detectarProblemasPerformance() async {
    try {
      final url = Uri.parse(BackendConfig.performanceIssuesUrl);

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _handlePerformanceIssuesResponse(response);
    } catch (e) {
      return PerformanceIssuesResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Exportar métricas de performance
  Future<PerformanceExportResponse> exportarMetricasPerformance({
    String format = 'json',
  }) async {
    try {
      final url = Uri.parse(
        '${BackendConfig.performanceExportUrl}?format=$format',
      );

      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 15));

      return _handlePerformanceExportResponse(response);
    } catch (e) {
      return PerformanceExportResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  /// Reiniciar estatísticas de performance
  Future<PerformanceResetResponse> reiniciarEstatisticasPerformance() async {
    try {
      final url = Uri.parse(BackendConfig.performanceResetUrl);

      final response = await http
          .post(url, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _handlePerformanceResetResponse(response);
    } catch (e) {
      return PerformanceResetResponse(
        sucesso: false,
        erro: _formatarErro(e),
        calculadoEm: DateTime.now(),
      );
    }
  }

  // ========================================
  // MÉTODOS AUXILIARES PARA HANDLING RESPONSES
  // ========================================

  Visualization3DResponse _handleVisualization3DResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Visualization3DResponse.fromJson(data);
      } else {
        return Visualization3DResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return Visualization3DResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  MLAnalysisResponse _handleMLAnalysisResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MLAnalysisResponse.fromJson(data);
      } else {
        return MLAnalysisResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return MLAnalysisResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  MLIntegrationDifficultyResponse _handleMLIntegrationDifficultyResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MLIntegrationDifficultyResponse.fromJson(data);
      } else {
        return MLIntegrationDifficultyResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return MLIntegrationDifficultyResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  MLComputationTimeResponse _handleMLComputationTimeResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MLComputationTimeResponse.fromJson(data);
      } else {
        return MLComputationTimeResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return MLComputationTimeResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  MLOptimalResolutionResponse _handleMLOptimalResolutionResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MLOptimalResolutionResponse.fromJson(data);
      } else {
        return MLOptimalResolutionResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return MLOptimalResolutionResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  MLModelInfoResponse _handleMLModelInfoResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MLModelInfoResponse.fromJson(data);
      } else {
        return MLModelInfoResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return MLModelInfoResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  PerformanceSummaryResponse _handlePerformanceSummaryResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PerformanceSummaryResponse.fromJson(data);
      } else {
        return PerformanceSummaryResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return PerformanceSummaryResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  CacheStatsResponse _handleCacheStatsResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CacheStatsResponse.fromJson(data);
      } else {
        return CacheStatsResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return CacheStatsResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  PrecisionAnalysisResponse _handlePrecisionAnalysisResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PrecisionAnalysisResponse.fromJson(data);
      } else {
        return PrecisionAnalysisResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return PrecisionAnalysisResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  SecurityStatsResponse _handleSecurityStatsResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SecurityStatsResponse.fromJson(data);
      } else {
        return SecurityStatsResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return SecurityStatsResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  // Novos handlers para endpoints adicionais
  SlowestCalculationsResponse _handleSlowestCalculationsResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SlowestCalculationsResponse.fromJson(data);
      } else {
        return SlowestCalculationsResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return SlowestCalculationsResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  PerformanceIssuesResponse _handlePerformanceIssuesResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PerformanceIssuesResponse.fromJson(data);
      } else {
        return PerformanceIssuesResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return PerformanceIssuesResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  PerformanceExportResponse _handlePerformanceExportResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PerformanceExportResponse.fromJson(data);
      } else {
        return PerformanceExportResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return PerformanceExportResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }

  PerformanceResetResponse _handlePerformanceResetResponse(
    http.Response response,
  ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PerformanceResetResponse.fromJson(data);
      } else {
        return PerformanceResetResponse(
          sucesso: false,
          erro: 'Erro HTTP ${response.statusCode}: ${response.body}',
          calculadoEm: DateTime.now(),
        );
      }
    } catch (e) {
      return PerformanceResetResponse(
        sucesso: false,
        erro: 'Erro ao processar resposta: $e',
        calculadoEm: DateTime.now(),
      );
    }
  }
}
