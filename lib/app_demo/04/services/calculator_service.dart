import 'package:flutter_x_widgets/app_demo/04/utils/utils.dart';

class CalculatorService {
  // 检查是否是运算符
  bool isOperator(String input) {
    return input == '+' || input == '-' || input == '×' || input == '÷';
  }

  // 处理数字输入
  String handleNumberInput(String input, String currentResult) {
    if (currentResult == '0' && input != '.') {
      return input;
    }
    // 防止多个小数点
    if (input == '.' && currentResult.contains('.')) {
      return currentResult;
    }
    return currentResult + input;
  }

  // 处理运算符输入
  String handleOperatorInput(String input, String currentResult) {
    if (currentResult == '0') {
      return '0$input';
    }
    return '$currentResult $input';
  }

  // 处理退格键
  String handleBackspace(String currentResult) {
    if (currentResult.length <= 1) {
      return '0';
    }
    return currentResult.substring(0, currentResult.length - 1);
  }

  // 处理正负号
  String handleToggleSign(String currentResult) {
    if (currentResult == '0') return '0';
    if (currentResult.startsWith('-')) {
      return currentResult.substring(1);
    } else {
      return '-$currentResult';
    }
  }

  // 处理百分比
  String handlePercentage(String currentResult) {
    try {
      double value = double.parse(currentResult) / 100;
      return formatResult(value);
    } catch (e) {
      return '0';
    }
  }

  // 处理等号计算
  String handleEquals(String expression) {
    try {
      return evaluateExpression(expression);
    } catch (e) {
      return '0';
    }
  }

  // 格式化显示过程
  String formatProcess(String currentProcess, String currentResult,
      String buttonText, String calculatedResult) {
    if (buttonText == '=') {
      if (!currentProcess.contains('=')) {
        final fullExpression = currentProcess.isEmpty
            ? currentResult
            : currentProcess.endsWith(currentResult)
                ? currentProcess
                : '$currentProcess $currentResult';
        return '$fullExpression = $calculatedResult';
      }
      return currentProcess;
    } else if (isOperator(buttonText)) {
      return '$currentResult $buttonText';
    } else if (buttonText == '%') {
      return calculatedResult;
    }
    return currentProcess;
  }

  // 主要处理方法
  Map<String, String> processInput(
      String buttonText, String currentResult, String currentProcess) {
    String newResult = currentResult;
    String newProcess = currentProcess;

    if (buttonText == 'C') {
      newResult = '0';
      newProcess = '';
    } else if (buttonText == '\u{232b}') {
      // 退格键 (Backspace) Unicode 字符
      newResult = handleBackspace(currentResult);
    } else if (buttonText == '+/-') {
      newResult = handleToggleSign(currentResult);
    } else if (buttonText == '%') {
      newResult = handlePercentage(currentResult);
      newProcess = newResult;
    } else if (buttonText == '=') {
      if (!currentProcess.contains('=')) {
        final fullExpression = currentProcess.isEmpty
            ? currentResult
            : currentProcess.endsWith(currentResult)
                ? currentProcess
                : '$currentProcess $currentResult';
        final calculatedResult = handleEquals(fullExpression);
        if (calculatedResult != '0') {
          newResult = calculatedResult;
          newProcess = formatProcess(
              currentProcess, currentResult, buttonText, calculatedResult);
        }
      }
    } else if (isOperator(buttonText)) {
      // 优化点1：处理连续运算符输入
      final parts = currentProcess.split(' ');

      // 当已有运算符时替换最后一个运算符
      if (parts.isNotEmpty && isOperator(parts.last)) {
        parts.removeLast();
        newProcess = '${parts.join(' ')} $buttonText'.trim();
      }
      // 优化点2：确保运算符前必须有有效数字
      else if (currentResult != '0' || currentProcess.isNotEmpty) {
        newProcess = '$currentProcess $buttonText'.trim();
      }

      // 优化点3：重置当前输入为初始状态
      newResult = '0';

      // 特殊处理：当直接输入运算符时显示 0+
      if (newProcess.isEmpty) {
        newProcess = '0$buttonText';
      }
    } else {
      // 处理数字和小数点
      if (currentProcess.contains('=')) {
        newProcess = '';
        newResult = handleNumberInput(buttonText, '0');
      } else {
        newResult = handleNumberInput(buttonText, currentResult);
        if (currentProcess.isEmpty) {
          newProcess = newResult;
        } else if (!currentProcess.contains('=')) {
          final parts = currentProcess.split(' ');
          if (parts.length % 2 == 0) {
            newProcess = '$currentProcess $newResult';
          } else {
            parts[parts.length - 1] = newResult;
            newProcess = parts.join(' ');
          }
        }
      }
    }

    return {
      'result': newResult,
      'process': newProcess,
    };
  }
}
