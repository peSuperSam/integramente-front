import 'package:get/get.dart';
import '../../data/models/funcao_matematica.dart';
import '../../data/models/historico_item.dart';
import '../../data/models/calculo_response.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/api_service.dart';
import '../../core/performance/lazy_loading_manager.dart';

class AppController extends GetxController {
  // Observables
  final Rx<FuncaoMatematica?> _funcaoAtual = Rx<FuncaoMatematica?>(null);
  final RxList<HistoricoItem> _historico = <HistoricoItem>[].obs;
  final RxList<HistoricoItem> _favoritos = <HistoricoItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _erro = ''.obs;
  final RxDouble _intervaloA = 0.0.obs;
  final RxDouble _intervaloB = 1.0.obs;
  final RxString _ultimoResultado = ''.obs;

  // Services
  late final StorageService _storageService;
  ApiService? _apiService;

  // Getters
  FuncaoMatematica? get funcaoAtual => _funcaoAtual.value;
  List<HistoricoItem> get historico => _historico;
  List<HistoricoItem> get favoritos => _favoritos;
  RxBool get isLoading => _isLoading;
  String get erro => _erro.value;
  double get intervaloA => _intervaloA.value;
  double get intervaloB => _intervaloB.value;
  RxString get ultimoResultado => _ultimoResultado;

  // Getters computados
  List<HistoricoItem> get historicoRecente => _historico.take(5).toList();

  List<HistoricoItem> get historicoArea =>
      _historico.where((item) => item.tipo == TipoCalculo.area).toList();

  List<HistoricoItem> get historicoSimbolico =>
      _historico.where((item) => item.tipo == TipoCalculo.simbolico).toList();

  int get totalCalculos => _historico.length;
  int get calculosComSucesso =>
      _historico.where((item) => item.calculoComSucesso).length;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _loadHistorico();
  }

  void _initializeServices() {
    _storageService = Get.find<StorageService>();

    // ApiService é carregado de forma lazy - pode não estar disponível ainda
    try {
      _apiService = Get.find<ApiService>();
    } catch (e) {
      // ApiService ainda não foi carregado - será carregado quando necessário
      _apiService = null;
    }
  }

  /// Garante que o ApiService está carregado
  Future<ApiService> _ensureApiService() async {
    if (_apiService != null) {
      return _apiService!;
    }

    try {
      _apiService = await LazyLoadingManager().loadService<ApiService>(
        'api_service',
        () => ApiService(),
      );
      return _apiService!;
    } catch (e) {
      throw Exception('Erro ao carregar ApiService: $e');
    }
  }

  Future<void> _loadHistorico() async {
    try {
      _isLoading.value = true;
      final historico = await _storageService.getHistorico();
      _historico.assignAll(historico);

      final favoritos = historico.where((item) => item.isFavorito).toList();
      _favoritos.assignAll(favoritos);

      _erro.value = '';
    } catch (e) {
      _erro.value = 'Erro ao carregar histórico: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  // Gerenciamento de função atual
  void setFuncaoAtual(String expressao) {
    if (expressao.trim().isEmpty) {
      _funcaoAtual.value = null;
      return;
    }

    final funcao = FuncaoMatematica.criarDaExpressao(expressao);
    _funcaoAtual.value = funcao;

    if (!funcao.isValida) {
      _erro.value = funcao.erro ?? 'Função inválida';
    } else {
      _erro.value = '';
    }
  }

  void clearFuncaoAtual() {
    _funcaoAtual.value = null;
    _erro.value = '';
  }

  // Gerenciamento de intervalo
  void setIntervaloA(double valor) {
    _intervaloA.value = valor;
  }

  void setIntervaloB(double valor) {
    _intervaloB.value = valor;
  }

  void setIntervalo(double a, double b) {
    _intervaloA.value = a;
    _intervaloB.value = b;
  }

  // Gerenciamento de histórico
  Future<void> adicionarAoHistorico(HistoricoItem item) async {
    try {
      _historico.insert(0, item); // Adiciona no início
      await _storageService.salvarHistorico(_historico);

      if (item.isFavorito) {
        _favoritos.insert(0, item);
      }
    } catch (e) {
      _erro.value = 'Erro ao salvar no histórico: ${e.toString()}';
    }
  }

  Future<void> removerDoHistorico(String itemId) async {
    try {
      _historico.removeWhere((item) => item.id == itemId);
      _favoritos.removeWhere((item) => item.id == itemId);
      await _storageService.salvarHistorico(_historico);
    } catch (e) {
      _erro.value = 'Erro ao remover do histórico: ${e.toString()}';
    }
  }

  Future<void> toggleFavorito(String itemId) async {
    try {
      final index = _historico.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _historico[index];
        final itemAtualizado = item.copyWith(isFavorito: !item.isFavorito);

        _historico[index] = itemAtualizado;

        if (itemAtualizado.isFavorito) {
          _favoritos.add(itemAtualizado);
        } else {
          _favoritos.removeWhere((fav) => fav.id == itemId);
        }

        await _storageService.salvarHistorico(_historico);
      }
    } catch (e) {
      _erro.value = 'Erro ao atualizar favorito: ${e.toString()}';
    }
  }

  Future<void> limparHistorico() async {
    try {
      _historico.clear();
      _favoritos.clear();
      await _storageService.limparHistorico();
    } catch (e) {
      _erro.value = 'Erro ao limpar histórico: ${e.toString()}';
    }
  }

  // Busca no histórico
  List<HistoricoItem> buscarNoHistorico(String query) {
    if (query.trim().isEmpty) return _historico;

    final queryLower = query.toLowerCase();
    return _historico.where((item) {
      return item.funcao.expressao.toLowerCase().contains(queryLower) ||
          item.descricaoResultado.toLowerCase().contains(queryLower);
    }).toList();
  }

  // Estatísticas
  Map<String, dynamic> getEstatisticas() {
    final totalArea = historicoArea.length;
    final totalSimbolico = historicoSimbolico.length;
    final sucessoArea =
        historicoArea.where((item) => item.calculoComSucesso).length;
    final sucessoSimbolico =
        historicoSimbolico.where((item) => item.calculoComSucesso).length;

    return {
      'totalCalculos': totalCalculos,
      'calculosArea': totalArea,
      'calculosSimbolico': totalSimbolico,
      'sucessoArea': sucessoArea,
      'sucessoSimbolico': sucessoSimbolico,
      'totalFavoritos': _favoritos.length,
      'taxaSucesso':
          totalCalculos > 0 ? (calculosComSucesso / totalCalculos * 100) : 0.0,
    };
  }

  // Utilitários
  void clearErro() {
    _erro.value = '';
  }

  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void setUltimoResultado(String resultado) {
    _ultimoResultado.value = resultado;
  }

  // Cálculo de área com integração ao backend
  Future<void> calcularArea() async {
    if (_funcaoAtual.value == null || !_funcaoAtual.value!.isValida) {
      _erro.value = 'Função inválida para cálculo';
      return;
    }

    try {
      _isLoading.value = true;
      _erro.value = '';

      // Garante que o ApiService está carregado
      final apiService = await _ensureApiService();

      // Tenta conectar com o backend primeiro
      final backendDisponivel = await apiService.verificarConexao();

      CalculoAreaResponse resultado;

      if (backendDisponivel) {
        // Usa API real
        resultado = await apiService.calcularArea(
          funcao: _funcaoAtual.value!,
          intervaloA: _intervaloA.value,
          intervaloB: _intervaloB.value,
        );
      } else {
        // Fallback para cálculo local
        resultado = await apiService.calcularAreaLocal(
          funcao: _funcaoAtual.value!,
          intervaloA: _intervaloA.value,
          intervaloB: _intervaloB.value,
        );
      }

      final historicoItem = HistoricoItem.area(
        funcao: _funcaoAtual.value!,
        intervaloA: _intervaloA.value,
        intervaloB: _intervaloB.value,
        resultado: resultado,
      );

      await adicionarAoHistorico(historicoItem);

      if (!resultado.sucesso) {
        _erro.value = resultado.erro ?? 'Erro no cálculo';
      }
    } catch (e) {
      _erro.value = 'Erro no cálculo: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> calcularSimbolico() async {
    if (_funcaoAtual.value == null || !_funcaoAtual.value!.isValida) {
      _erro.value = 'Função inválida para cálculo';
      return;
    }

    try {
      _isLoading.value = true;
      _erro.value = '';

      // Garante que o ApiService está carregado
      final apiService = await _ensureApiService();

      // Tenta conectar com o backend primeiro
      final backendDisponivel = await apiService.verificarConexao();

      CalculoSimbolicoResponse resultado;

      if (backendDisponivel) {
        // Usa API real
        resultado = await apiService.calcularSimbolico(
          funcao: _funcaoAtual.value!,
          mostrarPassos: true,
        );
      } else {
        // Fallback para cálculo local
        resultado = await apiService.calcularSimbolicoLocal(
          funcao: _funcaoAtual.value!,
        );
      }

      final historicoItem = HistoricoItem.simbolico(
        funcao: _funcaoAtual.value!,
        resultado: resultado,
      );

      await adicionarAoHistorico(historicoItem);

      if (!resultado.sucesso) {
        _erro.value = resultado.erro ?? 'Erro no cálculo';
      }
    } catch (e) {
      _erro.value = 'Erro no cálculo: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }
}
