import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class TecladoMatematico extends StatelessWidget {
  final Function(String) onInput;
  final VoidCallback? onClear;
  final VoidCallback? onBackspace;
  final bool isCompact;

  const TecladoMatematico({
    super.key,
    required this.onInput,
    this.onClear,
    this.onBackspace,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = isCompact ? 40.0 : 50.0;
    final fontSize = isCompact ? 14.0 : 16.0;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linha 1: Números básicos
          Row(
            children: [
              _buildButton('7', buttonHeight, fontSize),
              _buildButton('8', buttonHeight, fontSize),
              _buildButton('9', buttonHeight, fontSize),
              _buildButton(
                '/',
                buttonHeight,
                fontSize,
                color: AppColors.accent,
              ),
              _buildButton(
                '(',
                buttonHeight,
                fontSize,
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linha 2: Números e operadores
          Row(
            children: [
              _buildButton('4', buttonHeight, fontSize),
              _buildButton('5', buttonHeight, fontSize),
              _buildButton('6', buttonHeight, fontSize),
              _buildButton(
                '*',
                buttonHeight,
                fontSize,
                color: AppColors.accent,
              ),
              _buildButton(
                ')',
                buttonHeight,
                fontSize,
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linha 3: Números e operadores
          Row(
            children: [
              _buildButton('1', buttonHeight, fontSize),
              _buildButton('2', buttonHeight, fontSize),
              _buildButton('3', buttonHeight, fontSize),
              _buildButton(
                '-',
                buttonHeight,
                fontSize,
                color: AppColors.accent,
              ),
              _buildButton(
                '^',
                buttonHeight,
                fontSize,
                color: AppColors.integralColor,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linha 4: Zero e operadores
          Row(
            children: [
              _buildButton('0', buttonHeight, fontSize),
              _buildButton('.', buttonHeight, fontSize),
              _buildButton(
                'x',
                buttonHeight,
                fontSize,
                color: AppColors.variableColor,
              ),
              _buildButton(
                '+',
                buttonHeight,
                fontSize,
                color: AppColors.accent,
              ),
              _buildButton(
                'π',
                buttonHeight,
                fontSize,
                color: AppColors.constantColor,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linha 5: Funções trigonométricas
          Row(
            children: [
              _buildButton(
                'sin',
                buttonHeight,
                fontSize,
                color: AppColors.functionColor,
              ),
              _buildButton(
                'cos',
                buttonHeight,
                fontSize,
                color: AppColors.functionColor,
              ),
              _buildButton(
                'tan',
                buttonHeight,
                fontSize,
                color: AppColors.functionColor,
              ),
              _buildButton(
                'ln',
                buttonHeight,
                fontSize,
                color: AppColors.derivativeColor,
              ),
              _buildButton(
                '√',
                buttonHeight,
                fontSize,
                color: AppColors.derivativeColor,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Linha 6: Controles
          Row(
            children: [
              _buildButton(
                'e',
                buttonHeight,
                fontSize,
                color: AppColors.constantColor,
              ),
              _buildButton(
                'log',
                buttonHeight,
                fontSize,
                color: AppColors.derivativeColor,
              ),
              Expanded(
                child: _buildActionButton(
                  'Limpar',
                  buttonHeight,
                  fontSize - 2,
                  AppColors.error,
                  onClear ?? () {},
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                '⌫',
                buttonHeight,
                fontSize,
                AppColors.warning,
                onBackspace ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    double height,
    double fontSize, {
    Color? color,
  }) {
    return Expanded(
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () => onInput(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? AppColors.backgroundSurface,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            elevation: 2,
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    double height,
    double fontSize,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      height: height,
      width: height * 1.5,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// Widget específico para entrada de funções com preview
class EntradaFuncaoWidget extends StatefulWidget {
  final Function(String) onFuncaoChanged;
  final String? funcaoInicial;
  final String? erro;
  final bool showTeclado;

  const EntradaFuncaoWidget({
    super.key,
    required this.onFuncaoChanged,
    this.funcaoInicial,
    this.erro,
    this.showTeclado = true,
  });

  @override
  State<EntradaFuncaoWidget> createState() => _EntradaFuncaoWidgetState();
}

class _EntradaFuncaoWidgetState extends State<EntradaFuncaoWidget> {
  late final TextEditingController _controller;
  bool _tecladoVisivel = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.funcaoInicial ?? '');
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onFuncaoChanged(_controller.text);
  }

  void _onTecladoInput(String input) {
    final currentPosition = _controller.selection.start;
    final currentText = _controller.text;

    // Tratamento especial para algumas funções
    String textToInsert = input;
    if (input == 'sin' ||
        input == 'cos' ||
        input == 'tan' ||
        input == 'ln' ||
        input == 'log') {
      textToInsert = '$input(';
    } else if (input == '√') {
      textToInsert = 'sqrt(';
    } else if (input == 'π') {
      textToInsert = 'pi';
    }

    final newText =
        currentText.substring(0, currentPosition) +
        textToInsert +
        currentText.substring(currentPosition);

    _controller.text = newText;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: currentPosition + textToInsert.length),
    );
  }

  void _onClear() {
    _controller.clear();
  }

  void _onBackspace() {
    final currentText = _controller.text;
    final currentPosition = _controller.selection.start;

    if (currentPosition > 0) {
      final newText =
          currentText.substring(0, currentPosition - 1) +
          currentText.substring(currentPosition);

      _controller.text = newText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: currentPosition - 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de entrada
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Função f(x)',
            hintText: 'Ex: x^2 + 3*x - 1',
            errorText: widget.erro?.isNotEmpty == true ? widget.erro : null,
            suffixIcon:
                widget.showTeclado
                    ? IconButton(
                      onPressed: () {
                        setState(() {
                          _tecladoVisivel = !_tecladoVisivel;
                        });
                      },
                      icon: Icon(
                        _tecladoVisivel ? Icons.keyboard_hide : Icons.keyboard,
                        color: AppColors.primary,
                      ),
                    )
                    : null,
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          onTap: () {
            if (!widget.showTeclado) return;
            setState(() {
              _tecladoVisivel = true;
            });
          },
        ),

        // Preview da função
        if (_controller.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.preview,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'f(x) = ${_controller.text}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Teclado matemático
        if (_tecladoVisivel && widget.showTeclado) ...[
          const SizedBox(height: 16),
          TecladoMatematico(
            onInput: _onTecladoInput,
            onClear: _onClear,
            onBackspace: _onBackspace,
            isCompact: true,
          ),
        ],
      ],
    );
  }
}
