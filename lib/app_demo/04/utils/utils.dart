import 'package:math_expressions/math_expressions.dart';

// 简单格式化数字
String formatResult(double value) {
  if (value == value.toInt()) {
    return value.toInt().toString(); // 整数，去掉小数部分
  } else {
    return value.toString(); // 浮点数
  }
}

// 转换显示用运算符为实际计算用运算符
String _convertOperators(String expression) {
  return expression.replaceAll('×', '*').replaceAll('÷', '/');
}

// 检查表达式是否以运算符结尾
bool _endsWithOperator(String expression) {
  return expression.endsWith('+') ||
      expression.endsWith('-') ||
      expression.endsWith('*') ||
      expression.endsWith('/');
}

// 检查是否是除以0的情况
bool _isDivideByZero(String expression) {
  // 查找所有除法运算
  int index = expression.indexOf('÷');
  while (index != -1) {
    // 查找除数
    String rightPart = expression.substring(index + 1).trim();
    if (rightPart.startsWith('0') || rightPart.startsWith('0.0')) {
      return true;
    }
    index = expression.indexOf('÷', index + 1);
  }
  return false;
}

String evaluateExpression(String expression) {
  try {
    // 预处理表达式
    String processedExpression = _convertOperators(expression.trim());

    // 基本验证
    if (processedExpression.isEmpty) {
      return '0';
    }

    // 如果表达式以运算符结尾，去掉最后的运算符
    if (_endsWithOperator(processedExpression)) {
      processedExpression =
          processedExpression.substring(0, processedExpression.length - 1);
    }

    // 检查是否是有效的表达式
    if (processedExpression.contains('**') ||
        processedExpression.contains('÷÷') ||
        processedExpression.contains('++') ||
        processedExpression.contains('--')) {
      return '0';
    }

    // 检查是否除以0
    if (_isDivideByZero(processedExpression)) {
      return '0';
    }

    // 使用 math_expressions 库计算
    Parser p = Parser();
    Expression exp = p.parse(processedExpression);
    ContextModel cm = ContextModel();
    double result = exp.evaluate(EvaluationType.REAL, cm);

    // 检查结果是否有效
    if (result.isInfinite || result.isNaN) {
      return '0';
    }

    // 格式化结果
    return formatResult(result);
  } catch (e) {
    return '0';
  }
}
