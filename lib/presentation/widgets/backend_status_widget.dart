import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/backend_config.dart';
import '../../data/services/api_service.dart';

class BackendStatusWidget extends StatefulWidget {
  const BackendStatusWidget({super.key});

  @override
  State<BackendStatusWidget> createState() => _BackendStatusWidgetState();
}

class _BackendStatusWidgetState extends State<BackendStatusWidget> {
  bool _isConnected = false;
  bool _isChecking = false;
  String _statusMessage = 'Verificando conexão...';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    if (!mounted) return;

    setState(() {
      _isChecking = true;
      _statusMessage = 'Verificando conexão...';
    });

    try {
      final apiService = ApiService();
      final isConnected = await apiService.verificarConexao();

      if (!mounted) return;

      setState(() {
        _isConnected = isConnected;
        _isChecking = false;

        if (isConnected) {
          _statusMessage = 'Backend conectado';
        } else {
          _statusMessage =
              BackendConfig.fallbackToLocal
                  ? 'Usando cálculos locais'
                  : 'Backend indisponível';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isConnected = false;
        _isChecking = false;
        _statusMessage =
            BackendConfig.fallbackToLocal
                ? 'Usando cálculos locais'
                : 'Erro de conexão';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isChecking)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              ),
            )
          else
            Icon(_getStatusIcon(), color: _getStatusColor(), size: 16),
          const SizedBox(width: 6),
          Text(
            _statusMessage,
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!_isChecking) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _checkConnection,
              child: Icon(Icons.refresh, color: _getStatusColor(), size: 14),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_isChecking) return AppColors.info;
    if (_isConnected) return AppColors.success;
    return BackendConfig.fallbackToLocal ? AppColors.warning : AppColors.error;
  }

  IconData _getStatusIcon() {
    if (_isConnected) return Icons.cloud_done;
    if (BackendConfig.fallbackToLocal) return Icons.offline_bolt;
    return Icons.cloud_off;
  }
}

// Widget simplificado para usar em AppBars
class BackendStatusIndicator extends StatelessWidget {
  const BackendStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const BackendStatusWidget();
  }
}

// Mixin para facilitar o uso em telas
mixin BackendStatusMixin<T extends StatefulWidget> on State<T> {
  Widget buildBackendStatus() {
    return const BackendStatusWidget();
  }

  Widget buildStatusInAppBar() {
    return const BackendStatusIndicator();
  }
}
