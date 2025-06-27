import 'package:flutter/material.dart';
import '../../data/models/performance_models.dart';
import '../../data/services/api_service.dart';

class PerformanceDashboardWidget extends StatefulWidget {
  const PerformanceDashboardWidget({super.key});

  @override
  State<PerformanceDashboardWidget> createState() =>
      _PerformanceDashboardWidgetState();
}

class _PerformanceDashboardWidgetState
    extends State<PerformanceDashboardWidget> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  PerformanceSummaryResponse? _performanceSummary;
  CacheStatsResponse? _cacheStats;
  PrecisionAnalysisResponse? _precisionAnalysis;
  SecurityStatsResponse? _securityStats;

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  Future<void> _carregarDashboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carrega todas as métricas em paralelo
      final futures = await Future.wait([
        _apiService.obterResumoPerformance(),
        _apiService.obterEstatisticasCache(),
        _apiService.obterAnalisesPrecisao(),
        _apiService.obterEstatisticasSeguranca(),
      ]);

      setState(() {
        _performanceSummary = futures[0] as PerformanceSummaryResponse;
        _cacheStats = futures[1] as CacheStatsResponse;
        _precisionAnalysis = futures[2] as PrecisionAnalysisResponse;
        _securityStats = futures[3] as SecurityStatsResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Erro ao carregar dashboard: $e');
    }
  }

  void _mostrarErro(String erro) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.dashboard, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Dashboard de Performance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _carregarDashboard,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Carregando métricas...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                      : _buildDashboardContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Resumo geral de performance
          if (_performanceSummary?.sucesso == true) ...[
            _buildPerformanceOverview(),
            const SizedBox(height: 16),
          ],

          // Grid com métricas principais
          Row(
            children: [
              // Cache Stats
              if (_cacheStats?.sucesso == true)
                Expanded(child: _buildCacheStatsCard()),

              const SizedBox(width: 12),

              // Precision Analysis
              if (_precisionAnalysis?.sucesso == true)
                Expanded(child: _buildPrecisionCard()),
            ],
          ),

          const SizedBox(height: 12),

          // Segurança
          if (_securityStats?.sucesso == true) ...[_buildSecurityCard()],
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    final summary = _performanceSummary!.summary!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Resumo de Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Total de Cálculos',
                  '${summary.totalCalculations}',
                  Icons.calculate,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Tempo Médio',
                  summary.averageTimeFormatted,
                  Icons.timer,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Taxa de Sucesso',
                  summary.successRateFormatted,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Cache Hit Rate',
                  summary.cacheHitRateFormatted,
                  Icons.memory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCacheStatsCard() {
    final stats = _cacheStats!.stats!;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Cache',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            stats.hitRateFormatted,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Hit Rate',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: stats.usagePercentage,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.green),
          ),
          const SizedBox(height: 4),
          Text(
            'Uso: ${stats.usageFormatted}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecisionCard() {
    final analysis = _precisionAnalysis!.analysis!;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.precision_manufacturing,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'Precisão',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            analysis.qualityLevel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Qualidade',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 8),

          Text(
            'Erro médio: ${analysis.averageErrorFormatted}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            'Cálculos precisos: ${analysis.highPrecisionCalculations}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    final stats = _securityStats!.stats!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Segurança',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Nível de Ameaça',
                  stats.threatLevelDescription,
                  Icons.warning,
                  color: _getThreatLevelColor(stats.threatLevel),
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Requisições Bloqueadas',
                  stats.blockRateFormatted,
                  Icons.block,
                ),
              ),
            ],
          ),

          if (stats.topBlockedIps?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            const Text(
              'IPs mais bloqueados:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...stats.topBlockedIps!.entries
                .take(3)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${entry.value}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color ?? Colors.white70, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getThreatLevelColor(double threatLevel) {
    if (threatLevel < 0.2) return Colors.green;
    if (threatLevel < 0.5) return Colors.orange;
    if (threatLevel < 0.8) return Colors.red;
    return Colors.purple;
  }
}
