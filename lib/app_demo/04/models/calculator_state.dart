// 计算器状态管理类
class CalculatorState {
  // 当前显示的数字
  String _currentNumber = '0';
  // 上一个数字（用于二元运算）
  String _previousNumber = '';
  // 当前运算符
  String _operator = '';
  // 是否开始输入新数字
  bool _newNumber = true;
  // 当前数字是否包含小数点
  bool _hasDecimal = false;
  // 是否出现错误
  bool _hasError = false;
  // 最大数字位数
  static const int maxDigits = 15;

  // getter
  String get currentNumber => _currentNumber;
  String get previousNumber => _previousNumber;
  String get operator => _operator;
  bool get hasError => _hasError;

  // 重置状态
  void reset() {
    _currentNumber = '0';
    _previousNumber = '';
    _operator = '';
    _newNumber = true;
    _hasDecimal = false;
    _hasError = false;
  }

  // 添加数字
  bool addDigit(String digit) {
    if (_hasError) return false;

    // 检查数字长度
    if (!_newNumber && _currentNumber.replaceAll('-', '').length >= maxDigits) {
      return false;
    }

    if (_newNumber) {
      _currentNumber = digit;
      _newNumber = false;
    } else {
      _currentNumber += digit;
    }
    return true;
  }

  // 添加小数点
  bool addDecimal() {
    if (_hasError || _hasDecimal) return false;

    if (_newNumber) {
      _currentNumber = '0.';
      _newNumber = false;
    } else {
      _currentNumber += '.';
    }
    _hasDecimal = true;
    return true;
  }

  // 设置运算符
  bool setOperator(String newOperator) {
    if (_hasError) return false;

    if (_previousNumber.isNotEmpty && !_newNumber) {
      // 执行前一次运算
      calculate();
      if (_hasError) return false;
    }

    _operator = newOperator;
    if (!_newNumber) {
      _previousNumber = _currentNumber;
      _newNumber = true;
    }
    _hasDecimal = false;
    return true;
  }

  // 改变正负号
  void toggleSign() {
    if (_hasError) return;
    if (_currentNumber != '0') {
      if (_currentNumber.startsWith('-')) {
        _currentNumber = _currentNumber.substring(1);
      } else {
        _currentNumber = '-$_currentNumber';
      }
    }
  }

  // 计算百分比
  void calculatePercentage() {
    if (_hasError) return;
    try {
      double number = double.parse(_currentNumber);
      number = number / 100;
      _currentNumber = _formatNumber(number);
    } catch (e) {
      setError();
    }
  }

  // 执行计算
  void calculate() {
    if (_hasError || _operator.isEmpty || _previousNumber.isEmpty) return;

    try {
      double num1 = double.parse(_previousNumber);
      double num2 = double.parse(_currentNumber);
      double result = 0;

      switch (_operator) {
        case '+':
          result = num1 + num2;
          break;
        case '-':
          result = num1 - num2;
          break;
        case '×':
          result = num1 * num2;
          break;
        case '÷':
          if (num2 == 0) {
            setError();
            return;
          }
          result = num1 / num2;
          break;
      }

      _currentNumber = _formatNumber(result);
      _previousNumber = '';
      _operator = '';
      _newNumber = true;
      _hasDecimal = _currentNumber.contains('.');
    } catch (e) {
      setError();
    }
  }

  // 设置错误状态
  void setError() {
    _hasError = true;
    _currentNumber = 'Error';
    _previousNumber = '';
    _operator = '';
  }

  // 格式化数字
  String _formatNumber(double number) {
    if (number.isInfinite || number.isNaN) {
      setError();
      return 'Error';
    }

    // 检查数字是否过大
    if (number.abs() > 1e15) {
      return number.toStringAsExponential(10);
    }

    String result = number.toString();
    // 移除末尾的0和不必要的小数点
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0*$'), '');
      if (result.endsWith('.')) {
        result = result.substring(0, result.length - 1);
      }
    }
    return result;
  }
}
