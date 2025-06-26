import 'package:get/get.dart';

/// Gerenciador de estado global da aplicação
class AppState extends GetxController {
  static AppState get instance => Get.find<AppState>();

  // Estado do splash
  final RxBool _splashCompleted = false.obs;
  bool get splashCompleted => _splashCompleted.value;

  // Estado de inicialização
  final RxBool _appInitialized = false.obs;
  bool get appInitialized => _appInitialized.value;

  // Estado da API
  final RxBool _apiConnected = false.obs;
  bool get apiConnected => _apiConnected.value;

  // Primeira vez abrindo o app
  final RxBool _isFirstLaunch = true.obs;
  bool get isFirstLaunch => _isFirstLaunch.value;

  /// Marca o splash como completado
  void completeSplash() {
    _splashCompleted.value = true;
    _isFirstLaunch.value = false;
    update();
  }

  /// Marca o app como inicializado
  void markAppInitialized() {
    _appInitialized.value = true;
    update();
  }

  /// Atualiza o status da API
  void updateApiStatus(bool connected) {
    _apiConnected.value = connected;
    update();
  }

  /// Reset para testes (apenas em debug)
  void resetForTesting() {
    assert(() {
      _splashCompleted.value = false;
      _appInitialized.value = false;
      _apiConnected.value = false;
      _isFirstLaunch.value = true;
      update();
      return true;
    }());
  }

  /// Verifica se deve mostrar splash
  bool shouldShowSplash() {
    return !_splashCompleted.value || !_appInitialized.value;
  }
}
