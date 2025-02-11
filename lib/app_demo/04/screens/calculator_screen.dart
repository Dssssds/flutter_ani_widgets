import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/04/models/calcuation_model.dart';
import 'package:flutter_x_widgets/app_demo/04/services/calculator_service.dart';
import 'package:flutter_x_widgets/app_demo/04/widgets/calculator_button.dart';
import 'package:flutter_x_widgets/app_demo/04/widgets/display_widget.dart';

import '../utils/constants.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  final CalculationModel _calculationModel = CalculationModel();
  final CalculatorService _calculatorService = CalculatorService();
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 创建一个来回晃动的动画
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      // 使用弹性曲线使动画更自然
      curve: Curves.elasticIn,
    ));

    // 监听动画状态，完成后重置
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // 触发晃动动画
  void _triggerShakeAnimation() {
    _shakeController.forward();
  }

  void _handleButtonPressed(String buttonText) {
    setState(() {
      final result = _calculatorService.processInput(
        buttonText,
        _calculationModel.result,
        _calculationModel.process,
      );

      // print(
      // '输入: $buttonText, 结果: ${result['result']}, 过程: ${result['process']}');
      _calculationModel.result = result['result'] ?? '0';
      _calculationModel.process = result['process'] ?? '';

      // 如果计算出错，触发晃动动画
      if (buttonText == '=' && _calculationModel.result == '0') {
        _triggerShakeAnimation();
      }
    });
  }

  bool isOperator(String text) {
    return _calculatorService.isOperator(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      body: Column(
        children: [
          Expanded(
            child: DisplayWidget(
              result: _calculationModel.result,
              process: _calculationModel.process,
            ),
          ),
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              // 使用sin函数创建左右晃动效果
              final offset = sin(_shakeAnimation.value * 3 * pi) * 10.0;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: SizedBox(
              height: 500, // 设置固定高度
              child: Column(
                children: [
                  buildRow(['C', '%', '\u{232b}', '÷']),
                  buildRow(['7', '8', '9', '×']),
                  buildRow(['4', '5', '6', '-']),
                  buildRow(['1', '2', '3', '+']),
                  buildRow(['0', '.', '+/-', '=']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((buttonText) {
          return CalculatorButton(
            text: buttonText,
            onPressed: () => _handleButtonPressed(buttonText),
            buttonColor: AppColors.transparentColor, // 使用实用函数
            textColor: getTextColor(buttonText),
            fontFamily: getFontFamily(buttonText),
          );
        }).toList(),
      ),
    );
  }

  // 根据按钮文本获取颜色
  Color getButtonColor(String buttonText) {
    if (buttonText == '÷' ||
        buttonText == '×' ||
        buttonText == '-' ||
        buttonText == '+' ||
        buttonText == '=') {
      return AppColors.operatorButtonColor;
    } else if (buttonText == 'C') {
      return AppColors.clearButtonColor;
    } else {
      return AppColors.numberButtonColor;
    }
  }

  Color getTextColor(String buttonText) {
    if (buttonText == '÷' ||
        buttonText == '×' ||
        buttonText == '-' ||
        buttonText == '+' ||
        buttonText == '=') {
      return AppColors.operatorButtonColor;
    } else if (buttonText == 'C' ||
        buttonText == '\u{232b}' ||
        buttonText == '%') {
      return AppColors.clearButtonColor;
    } else {
      return AppColors.numberTextColor;
    }
  }

  String getFontFamily(String buttonText) {
    if (buttonText == '÷' ||
        buttonText == '×' ||
        buttonText == '-' ||
        buttonText == '+' ||
        buttonText == '=') {
      return AppFonts.sfProDisplayRegular;
    } else if (buttonText == 'C' ||
        buttonText == '\u{232b}' ||
        buttonText == '%') {
      return AppFonts.sfProDisplayRegular;
    } else {
      return AppFonts.neumaticGothicSemiBold;
    }
  }
}
