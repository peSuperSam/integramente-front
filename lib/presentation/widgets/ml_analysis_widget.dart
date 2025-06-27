import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/ml_models.dart';
import '../../data/services/api_service.dart';

class MLAnalysisWidget extends StatefulWidget {
  final String funcao;
  final List<double>? interval;

  const MLAnalysisWidget({super.key, required this.funcao, this.interval});

  @override
  State<MLAnalysisWidget> createState() => _MLAnalysisWidgetState();
}

class _MLAnalysisWidgetState extends State<MLAnalysisWidget> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  MLAnalysisResponse? _analysis;
  MLIntegrationDifficultyResponse? _difficulty;
  MLComputationTimeResponse? _timeEstimate;
  MLOptimalResolutionResponse? _optimalResolution;

  @override
  void initState() {
    super.initState();
    _carregarAnalises();
  }

  Future<void> _carregarAnalises() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Executa todas as análises em paralelo
      final futures = await Future.wait([
        _apiService.analisarFuncaoML(funcao: widget.funcao),
        _apiService.predizerDificuldadeIntegracao(
          funcao: widget.funcao,
          interval: widget.interval,
        ),
        _apiService.estimarTempoComputacao(
          funcao: widget.funcao,
          interval: widget.interval,
        ),
        _apiService.predizerResolucaoOtima(
          funcao: widget.funcao,
          interval: widget.interval,
        ),
      ]);

      setState(() {
        _analysis = futures[0] as MLAnalysisResponse;
        _difficulty = futures[1] as MLIntegrationDifficultyResponse;
        _timeEstimate = futures[2] as MLComputationTimeResponse;
        _optimalResolution = futures[3] as MLOptimalResolutionResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Erro ao carregar análises ML: $e');
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
            color: Colors.black.withOpacity(0.1),
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
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Análise Inteligente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'f(x) = ${widget.funcao}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _carregarAnalises,
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
                              'Analisando função com IA...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                      : _buildAnalysisResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_analysis?.sucesso == true) ...[
            _buildAnalysisCard(
              title: 'Características da Função',
              icon: Icons.analytics,
              child: _buildCharacteristicsInfo(),
            ),
            const SizedBox(height: 12),
          ],

          if (_difficulty?.sucesso == true) ...[
            _buildAnalysisCard(
              title: 'Dificuldade de Integração',
              icon: Icons.speed,
              child: _buildDifficultyInfo(),
            ),
            const SizedBox(height: 12),
          ],

          if (_timeEstimate?.sucesso == true) ...[
            _buildAnalysisCard(
              title: 'Tempo Estimado',
              icon: Icons.timer,
              child: _buildTimeEstimateInfo(),
            ),
            const SizedBox(height: 12),
          ],

          if (_optimalResolution?.sucesso == true) ...[
            _buildAnalysisCard(
              title: 'Resolução Recomendada',
              icon: Icons.tune,
              child: _buildOptimalResolutionInfo(),
            ),
            const SizedBox(height: 12),
          ],

          if (_analysis?.recommendations?.isNotEmpty == true) ...[
            _buildAnalysisCard(
              title: 'Recomendações IA',
              icon: Icons.lightbulb,
              child: _buildRecommendationsInfo(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCharacteristicsInfo() {
    final characteristics = _analysis!.characteristics;
    if (characteristics == null) {
      return const Text(
        'Características não disponíveis',
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      children: [
        _buildPropertyRow('Tipo', _analysis!.functionType ?? 'Desconhecido'),
        _buildPropertyRow(
          'Complexidade',
          '${(characteristics.complexityScore * 100).toStringAsFixed(1)}%',
        ),
        _buildPropertyRow(
          'Monotônica',
          characteristics.isMonotonic ? 'Sim' : 'Não',
        ),
        _buildPropertyRow(
          'Oscilatória',
          characteristics.isOscillatory ? 'Sim' : 'Não',
        ),
        _buildPropertyRow('Paridade', _getParityDescription(characteristics)),
        if (characteristics.isPeriodic) _buildPropertyRow('Periódica', 'Sim'),
      ],
    );
  }

  Widget _buildDifficultyInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nível de Dificuldade:',
              style: TextStyle(color: Colors.white70),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDifficultyColor(),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _difficulty!.difficultyLevel ?? 'Desconhecido',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (_difficulty!.difficultyScore != null) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _difficulty!.difficultyScore!,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(_getDifficultyColor()),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_difficulty!.difficultyScore! * 100).toStringAsFixed(1)}% de dificuldade',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
        if (_difficulty!.factors?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          const Text(
            'Fatores de Complexidade:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...(_difficulty!.factors!.map(
            (factor) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.white70, size: 6),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      factor,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildTimeEstimateInfo() {
    return Column(
      children: [
        _buildPropertyRow(
          'Tempo Estimado',
          _timeEstimate!.estimatedTimeFormatted,
        ),
        if (_timeEstimate!.confidence != null)
          _buildPropertyRow('Confiança', _timeEstimate!.confidence!),
      ],
    );
  }

  Widget _buildOptimalResolutionInfo() {
    return Column(
      children: [
        _buildPropertyRow(
          'Resolução Recomendada',
          '${_optimalResolution!.optimalResolution ?? 'Padrão'}',
        ),
        if (_optimalResolution!.reasoning != null) ...[
          const SizedBox(height: 8),
          Text(
            _optimalResolution!.reasoning!,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.justify,
          ),
        ],
      ],
    );
  }

  Widget _buildRecommendationsInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...(_analysis!.recommendations!.map(
          (recommendation) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getParityDescription(FunctionCharacteristics characteristics) {
    if (characteristics.isEven) return 'Par';
    if (characteristics.isOdd) return 'Ímpar';
    return 'Nem par nem ímpar';
  }

  Color _getDifficultyColor() {
    if (_difficulty?.difficultyScore == null) return Colors.grey;

    final score = _difficulty!.difficultyScore!;
    if (score < 0.3) return Colors.green;
    if (score < 0.6) return Colors.orange;
    if (score < 0.8) return Colors.red;
    return Colors.purple;
  }
}
