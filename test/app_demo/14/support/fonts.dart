import 'package:flutter/services.dart';

/// 测试环境默认只有方块字体，标题宽度和基线都会与真机完全不同。
/// 依赖标题排版（宽度、基线、是否放得下页码）的测试要先加载项目自带的展示字体。
Future<void> loadDisplayFont() async {
  final loader = FontLoader('NeumaticGothic-Black')..addFont(rootBundle.load('assets/fonts/NeumaticGothic-Black.ttf'));
  await loader.load();
}
