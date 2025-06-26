import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/performance/performance_config.dart';
import 'core/performance/lazy_loading_manager.dart';
import 'core/performance/performance_monitor.dart';
import 'core/performance/object_pool.dart';
import 'data/services/storage_service.dart';
import 'data/services/api_service.dart';
import 'presentation/controllers/app_controller.dart';
import 'core/utils/app_state.dart';

void main() async {
  // 🚀 Inicialização super otimizada
  await _optimizedInitialization();

  runApp(const IntegraMenteApp());
}

Future<void> _optimizedInitialization() async {
  // 1. Binding básico
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configurações de sistema (paralelo)
  await Future.wait([
    _configureSystemUI(),
    _initializePerformanceSystems(),
    _initializeLocalization(),
  ]);

  // 3. Serviços críticos (sequencial - dependências)
  await _initCriticalServices();

  // 4. Pré-carregamento em background (não bloqueia)
  _preloadNonCriticalServices();
}

/// Configurações de UI do sistema
Future<void> _configureSystemUI() async {
  // Permitir todas as orientações - será controlado responsivamente
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

/// Inicializa sistemas de performance
Future<void> _initializePerformanceSystems() async {
  // Performance Config
  PerformanceConfig.initialize();

  // Object Pools
  PoolManager().initializeDefaultPools();

  // Performance Monitor (só em debug)
  if (PerformanceConfig.enablePerformanceMonitoring) {
    PerformanceMonitor();
  }

  // Lazy Loading Manager
  LazyLoadingManager();
}

/// Inicializa a localização
Future<void> _initializeLocalization() async {
  try {
    // Inicializa os dados de formatação para português brasileiro
    await initializeDateFormatting('pt_BR', null);

    // Define o locale padrão
    Intl.defaultLocale = 'pt_BR';
  } catch (e) {
    // Fallback para inglês se houver erro
    await initializeDateFormatting('en_US', null);
    Intl.defaultLocale = 'en_US';
  }
}

/// Serviços críticos (bloqueia inicialização)
Future<void> _initCriticalServices() async {
  final performanceMonitor = PerformanceMonitor();

  // App State (primeiro - controla splash)
  Get.put(AppState());

  // Storage Service (crítico)
  await performanceMonitor.measureAsync('storage_init', () async {
    final storageService = StorageService();
    await storageService.init();
    Get.put(storageService);
  });

  // App Controller (crítico)
  await performanceMonitor.measureAsync('app_controller_init', () async {
    Get.put(AppController());
  });
}

/// Pré-carregamento não crítico (não bloqueia)
void _preloadNonCriticalServices() {
  Future.microtask(() async {
    final lazyManager = LazyLoadingManager();
    final performanceMonitor = PerformanceMonitor();

    // API Service (lazy)
    await lazyManager.loadService<ApiService>(
      'api_service',
      () => ApiService(),
    );

    // Pré-carregamento de recursos
    await performanceMonitor.measureAsync('preload_resources', () async {
      // Aqui você pode pré-carregar imagens, fontes, etc.
      await _preloadAssets();
    });

    // Log performance inicial
    if (PerformanceConfig.enablePerformanceMonitoring) {
      performanceMonitor.printReport();
    }
  });
}

/// Pré-carrega assets críticos
Future<void> _preloadAssets() async {
  // Pré-carregar imagens críticas
  // await precacheImage(AssetImage('assets/images/logo.png'), context);

  // Pré-carregar fontes se necessário
  // FontLoader('CustomFont')..addFont(FontAsset('assets/fonts/custom.ttf'))..load();
}

class IntegraMenteApp extends StatelessWidget {
  const IntegraMenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Tema otimizado
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Roteamento otimizado
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,

      // Configurações de localização
      locale: const Locale('pt', 'BR'),

      // Configurações de performance
      builder: (context, child) {
        return _PerformanceWrapper(child: child);
      },
    );
  }
}

/// Wrapper para monitoramento de performance
class _PerformanceWrapper extends StatefulWidget {
  final Widget? child;

  const _PerformanceWrapper({this.child});

  @override
  State<_PerformanceWrapper> createState() => _PerformanceWrapperState();
}

class _PerformanceWrapperState extends State<_PerformanceWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (PerformanceConfig.enablePerformanceMonitoring) {
      final monitor = PerformanceMonitor();

      switch (state) {
        case AppLifecycleState.paused:
          // App pausado - limpar recursos desnecessários
          PoolManager().clearAllPools();
          LazyLoadingManager().unloadUnusedServices();
          break;
        case AppLifecycleState.resumed:
          // App retomado - imprimir relatório de performance
          monitor.printReport();
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
