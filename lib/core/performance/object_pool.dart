import 'dart:collection';

/// Pool de objetos para reduzir criação/destruição frequente
class ObjectPool<T> {
  final Queue<T> _available = Queue<T>();
  final Set<T> _inUse = <T>{};
  final T Function() _factory;
  final void Function(T)? _reset;
  final int _maxSize;

  ObjectPool({
    required T Function() factory,
    void Function(T)? reset,
    int maxSize = 50,
  }) : _factory = factory,
       _reset = reset,
       _maxSize = maxSize;

  /// Obtém objeto do pool ou cria novo
  T acquire() {
    T object;

    if (_available.isNotEmpty) {
      object = _available.removeFirst();
    } else {
      object = _factory();
    }

    _inUse.add(object);
    return object;
  }

  /// Retorna objeto para o pool
  void release(T object) {
    if (!_inUse.remove(object)) return;

    // Reset object state if needed
    _reset?.call(object);

    // Add back to pool if not at capacity
    if (_available.length < _maxSize) {
      _available.add(object);
    }
  }

  /// Libera todos os objetos
  void clear() {
    _available.clear();
    _inUse.clear();
  }

  /// Estatísticas do pool
  Map<String, int> get stats => {
    'available': _available.length,
    'in_use': _inUse.length,
    'total': _available.length + _inUse.length,
  };
}

/// Pool manager para diferentes tipos de objetos
class PoolManager {
  static final PoolManager _instance = PoolManager._internal();
  factory PoolManager() => _instance;
  PoolManager._internal();

  final Map<Type, ObjectPool> _pools = {};

  /// Registra um novo pool para um tipo
  void registerPool<T>(ObjectPool<T> pool) {
    _pools[T] = pool;
  }

  /// Obtém pool para um tipo
  ObjectPool<T>? getPool<T>() {
    return _pools[T] as ObjectPool<T>?;
  }

  /// Cria pools padrão para tipos comuns
  void initializeDefaultPools() {
    // Pool para listas temporárias
    registerPool<List<String>>(
      ObjectPool<List<String>>(
        factory: () => <String>[],
        reset: (list) => list.clear(),
        maxSize: 20,
      ),
    );

    // Pool para maps temporários
    registerPool<Map<String, dynamic>>(
      ObjectPool<Map<String, dynamic>>(
        factory: () => <String, dynamic>{},
        reset: (map) => map.clear(),
        maxSize: 15,
      ),
    );

    // Pool para StringBuffer
    registerPool<StringBuffer>(
      ObjectPool<StringBuffer>(
        factory: () => StringBuffer(),
        reset: (buffer) => buffer.clear(),
        maxSize: 10,
      ),
    );
  }

  /// Limpa todos os pools
  void clearAllPools() {
    for (final pool in _pools.values) {
      pool.clear();
    }
  }

  /// Estatísticas de todos os pools
  Map<String, dynamic> getAllStats() {
    final stats = <String, dynamic>{};
    for (final entry in _pools.entries) {
      stats[entry.key.toString()] = entry.value.stats;
    }
    return stats;
  }
}
