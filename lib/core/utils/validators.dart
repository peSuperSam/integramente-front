class Validators {
  /// Valida se uma função matemática tem sintaxe básica válida
  static bool isValidMathFunction(String function) {
    if (function.isEmpty) return false;

    // Remove espaços
    function = function.replaceAll(' ', '');

    // Verifica caracteres válidos
    final validPattern = RegExp(r'^[x0-9+\-*/^()sincotaglneqrtpi.,]+$');
    if (!validPattern.hasMatch(function)) return false;

    // Verifica balanceamento de parênteses
    int openParens = 0;
    for (int i = 0; i < function.length; i++) {
      if (function[i] == '(') openParens++;
      if (function[i] == ')') openParens--;
      if (openParens < 0) return false;
    }

    return openParens == 0;
  }

  /// Valida se um intervalo é válido (a < b)
  static bool isValidInterval(double a, double b) {
    return a < b && a.isFinite && b.isFinite;
  }

  /// Valida se um número é válido e finito
  static bool isValidNumber(String value) {
    if (value.isEmpty) return false;
    final number = double.tryParse(value);
    return number != null && number.isFinite;
  }

  /// Normaliza uma função matemática removendo espaços e formatando
  static String normalizeMathFunction(String function) {
    return function
        .replaceAll(' ', '')
        .replaceAll('**', '^')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .toLowerCase();
  }

  /// Verifica se a função contém operadores válidos
  static bool containsValidOperators(String function) {
    final operators = ['+', '-', '*', '/', '^', '(', ')'];
    final functions = ['sin', 'cos', 'tan', 'log', 'ln', 'sqrt', 'abs'];

    for (String op in operators) {
      if (function.contains(op)) return true;
    }

    for (String func in functions) {
      if (function.contains(func)) return true;
    }

    return function.contains('x') || RegExp(r'\d').hasMatch(function);
  }
}
