import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/visualization_3d_widget.dart';
import '../widgets/ml_analysis_widget.dart';
import '../widgets/performance_dashboard_widget.dart';

class AdvancedFeaturesScreen extends StatefulWidget {
  const AdvancedFeaturesScreen({super.key});

  @override
  State<AdvancedFeaturesScreen> createState() => _AdvancedFeaturesScreenState();
}

class _AdvancedFeaturesScreenState extends State<AdvancedFeaturesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _funcaoController = TextEditingController();
  final TextEditingController _xMinController = TextEditingController(
    text: '-2',
  );
  final TextEditingController _xMaxController = TextEditingController(
    text: '2',
  );
  final TextEditingController _yMinController = TextEditingController(
    text: '-2',
  );
  final TextEditingController _yMaxController = TextEditingController(
    text: '2',
  );

  String _selectedVisualizationType = 'surface';
  bool _showVisualization = false;
  bool _showMLAnalysis = false;

  @override
  void initState() {
    super.initState();

    // Verifica se há argumentos da navegação
    final arguments = Get.arguments as Map<String, dynamic>?;
    final focusTab = arguments?['focusTab'] as int? ?? 0;
    final funcao = arguments?['funcao'] as String?;

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: focusTab,
    );

    // Define a função recebida ou usa a padrão
    _funcaoController.text = funcao ?? 'x**2 + y**2';

    // Se veio uma função da calculadora, já exibe a visualização
    if (funcao != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showVisualization = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _funcaoController.dispose();
    _xMinController.dispose();
    _xMaxController.dispose();
    _yMinController.dispose();
    _yMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Funcionalidades Avançadas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.threed_rotation), text: 'Visualização 3D'),
            Tab(icon: Icon(Icons.psychology), text: 'Análise IA'),
            Tab(icon: Icon(Icons.dashboard), text: 'Performance'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildVisualization3DTab(),
            _buildMLAnalysisTab(),
            _buildPerformanceTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualization3DTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Formulário de entrada
          Card(
            color: Colors.white.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuração da Visualização 3D',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Função
                  TextField(
                    controller: _funcaoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Função f(x,y)',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: 'Ex: x**2 + y**2',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Intervalos
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _xMinController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'X mín',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _xMaxController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'X máx',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _yMinController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Y mín',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _yMaxController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Y máx',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tipo de visualização
                  DropdownButtonFormField<String>(
                    value: _selectedVisualizationType,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF667eea),
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Visualização',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'surface',
                        child: Text('Superfície 3D'),
                      ),
                      DropdownMenuItem(
                        value: 'contour',
                        child: Text('Contornos 3D'),
                      ),
                      DropdownMenuItem(
                        value: 'volume',
                        child: Text('Volume de Integração'),
                      ),
                      DropdownMenuItem(
                        value: 'gradient',
                        child: Text('Campo Gradiente'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedVisualizationType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botão
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _gerarVisualizacao3D,
                      icon: const Icon(Icons.threed_rotation),
                      label: const Text('Gerar Visualização 3D'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Visualização
          if (_showVisualization)
            Expanded(
              child: Visualization3DWidget(
                funcao: _funcaoController.text,
                xRange: [
                  double.tryParse(_xMinController.text) ?? -2,
                  double.tryParse(_xMaxController.text) ?? 2,
                ],
                yRange: [
                  double.tryParse(_yMinController.text) ?? -2,
                  double.tryParse(_yMaxController.text) ?? 2,
                ],
                type: _selectedVisualizationType,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMLAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Formulário de entrada
          Card(
            color: Colors.white.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Análise Inteligente com IA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Função
                  TextField(
                    controller: _funcaoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Função f(x)',
                      labelStyle: TextStyle(color: Colors.white70),
                      hintText: 'Ex: x**2 + sin(x)',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _analisarComIA,
                      icon: const Icon(Icons.psychology),
                      label: const Text('Analisar com IA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Análise ML
          if (_showMLAnalysis)
            Expanded(
              child: MLAnalysisWidget(
                funcao: _funcaoController.text,
                interval: [
                  double.tryParse(_xMinController.text) ?? -2,
                  double.tryParse(_xMaxController.text) ?? 2,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: PerformanceDashboardWidget(),
    );
  }

  void _gerarVisualizacao3D() {
    if (_funcaoController.text.trim().isEmpty) {
      _mostrarErro('Por favor, insira uma função');
      return;
    }

    setState(() {
      _showVisualization = true;
    });
  }

  void _analisarComIA() {
    if (_funcaoController.text.trim().isEmpty) {
      _mostrarErro('Por favor, insira uma função');
      return;
    }

    setState(() {
      _showMLAnalysis = true;
    });
  }

  void _mostrarErro(String erro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(erro),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
