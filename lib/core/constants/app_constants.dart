class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8000'; // Para desenvolvimento
  static const String apiAreaEndpoint = '/area';
  static const String apiSimbolicoEndpoint = '/simbolico';

  // App Information
  static const String appName = 'IntegraMente';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Aplicativo educacional para Cálculo II';

  // Storage Keys
  static const String storageHistoricoKey = 'integramente_historico';
  static const String storageFavoritosKey = 'integramente_favoritos';
  static const String storageConfiguracaoKey = 'integramente_config';

  // Animation Durations (otimizadas para performance)
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 250);
  static const Duration animationDurationSlow = Duration(milliseconds: 350);

  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Chart Configuration
  static const int chartResolutionDefault = 1000;
  static const double chartMinZoom = 0.5;
  static const double chartMaxZoom = 5.0;

  // Math Constants
  static const List<String> operadoresMatematicos = [
    '+',
    '-',
    '*',
    '/',
    '^',
    '(',
    ')',
    'sin',
    'cos',
    'tan',
    'log',
    'ln',
    'sqrt',
  ];

  static const List<String> exemplosFuncoes = [
    'x^2',
    'x^3 - 2*x + 1',
    'sin(x)',
    'cos(x) + x',
    'e^x',
    'ln(x)',
    'sqrt(x)',
    'x^2 * sin(x)',
  ];
}
