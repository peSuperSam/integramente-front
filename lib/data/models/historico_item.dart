import 'package:equatable/equatable.dart';
import 'funcao_matematica.dart';
import 'calculo_response.dart';

enum TipoCalculo { area, simbolico }

class HistoricoItem extends Equatable {
  final String id;
  final FuncaoMatematica funcao;
  final TipoCalculo tipo;
  final DateTime criadoEm;
  final bool isFavorito;
  final double? intervaloA;
  final double? intervaloB;
  final CalculoAreaResponse? resultadoArea;
  final CalculoSimbolicoResponse? resultadoSimbolico;
  final String? miniaturalGrafico; // Base64 da miniatura

  const HistoricoItem({
    required this.id,
    required this.funcao,
    required this.tipo,
    required this.criadoEm,
    this.isFavorito = false,
    this.intervaloA,
    this.intervaloB,
    this.resultadoArea,
    this.resultadoSimbolico,
    this.miniaturalGrafico,
  });

  factory HistoricoItem.area({
    required FuncaoMatematica funcao,
    required double intervaloA,
    required double intervaloB,
    CalculoAreaResponse? resultado,
  }) {
    return HistoricoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      funcao: funcao,
      tipo: TipoCalculo.area,
      criadoEm: DateTime.now(),
      intervaloA: intervaloA,
      intervaloB: intervaloB,
      resultadoArea: resultado,
    );
  }

  factory HistoricoItem.simbolico({
    required FuncaoMatematica funcao,
    CalculoSimbolicoResponse? resultado,
  }) {
    return HistoricoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      funcao: funcao,
      tipo: TipoCalculo.simbolico,
      criadoEm: DateTime.now(),
      resultadoSimbolico: resultado,
    );
  }

  HistoricoItem copyWith({
    String? id,
    FuncaoMatematica? funcao,
    TipoCalculo? tipo,
    DateTime? criadoEm,
    bool? isFavorito,
    double? intervaloA,
    double? intervaloB,
    CalculoAreaResponse? resultadoArea,
    CalculoSimbolicoResponse? resultadoSimbolico,
    String? miniaturalGrafico,
  }) {
    return HistoricoItem(
      id: id ?? this.id,
      funcao: funcao ?? this.funcao,
      tipo: tipo ?? this.tipo,
      criadoEm: criadoEm ?? this.criadoEm,
      isFavorito: isFavorito ?? this.isFavorito,
      intervaloA: intervaloA ?? this.intervaloA,
      intervaloB: intervaloB ?? this.intervaloB,
      resultadoArea: resultadoArea ?? this.resultadoArea,
      resultadoSimbolico: resultadoSimbolico ?? this.resultadoSimbolico,
      miniaturalGrafico: miniaturalGrafico ?? this.miniaturalGrafico,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'funcao': funcao.toJson(),
      'tipo': tipo.toString(),
      'criadoEm': criadoEm.toIso8601String(),
      'isFavorito': isFavorito,
      'intervaloA': intervaloA,
      'intervaloB': intervaloB,
      'resultadoArea': resultadoArea?.toJson(),
      'resultadoSimbolico': resultadoSimbolico?.toJson(),
      'miniaturalGrafico': miniaturalGrafico,
    };
  }

  factory HistoricoItem.fromJson(Map<String, dynamic> json) {
    return HistoricoItem(
      id: json['id'],
      funcao: FuncaoMatematica.fromJson(json['funcao']),
      tipo: TipoCalculo.values.firstWhere((e) => e.toString() == json['tipo']),
      criadoEm: DateTime.parse(json['criadoEm']),
      isFavorito: json['isFavorito'] ?? false,
      intervaloA: json['intervaloA']?.toDouble(),
      intervaloB: json['intervaloB']?.toDouble(),
      resultadoArea:
          json['resultadoArea'] != null
              ? CalculoAreaResponse.fromJson(json['resultadoArea'])
              : null,
      resultadoSimbolico:
          json['resultadoSimbolico'] != null
              ? CalculoSimbolicoResponse.fromJson(json['resultadoSimbolico'])
              : null,
      miniaturalGrafico: json['miniaturalGrafico'],
    );
  }

  // Getters de conveniência
  bool get temResultado =>
      (tipo == TipoCalculo.area && resultadoArea != null) ||
      (tipo == TipoCalculo.simbolico && resultadoSimbolico != null);

  bool get calculoComSucesso =>
      (resultadoArea?.sucesso ?? false) ||
      (resultadoSimbolico?.sucesso ?? false);

  String get descricaoResultado {
    if (tipo == TipoCalculo.area && resultadoArea != null) {
      return 'Área: ${resultadoArea!.areaTotal?.toStringAsFixed(4) ?? "N/A"}';
    } else if (tipo == TipoCalculo.simbolico && resultadoSimbolico != null) {
      return 'Antiderivada: ${resultadoSimbolico!.antiderivada ?? "N/A"}';
    }
    return 'Sem resultado';
  }

  String get descricaoCompleta {
    final intervalo =
        intervaloA != null && intervaloB != null
            ? ' em [$intervaloA, $intervaloB]'
            : '';
    return '${funcao.expressaoFormatada}$intervalo';
  }

  @override
  List<Object?> get props => [
    id,
    funcao,
    tipo,
    criadoEm,
    isFavorito,
    intervaloA,
    intervaloB,
    resultadoArea,
    resultadoSimbolico,
    miniaturalGrafico,
  ];

  @override
  String toString() {
    return 'HistoricoItem(id: $id, funcao: ${funcao.expressao}, tipo: $tipo)';
  }
}
