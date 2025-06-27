import 'package:equatable/equatable.dart';

// Classe utilitária para parsing
class _ResponseUtils {
  static DateTime parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

class CalculoAreaResponse extends Equatable {
  final bool sucesso;
  final String? graficoBase64;
  final String? graficoUrl; // Para compatibilidade com o backend do Rafael
  final double? valorIntegral;
  final double? areaTotal;
  final double? erroEstimado; // Novo campo do backend
  final List<Map<String, double>>? pontosGrafico;
  final String? funcaoFormatada;
  final Map<String, double>? intervalo; // Novo campo do backend
  final String? erro;
  final DateTime calculadoEm;

  const CalculoAreaResponse({
    required this.sucesso,
    this.graficoBase64,
    this.graficoUrl,
    this.valorIntegral,
    this.areaTotal,
    this.erroEstimado,
    this.pontosGrafico,
    this.funcaoFormatada,
    this.intervalo,
    this.erro,
    required this.calculadoEm,
  });

  factory CalculoAreaResponse.fromJson(Map<String, dynamic> json) {
    return CalculoAreaResponse(
      sucesso: json['sucesso'] ?? false,
      graficoBase64: json['grafico_base64'],
      graficoUrl: json['grafico_url'], // Backend do Rafael
      valorIntegral: json['valor_integral']?.toDouble(),
      areaTotal: json['area_total']?.toDouble(),
      erroEstimado: json['erro_estimado']?.toDouble(),
      pontosGrafico: _parsePontosGrafico(json['pontos_grafico']),
      funcaoFormatada: json['funcao_formatada'],
      intervalo: _parseIntervalo(json['intervalo']),
      erro: json['erro'],
      calculadoEm: _ResponseUtils.parseDateTime(json['calculado_em']),
    );
  }

  // Métodos auxiliares para parsing
  static List<Map<String, double>>? _parsePontosGrafico(dynamic pontos) {
    if (pontos == null) return null;
    if (pontos is List) {
      return pontos.map<Map<String, double>>((ponto) {
        if (ponto is Map) {
          return <String, double>{
            'x': (ponto['x'] ?? 0.0).toDouble(),
            'y': (ponto['y'] ?? 0.0).toDouble(),
          };
        }
        return <String, double>{};
      }).toList();
    }
    return null;
  }

  static Map<String, double>? _parseIntervalo(dynamic intervalo) {
    if (intervalo == null) return null;
    if (intervalo is Map) {
      return {
        'a': (intervalo['a'] ?? 0.0).toDouble(),
        'b': (intervalo['b'] ?? 0.0).toDouble(),
      };
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'sucesso': sucesso,
      'grafico_base64': graficoBase64,
      'grafico_url': graficoUrl,
      'valor_integral': valorIntegral,
      'area_total': areaTotal,
      'erro_estimado': erroEstimado,
      'pontos_grafico': pontosGrafico,
      'funcao_formatada': funcaoFormatada,
      'intervalo': intervalo,
      'erro': erro,
      'calculado_em': calculadoEm.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    sucesso,
    graficoBase64,
    graficoUrl,
    valorIntegral,
    areaTotal,
    erroEstimado,
    pontosGrafico,
    funcaoFormatada,
    intervalo,
    erro,
    calculadoEm,
  ];
}

class CalculoSimbolicoResponse extends Equatable {
  final bool sucesso;
  final String? antiderivada;
  final String? antiderivadaLatex;
  final double? resultadoSimbolico; // Novo campo do backend
  final List<String>? passosResolucao;
  final String? funcaoOriginal; // Novo campo do backend
  final String? erro;
  final DateTime calculadoEm;

  const CalculoSimbolicoResponse({
    required this.sucesso,
    this.antiderivada,
    this.antiderivadaLatex,
    this.resultadoSimbolico,
    this.passosResolucao,
    this.funcaoOriginal,
    this.erro,
    required this.calculadoEm,
  });

  factory CalculoSimbolicoResponse.fromJson(Map<String, dynamic> json) {
    return CalculoSimbolicoResponse(
      sucesso: json['sucesso'] ?? false,
      antiderivada: json['antiderivada'],
      antiderivadaLatex: json['antiderivada_latex'],
      resultadoSimbolico: json['resultado_simbolico']?.toDouble(),
      passosResolucao: json['passos_resolucao']?.cast<String>(),
      funcaoOriginal: json['funcao_original'],
      erro: json['erro'],
      calculadoEm: _ResponseUtils.parseDateTime(json['calculado_em']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucesso': sucesso,
      'antiderivada': antiderivada,
      'antiderivada_latex': antiderivadaLatex,
      'resultado_simbolico': resultadoSimbolico,
      'passos_resolucao': passosResolucao,
      'funcao_original': funcaoOriginal,
      'erro': erro,
      'calculado_em': calculadoEm.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    sucesso,
    antiderivada,
    antiderivadaLatex,
    resultadoSimbolico,
    passosResolucao,
    funcaoOriginal,
    erro,
    calculadoEm,
  ];
}

class CalculoDerivadaResponse extends Equatable {
  final bool sucesso;
  final String? derivada;
  final String? derivadaLatex;
  final String? derivadaSimplificada;
  final List<String>? passosResolucao;
  final String? funcaoOriginal;
  final String? tipoDerivada; // primeira, segunda, etc.
  final String? erro;
  final DateTime calculadoEm;

  const CalculoDerivadaResponse({
    required this.sucesso,
    this.derivada,
    this.derivadaLatex,
    this.derivadaSimplificada,
    this.passosResolucao,
    this.funcaoOriginal,
    this.tipoDerivada,
    this.erro,
    required this.calculadoEm,
  });

  factory CalculoDerivadaResponse.fromJson(Map<String, dynamic> json) {
    return CalculoDerivadaResponse(
      sucesso: json['sucesso'] ?? false,
      derivada: json['derivada'],
      derivadaLatex: json['derivada_latex'],
      derivadaSimplificada: json['derivada_simplificada'],
      passosResolucao: json['passos_resolucao']?.cast<String>(),
      funcaoOriginal: json['funcao_original'],
      tipoDerivada: json['tipo_derivada'] ?? 'primeira',
      erro: json['erro'],
      calculadoEm: _ResponseUtils.parseDateTime(json['calculado_em']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucesso': sucesso,
      'derivada': derivada,
      'derivada_latex': derivadaLatex,
      'derivada_simplificada': derivadaSimplificada,
      'passos_resolucao': passosResolucao,
      'funcao_original': funcaoOriginal,
      'tipo_derivada': tipoDerivada,
      'erro': erro,
      'calculado_em': calculadoEm.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    sucesso,
    derivada,
    derivadaLatex,
    derivadaSimplificada,
    passosResolucao,
    funcaoOriginal,
    tipoDerivada,
    erro,
    calculadoEm,
  ];
}

class CalculoLimiteResponse extends Equatable {
  final bool sucesso;
  final double? valorLimite;
  final String? limiteLatex;
  final String? tipoLimite; // esquerda, direita, bilateral
  final bool existeLimite;
  final List<String>? passosResolucao;
  final String? funcaoOriginal;
  final double? pontoLimite;
  final String? erro;
  final DateTime calculadoEm;

  const CalculoLimiteResponse({
    required this.sucesso,
    this.valorLimite,
    this.limiteLatex,
    this.tipoLimite,
    this.existeLimite = false,
    this.passosResolucao,
    this.funcaoOriginal,
    this.pontoLimite,
    this.erro,
    required this.calculadoEm,
  });

  factory CalculoLimiteResponse.fromJson(Map<String, dynamic> json) {
    return CalculoLimiteResponse(
      sucesso: json['sucesso'] ?? false,
      valorLimite: json['valor_limite']?.toDouble(),
      limiteLatex: json['limite_latex'],
      tipoLimite: json['tipo_limite'] ?? 'bilateral',
      existeLimite: json['existe_limite'] ?? false,
      passosResolucao: json['passos_resolucao']?.cast<String>(),
      funcaoOriginal: json['funcao_original'],
      pontoLimite: json['ponto_limite']?.toDouble(),
      erro: json['erro'],
      calculadoEm: _ResponseUtils.parseDateTime(json['calculado_em']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sucesso': sucesso,
      'valor_limite': valorLimite,
      'limite_latex': limiteLatex,
      'tipo_limite': tipoLimite,
      'existe_limite': existeLimite,
      'passos_resolucao': passosResolucao,
      'funcao_original': funcaoOriginal,
      'ponto_limite': pontoLimite,
      'erro': erro,
      'calculado_em': calculadoEm.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    sucesso,
    valorLimite,
    limiteLatex,
    tipoLimite,
    existeLimite,
    passosResolucao,
    funcaoOriginal,
    pontoLimite,
    erro,
    calculadoEm,
  ];
}
