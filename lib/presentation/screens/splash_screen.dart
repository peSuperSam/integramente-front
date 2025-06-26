import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_state.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/performance/performance_monitor.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/api_service.dart';
import '../controllers/app_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _textController;

  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _slideAnimation;

  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  // Estados de carregamento
  bool _servicesInitialized = false;
  bool _controllersInitialized = false;
  bool _configsLoaded = false;
  bool _apiConnected = false;
  bool _resourcesPreloaded = false;

  String _currentLoadingStep = 'Inicializando...';
  double _progress = 0.0;

  final List<String> _loadingSteps = [
    'Inicializando serviços...',
    'Carregando controladores...',
    'Verificando configurações...',
    'Testando conexão com API...',
    'Pré-carregando recursos...',
    'Finalizando...',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingProcess();
  }

  void _initializeAnimations() {
    // Animação do logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Animação do progresso
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Animação do texto
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Iniciar animações
    _logoController.forward();
    _textController.forward();
  }

  Future<void> _startLoadingProcess() async {
    try {
      await _performanceMonitor.measureAsync('splash_loading', () async {
        // Passo 1: Inicializar serviços
        await _initializeServices();

        // Passo 2: Inicializar controladores
        await _initializeControllers();

        // Passo 3: Carregar configurações
        await _loadConfigurations();

        // Passo 4: Testar API
        await _testApiConnection();

        // Passo 5: Pré-carregar recursos
        await _preloadResources();

        // Passo 6: Finalizar
        await _finalizeLoading();
      });
    } catch (e) {
      debugPrint('Erro durante carregamento: $e');
      // Mesmo com erro, continuar para o app
      _navigateToHome();
    }
  }

  Future<void> _initializeServices() async {
    _updateProgress(0, _loadingSteps[0]);

    try {
      // Inicializar serviços essenciais
      if (!Get.isRegistered<StorageService>()) {
        Get.put(StorageService());
      }

      if (!Get.isRegistered<ApiService>()) {
        Get.put(ApiService());
      }

      // Aguardar inicialização
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _servicesInitialized = true;
      });

      debugPrint('✅ Serviços inicializados');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar serviços: $e');
    }
  }

  Future<void> _initializeControllers() async {
    _updateProgress(1, _loadingSteps[1]);

    try {
      // Inicializar controlador principal
      if (!Get.isRegistered<AppController>()) {
        Get.put(AppController());
      }

      // Aguardar inicialização do controlador
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _controllersInitialized = true;
      });

      debugPrint('✅ Controladores inicializados');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar controladores: $e');
    }
  }

  Future<void> _loadConfigurations() async {
    _updateProgress(2, _loadingSteps[2]);

    try {
      final storageService = Get.find<StorageService>();

      // Carregar configurações salvas
      final configs = await storageService.getConfiguracoes();
      debugPrint('📋 Configurações carregadas: ${configs.keys.length} itens');

      // Carregar histórico
      final historico = await storageService.getHistorico();
      debugPrint('📚 Histórico carregado: ${historico.length} itens');

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _configsLoaded = true;
      });

      debugPrint('✅ Configurações carregadas');
    } catch (e) {
      debugPrint('❌ Erro ao carregar configurações: $e');
      setState(() {
        _configsLoaded = true; // Continuar mesmo com erro
      });
    }
  }

  Future<void> _testApiConnection() async {
    _updateProgress(3, _loadingSteps[3]);

    try {
      final apiService = Get.find<ApiService>();

      // Testar conexão com timeout
      final isConnected = await apiService.verificarConexao().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );

      await Future.delayed(const Duration(milliseconds: 400));

      setState(() {
        _apiConnected = isConnected;
      });

      if (isConnected) {
        debugPrint('✅ API conectada');
      } else {
        debugPrint('⚠️ API offline - modo local ativo');
      }
    } catch (e) {
      debugPrint('❌ Erro ao testar API: $e');
      setState(() {
        _apiConnected = false; // Modo offline
      });
    }
  }

  Future<void> _preloadResources() async {
    _updateProgress(4, _loadingSteps[4]);

    try {
      // Pré-carregar assets críticos se existirem
      // await Future.wait([
      //   precacheImage(const AssetImage('assets/icons/app_icon.png'), context),
      // ]);

      // Simular carregamento de outros recursos
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _resourcesPreloaded = true;
      });

      debugPrint('✅ Recursos pré-carregados');
    } catch (e) {
      debugPrint('❌ Erro ao pré-carregar recursos: $e');
      setState(() {
        _resourcesPreloaded = true; // Continuar mesmo com erro
      });
    }
  }

  Future<void> _finalizeLoading() async {
    _updateProgress(5, _loadingSteps[5]);

    // Aguardar um pouco para mostrar 100%
    await Future.delayed(const Duration(milliseconds: 800));

    // Garantir que todas as animações terminaram
    await _progressController.forward();

    debugPrint('🚀 Carregamento finalizado');

    // Navegar para home
    _navigateToHome();
  }

  void _updateProgress(int step, String message) {
    setState(() {
      _currentLoadingStep = message;
      _progress = (step + 1) / _loadingSteps.length;
    });

    _progressController.reset();
    _progressController.forward();
  }

  void _navigateToHome() {
    // Marcar splash como completado no AppState
    final appState = Get.find<AppState>();
    appState.completeSplash();
    appState.markAppInitialized();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveHelper.getHorizontalPadding(context),
          ),
          child: Column(
            children: [
              // Logo e branding
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animado
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Container(
                              width:
                                  ResponsiveHelper.isMobile(context)
                                      ? 150
                                      : 180,
                              height:
                                  ResponsiveHelper.isMobile(context)
                                      ? 150
                                      : 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 25,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Image.asset(
                                    'assets/icons/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback para ícone se a imagem não carregar
                                      return Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.primary,
                                              AppColors.integralColor,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.functions,
                                          color: Colors.white,
                                          size: 80,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Título animado
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _textAnimation,
                          child: Column(
                            children: [
                              Text(
                                'IntegraMente',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize:
                                      ResponsiveHelper.isMobile(context)
                                          ? 32
                                          : 40,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cálculo Integral Inteligente',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize:
                                      ResponsiveHelper.isMobile(context)
                                          ? 16
                                          : 18,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Status de carregamento
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indicadores de status
                    _buildStatusIndicators(),

                    const SizedBox(height: 32),

                    // Barra de progresso
                    _buildProgressBar(),

                    const SizedBox(height: 16),

                    // Texto do status atual
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentLoadingStep,
                        key: ValueKey(_currentLoadingStep),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'v1.0.0 • Powered by OlympusGroup',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusIcon(
          icon: Icons.settings,
          isCompleted: _servicesInitialized,
          label: 'Serviços',
        ),
        const SizedBox(width: 24),
        _buildStatusIcon(
          icon: Icons.memory,
          isCompleted: _controllersInitialized,
          label: 'Controllers',
        ),
        const SizedBox(width: 24),
        _buildStatusIcon(
          icon: Icons.folder,
          isCompleted: _configsLoaded,
          label: 'Configs',
        ),
        const SizedBox(width: 24),
        _buildStatusIcon(
          icon: Icons.wifi,
          isCompleted: _apiConnected,
          label: 'API',
          isOptional: true,
        ),
        const SizedBox(width: 24),
        _buildStatusIcon(
          icon: Icons.image,
          isCompleted: _resourcesPreloaded,
          label: 'Assets',
        ),
      ],
    );
  }

  Widget _buildStatusIcon({
    required IconData icon,
    required bool isCompleted,
    required String label,
    bool isOptional = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? AppColors.success
                    : isOptional
                    ? AppColors.warning
                    : AppColors.glassBorder,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: ResponsiveHelper.isMobile(context) ? 10 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        // Barra de progresso principal
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.glassBorder,
            borderRadius: BorderRadius.circular(3),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progress * _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.integralColor],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Porcentagem
        Text(
          '${(_progress * 100).toInt()}%',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
