import 'package:flutter/material.dart';
import '../../data/models/visualization_3d_models.dart';
import '../../data/services/api_service.dart';

class Visualization3DWidget extends StatefulWidget {
  final String funcao;
  final List<double> xRange;
  final List<double> yRange;
  final String type; // 'surface', 'contour', 'volume', 'gradient'
  final Map<String, dynamic>? opcoes;

  const Visualization3DWidget({
    super.key,
    required this.funcao,
    required this.xRange,
    required this.yRange,
    required this.type,
    this.opcoes,
  });

  @override
  State<Visualization3DWidget> createState() => _Visualization3DWidgetState();
}

class _Visualization3DWidgetState extends State<Visualization3DWidget> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _erro;
  Visualization3DResponse? _response;

  @override
  void initState() {
    super.initState();
    _carregarVisualizacao();
  }

  Future<void> _carregarVisualizacao() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      Visualization3DResponse response;

      switch (widget.type) {
        case 'surface':
          response = await _apiService.gerarSuperficie3D(
            funcao: widget.funcao,
            xRange: widget.xRange,
            yRange: widget.yRange,
            opcoes: widget.opcoes,
          );
          break;
        case 'contour':
          response = await _apiService.gerarContorno3D(
            funcao: widget.funcao,
            xRange: widget.xRange,
            yRange: widget.yRange,
            opcoes: widget.opcoes,
          );
          break;
        case 'volume':
          response = await _apiService.gerarVolumeIntegracao3D(
            funcao: widget.funcao,
            xRange: widget.xRange,
            yRange: widget.yRange,
          );
          break;
        case 'gradient':
          response = await _apiService.gerarCampoGradiente3D(
            funcao: widget.funcao,
            xRange: widget.xRange,
            yRange: widget.yRange,
          );
          break;
        default:
          throw Exception('Tipo de visualização não suportado: ${widget.type}');
      }

      setState(() {
        _response = response;
        _isLoading = false;
      });

      if (!response.sucesso) {
        _erro = response.erro ?? 'Erro desconhecido ao gerar visualização';
        _mostrarErro(_erro!);
      }
    } catch (e) {
      setState(() {
        _erro = 'Erro ao conectar com o servidor: $e';
        _isLoading = false;
      });
      _mostrarErro(_erro!);
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
                  Icon(_getTypeIcon(), color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTypeTitle(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'f(x,y) = ${widget.funcao}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_response?.cacheInfo != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'CACHE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: _carregarVisualizacao,
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
                              'Gerando visualização 3D...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                      : _erro != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Erro na Visualização',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                _erro!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _carregarVisualizacao,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar Novamente'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667eea),
                              ),
                            ),
                          ],
                        ),
                      )
                      : _buildVisualizationInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizationInfo() {
    if (_response == null || !_response!.sucesso) {
      return const Center(
        child: Text(
          'Visualização não disponível',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 64),
          const SizedBox(height: 24),
          const Text(
            'Visualização 3D Gerada!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getTypeDescription(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_response!.metadados != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Informações da Visualização',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildMetadataInfo(),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Para visualizar o gráfico 3D interativo, acesse o backend diretamente.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMetadataInfo() {
    final metadata = _response!.metadados!;
    final widgets = <Widget>[];

    if (metadata.containsKey('execution_time')) {
      widgets.add(
        _buildInfoRow(
          'Tempo de Execução',
          '${metadata['execution_time']?.toStringAsFixed(3)}s',
        ),
      );
    }

    if (metadata.containsKey('points_generated')) {
      widgets.add(
        _buildInfoRow('Pontos Gerados', '${metadata['points_generated']}'),
      );
    }

    if (metadata.containsKey('resolution')) {
      widgets.add(
        _buildInfoRow(
          'Resolução',
          '${metadata['resolution']}x${metadata['resolution']}',
        ),
      );
    }

    return widgets;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case 'surface':
        return Icons.terrain;
      case 'contour':
        return Icons.waves;
      case 'volume':
        return Icons.view_in_ar;
      case 'gradient':
        return Icons.arrow_upward;
      default:
        return Icons.threed_rotation;
    }
  }

  String _getTypeTitle() {
    switch (widget.type) {
      case 'surface':
        return 'Superfície 3D';
      case 'contour':
        return 'Contornos 3D';
      case 'volume':
        return 'Volume de Integração';
      case 'gradient':
        return 'Campo Gradiente';
      default:
        return 'Visualização 3D';
    }
  }

  String _getTypeDescription() {
    switch (widget.type) {
      case 'surface':
        return 'Superfície tridimensional da função f(x,y) mostrando como os valores mudam no espaço.';
      case 'contour':
        return 'Linhas de contorno 3D mostrando curvas de nível da função em diferentes alturas.';
      case 'volume':
        return 'Visualização do volume sob a superfície para cálculo de integrais duplas.';
      case 'gradient':
        return 'Campo vetorial do gradiente mostrando a direção de maior crescimento da função.';
      default:
        return 'Visualização tridimensional da função matemática.';
    }
  }
}
