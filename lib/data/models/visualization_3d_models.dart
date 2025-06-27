class Visualization3DRequest {
  final String funcao;
  final List<double> xRange;
  final List<double> yRange;
  final int resolution;
  final Map<String, dynamic>? opcoes;

  Visualization3DRequest({
    required this.funcao,
    required this.xRange,
    required this.yRange,
    this.resolution = 50,
    this.opcoes,
  });

  Map<String, dynamic> toJson() {
    return {
      'funcao': funcao,
      'x_range': xRange,
      'y_range': yRange,
      'resolution': resolution,
      if (opcoes != null) ...opcoes!,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class VectorField3DRequest {
  final String fx;
  final String fy;
  final String fz;
  final List<double> xRange;
  final List<double> yRange;
  final List<double> zRange;
  final int resolution;

  VectorField3DRequest({
    required this.fx,
    required this.fy,
    required this.fz,
    required this.xRange,
    required this.yRange,
    required this.zRange,
    this.resolution = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'fx': fx,
      'fy': fy,
      'fz': fz,
      'x_range': xRange,
      'y_range': yRange,
      'z_range': zRange,
      'resolution': resolution,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class ParametricSurface3DRequest {
  final String fx;
  final String fy;
  final String fz;
  final List<double> uRange;
  final List<double> vRange;
  final int resolution;

  ParametricSurface3DRequest({
    required this.fx,
    required this.fy,
    required this.fz,
    required this.uRange,
    required this.vRange,
    this.resolution = 50,
  });

  Map<String, dynamic> toJson() {
    return {
      'fx': fx,
      'fy': fy,
      'fz': fz,
      'u_range': uRange,
      'v_range': vRange,
      'resolution': resolution,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class IntegrationVolume3DRequest {
  final String funcao;
  final List<double> xRange;
  final List<double> yRange;
  final int resolution;

  IntegrationVolume3DRequest({
    required this.funcao,
    required this.xRange,
    required this.yRange,
    this.resolution = 50,
  });

  Map<String, dynamic> toJson() {
    return {
      'funcao': funcao,
      'x_range': xRange,
      'y_range': yRange,
      'resolution': resolution,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class Visualization3DResponse {
  final bool sucesso;
  final String? plotlyJson;
  final String? erro;
  final DateTime calculadoEm;
  final Map<String, dynamic>? metadados;
  final String? cacheInfo;

  Visualization3DResponse({
    required this.sucesso,
    this.plotlyJson,
    this.erro,
    required this.calculadoEm,
    this.metadados,
    this.cacheInfo,
  });

  factory Visualization3DResponse.fromJson(Map<String, dynamic> json) {
    return Visualization3DResponse(
      sucesso: json['sucesso'] ?? false,
      plotlyJson: json['plotly_json'],
      erro: json['erro'],
      calculadoEm:
          DateTime.tryParse(json['calculado_em'] ?? '') ?? DateTime.now(),
      metadados: json['metadados'],
      cacheInfo: json['cache_info'],
    );
  }

  bool get temVisualizacao =>
      sucesso && plotlyJson != null && plotlyJson!.isNotEmpty;
}
