import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/performance/performance_config.dart';
import '../../data/models/funcao_matematica.dart';
import 'dart:math' as math;

class GraficoInterativo extends StatefulWidget {
  final FuncaoMatematica? funcao;
  final double? intervaloA;
  final double? intervaloB;
  final bool mostrarArea;
  final double? areaCalculada;

  const GraficoInterativo({
    super.key,
    this.funcao,
    this.intervaloA,
    this.intervaloB,
    this.mostrarArea = false,
    this.areaCalculada,
  });

  @override
  State<GraficoInterativo> createState() => _GraficoInterativoState();
}

class _GraficoInterativoState extends State<GraficoInterativo> {
  double _minX = -5.0;
  double _maxX = 5.0;
  double _minY = -10.0;
  double _maxY = 10.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          // Header do gráfico
          Row(
            children: [
              const Icon(Icons.show_chart, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.funcao != null
                      ? 'f(x) = ${widget.funcao!.expressaoFormatada}'
                      : 'Gráfico da Função',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Controles de zoom
              IconButton(
                onPressed: _zoomIn,
                icon: const Icon(Icons.zoom_in, color: AppColors.textSecondary),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: _zoomOut,
                icon: const Icon(
                  Icons.zoom_out,
                  color: AppColors.textSecondary,
                ),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: _resetZoom,
                icon: const Icon(
                  Icons.center_focus_strong,
                  color: AppColors.textSecondary,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico
          Expanded(
            child: widget.funcao != null ? _buildChart() : _buildPlaceholder(),
          ),

          // Informações da área (se calculada)
          if (widget.mostrarArea && widget.areaCalculada != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.integralColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusSmall,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.area_chart,
                    color: AppColors.integralColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Área: ${widget.areaCalculada!.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: AppColors.integralColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.intervaloA != null &&
                      widget.intervaloB != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      'em [${widget.intervaloA}, ${widget.intervaloB}]',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart() {
    final spots = _gerarPontosFuncao();
    final areaSpots = widget.mostrarArea ? _gerarPontosArea() : <FlSpot>[];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: (_maxY - _minY) / 10,
          verticalInterval: (_maxX - _minX) / 10,
          getDrawingHorizontalLine:
              (value) => FlLine(color: AppColors.glassBorder, strokeWidth: 0.5),
          getDrawingVerticalLine:
              (value) => FlLine(color: AppColors.glassBorder, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget:
                  (value, meta) => Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget:
                  (value, meta) => Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.glassBorder),
        ),
        minX: _minX,
        maxX: _maxX,
        minY: _minY,
        maxY: _maxY,
        lineBarsData: [
          // Função principal
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.graphFunction,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
          // Área sob a curva (se habilitada)
          if (widget.mostrarArea && areaSpots.isNotEmpty)
            LineChartBarData(
              spots: areaSpots,
              isCurved: true,
              color: AppColors.integralColor.withValues(alpha: 0.3),
              barWidth: 1,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.integralColor.withValues(alpha: 0.2),
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: PerformanceConfig.shouldUseComplexAnimations,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.backgroundSurface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  'x: ${spot.x.toStringAsFixed(2)}\ny: ${spot.y.toStringAsFixed(2)}',
                  const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.functions,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Digite uma função para ver o gráfico',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<FlSpot> _gerarPontosFuncao() {
    final spots = <FlSpot>[];
    // Adaptar número de pontos baseado na performance
    final numPoints = PerformanceConfig.shouldUseComplexAnimations ? 200 : 100;
    final step = (_maxX - _minX) / numPoints;

    for (double x = _minX; x <= _maxX; x += step) {
      try {
        final y = _calcularFuncao(x);
        if (y.isFinite && y >= _minY && y <= _maxY) {
          spots.add(FlSpot(x, y));
        }
      } catch (e) {
        // Ignora pontos inválidos
      }
    }

    return spots;
  }

  List<FlSpot> _gerarPontosArea() {
    if (widget.intervaloA == null || widget.intervaloB == null) return [];

    final spots = <FlSpot>[];
    final a = widget.intervaloA!;
    final b = widget.intervaloB!;
    // Reduzir pontos na área para melhor performance
    final numPoints = PerformanceConfig.shouldUseComplexAnimations ? 100 : 50;
    final step = (b - a) / numPoints;

    // Adiciona ponto inicial no eixo x
    spots.add(FlSpot(a, 0));

    // Pontos da função no intervalo
    for (double x = a; x <= b; x += step) {
      try {
        final y = _calcularFuncao(x);
        if (y.isFinite) {
          spots.add(FlSpot(x, y));
        }
      } catch (e) {
        // Ignora pontos inválidos
      }
    }

    // Adiciona ponto final no eixo x
    spots.add(FlSpot(b, 0));

    return spots;
  }

  double _calcularFuncao(double x) {
    if (widget.funcao == null) return 0;

    final expressao = widget.funcao!.expressao.toLowerCase();

    // Parser simplificado para demonstração
    try {
      if (expressao == 'x') {
        return x;
      } else if (expressao == 'x^2') {
        return x * x;
      } else if (expressao == 'x^3') {
        return x * x * x;
      } else if (expressao.contains('sin(x)')) {
        return math.sin(x);
      } else if (expressao.contains('cos(x)')) {
        return math.cos(x);
      } else if (expressao.contains('tan(x)')) {
        return math.tan(x);
      } else if (expressao.contains('ln(x)')) {
        return x > 0 ? math.log(x) : double.nan;
      } else if (expressao.contains('sqrt(x)')) {
        return x >= 0 ? math.sqrt(x) : double.nan;
      } else if (expressao.contains('e^x')) {
        return math.exp(x);
      } else {
        // Tenta parsear como polinômio simples
        return _parsePolinomio(expressao, x);
      }
    } catch (e) {
      return double.nan;
    }
  }

  double _parsePolinomio(String expressao, double x) {
    // Parser muito simples para polinômios como "2*x + 3" ou "x^2 - 3*x + 1"
    // Remove espaços
    expressao = expressao.replaceAll(' ', '');

    // Implementação simplificada - retorna x^2 como padrão para demonstração
    return x * x;
  }

  void _zoomIn() {
    setState(() {
      final centerX = (_minX + _maxX) / 2;
      final centerY = (_minY + _maxY) / 2;
      final rangeX = (_maxX - _minX) * 0.8;
      final rangeY = (_maxY - _minY) * 0.8;

      _minX = centerX - rangeX / 2;
      _maxX = centerX + rangeX / 2;
      _minY = centerY - rangeY / 2;
      _maxY = centerY + rangeY / 2;
    });
  }

  void _zoomOut() {
    setState(() {
      final centerX = (_minX + _maxX) / 2;
      final centerY = (_minY + _maxY) / 2;
      final rangeX = (_maxX - _minX) * 1.2;
      final rangeY = (_maxY - _minY) * 1.2;

      _minX = centerX - rangeX / 2;
      _maxX = centerX + rangeX / 2;
      _minY = centerY - rangeY / 2;
      _maxY = centerY + rangeY / 2;
    });
  }

  void _resetZoom() {
    setState(() {
      _minX = -5.0;
      _maxX = 5.0;
      _minY = -10.0;
      _maxY = 10.0;
    });
  }
}
