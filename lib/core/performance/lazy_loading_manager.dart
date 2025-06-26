import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Gerenciador de carregamento lazy para otimizar inicialização
class LazyLoadingManager {
  static final LazyLoadingManager _instance = LazyLoadingManager._internal();
  factory LazyLoadingManager() => _instance;
  LazyLoadingManager._internal();

  final Map<String, bool> _loadedServices = {};
  final Map<String, Completer<void>> _loadingCompleters = {};

  /// Carrega serviço apenas quando necessário
  Future<T> loadService<T>(
    String serviceKey,
    T Function() factory, {
    bool forceReload = false,
  }) async {
    if (_loadedServices[serviceKey] == true && !forceReload) {
      return Get.find<T>();
    }

    // Se já está carregando, aguarda
    if (_loadingCompleters.containsKey(serviceKey)) {
      await _loadingCompleters[serviceKey]!.future;
      return Get.find<T>();
    }

    final completer = Completer<void>();
    _loadingCompleters[serviceKey] = completer;

    try {
      final service = factory();
      Get.put<T>(service);
      _loadedServices[serviceKey] = true;
      completer.complete();
      return service;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _loadingCompleters.remove(serviceKey);
    }
  }

  /// Pré-carrega serviços críticos em background
  Future<void> preloadCriticalServices() async {
    if (kDebugMode) {
      debugPrint('🚀 Pré-carregando serviços críticos...');
    }

    // Lista de serviços críticos para pré-carregamento
    final criticalServices = ['theme_service', 'performance_monitor'];

    await Future.wait(
      criticalServices.map((service) => _preloadService(service)),
    );
  }

  Future<void> _preloadService(String serviceKey) async {
    try {
      switch (serviceKey) {
        case 'theme_service':
          // Pré-carrega configurações de tema
          break;
        case 'performance_monitor':
          // Pré-carrega monitor de performance
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao pré-carregar $serviceKey: $e');
      }
    }
  }

  /// Descarrega serviços não utilizados para liberar memória
  void unloadUnusedServices() {
    final unusedServices = <String>[];

    // Lógica para detectar serviços não utilizados pode ser implementada aqui
    // Por exemplo: verificar timestamp de último acesso, uso de memória, etc.

    for (final key in unusedServices) {
      try {
        Get.delete(tag: key);
        _loadedServices.remove(key);
        if (kDebugMode) {
          debugPrint('🗑️ Serviço descarregado: $key');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Erro ao descarregar $key: $e');
        }
      }
    }
  }

  /// Estatísticas de carregamento
  Map<String, dynamic> getLoadingStats() {
    return {
      'loaded_services': _loadedServices.length,
      'currently_loading': _loadingCompleters.length,
      'services': _loadedServices.keys.toList(),
    };
  }
}
