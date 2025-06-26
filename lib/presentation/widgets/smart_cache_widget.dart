import 'dart:collection';
import 'package:flutter/material.dart';
import '../../core/performance/performance_config.dart';
import '../../core/performance/object_pool.dart';

/// Cache inteligente para widgets pesados
class SmartCacheWidget<T> extends StatefulWidget {
  final String cacheKey;
  final T data;
  final Widget Function(T data) builder;
  final bool Function(T oldData, T newData)? shouldRebuild;
  final Duration? ttl;
  final int? maxCacheSize;

  const SmartCacheWidget({
    super.key,
    required this.cacheKey,
    required this.data,
    required this.builder,
    this.shouldRebuild,
    this.ttl,
    this.maxCacheSize,
  });

  @override
  State<SmartCacheWidget<T>> createState() => _SmartCacheWidgetState<T>();
}

class _SmartCacheWidgetState<T> extends State<SmartCacheWidget<T>> {
  static final Map<String, _CacheEntry> _widgetCache = {};
  static final Queue<String> _accessOrder = Queue<String>();

  @override
  void initState() {
    super.initState();
    _updateAccessOrder();
  }

  @override
  void didUpdateWidget(SmartCacheWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if we need to rebuild
    if (_shouldRebuildWidget(oldWidget.data, widget.data)) {
      _invalidateCache();
    }

    _updateAccessOrder();
  }

  bool _shouldRebuildWidget(T oldData, T newData) {
    if (widget.shouldRebuild != null) {
      return widget.shouldRebuild!(oldData, newData);
    }

    // Default comparison
    return oldData != newData;
  }

  void _updateAccessOrder() {
    _accessOrder.remove(widget.cacheKey);
    _accessOrder.add(widget.cacheKey);

    // Limit cache size
    final maxSize = widget.maxCacheSize ?? PerformanceConfig.maxCacheSize;
    while (_accessOrder.length > maxSize) {
      final oldestKey = _accessOrder.removeFirst();
      _widgetCache.remove(oldestKey);
    }
  }

  void _invalidateCache() {
    _widgetCache.remove(widget.cacheKey);
  }

  Widget _buildAndCache() {
    final builtWidget = widget.builder(widget.data);

    // Store in cache
    _widgetCache[widget.cacheKey] = _CacheEntry(
      widget: builtWidget,
      timestamp: DateTime.now(),
      data: widget.data,
    );

    return builtWidget;
  }

  @override
  Widget build(BuildContext context) {
    final cached = _widgetCache[widget.cacheKey];

    // Check if cache is valid
    if (cached != null) {
      final ttl =
          widget.ttl ??
          PerformanceConfig.getCacheConfig(cacheType: 'widget_cache')['ttl']
              as Duration;

      final isExpired = DateTime.now().difference(cached.timestamp) > ttl;
      final dataChanged = cached.data != widget.data;

      if (!isExpired && !dataChanged) {
        return cached.widget;
      }
    }

    // Build new widget
    return _buildAndCache();
  }
}

class _CacheEntry {
  final Widget widget;
  final DateTime timestamp;
  final dynamic data;

  _CacheEntry({
    required this.widget,
    required this.timestamp,
    required this.data,
  });
}

/// Mixin para widgets que usam cache inteligente
mixin SmartCacheMixin<T extends StatefulWidget> on State<T> {
  final Map<String, Widget> _localCache = {};

  /// Cache widget localmente
  Widget cacheWidget(String key, Widget Function() builder) {
    if (_localCache.containsKey(key)) {
      return _localCache[key]!;
    }

    final widget = builder();
    _localCache[key] = widget;
    return widget;
  }

  /// Invalida cache local
  void invalidateCache([String? key]) {
    if (key != null) {
      _localCache.remove(key);
    } else {
      _localCache.clear();
    }
  }

  @override
  void dispose() {
    _localCache.clear();
    super.dispose();
  }
}

/// Lista com cache inteligente
class SmartCachedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String Function(T item)? keyExtractor;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const SmartCachedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.keyExtractor,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<SmartCachedListView<T>> createState() => _SmartCachedListViewState<T>();
}

class _SmartCachedListViewState<T> extends State<SmartCachedListView<T>> {
  final Map<String, Widget> _itemCache = {};

  String _getItemKey(T item, int index) {
    if (widget.keyExtractor != null) {
      return widget.keyExtractor!(item);
    }
    return 'item_$index';
  }

  Widget _buildCachedItem(BuildContext context, int index) {
    if (index >= widget.items.length) return const SizedBox.shrink();

    final item = widget.items[index];
    final key = _getItemKey(item, index);

    // Use object pool for better memory management
    final pool = PoolManager().getPool<Map<String, dynamic>>();
    final tempData = pool?.acquire() ?? <String, dynamic>{};

    try {
      if (!_itemCache.containsKey(key)) {
        _itemCache[key] = widget.itemBuilder(context, item, index);
      }

      return _itemCache[key]!;
    } finally {
      pool?.release(tempData);
    }
  }

  @override
  void didUpdateWidget(SmartCachedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Clear cache if items changed significantly
    if (widget.items.length != oldWidget.items.length) {
      _itemCache.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: widget.items.length,
      itemBuilder: _buildCachedItem,
      // Otimizações adicionais
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      cacheExtent: 1000, // Cache de 1000px
    );
  }

  @override
  void dispose() {
    _itemCache.clear();
    super.dispose();
  }
}
