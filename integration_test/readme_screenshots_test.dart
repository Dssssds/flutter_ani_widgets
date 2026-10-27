import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/main.dart';
import 'package:integration_test/integration_test.dart';

// 生成 README 截图：
// 1. flutter drive --driver=test_driver/integration_test.dart \
//      --target=integration_test/readme_screenshots_test.dart -d <simulator-id>
//    产物是 docs/screenshots/ 下的 PNG（组件 01–28、Demo App 01–16）。
// 2. 用 sips 转成 402 宽 JPEG，覆盖 README 引用的同名 .jpg：
//    sips --resampleWidth 402 -s format jpeg -s formatOptions 80 in.png --out out.jpg
// 3. APP-04 的 3D 模型是原生平台视图，Flutter 侧截图拍不到：测试停在
//    READY_FOR_NATIVE_SCREENSHOT 时执行 xcrun simctl io booted screenshot，
//    再按第 2 步转换。

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsApp.debugAllowBannerOverride = false;

  testWidgets('首页', (tester) async {
    await tester.pumpWidget(const AnimationShowcaseApp());
    await _pumpFor(tester, const Duration(seconds: 2), 'home');
    await binding.takeScreenshot('home');
  });

  final components = HomeScreen().components;
  for (var index = 0; index < components.length; index++) {
    final example = components[index];
    final name = 'components/${(index + 1).toString().padLeft(2, '0')}';
    testWidgets('${example.title} · $name', (tester) async {
      await _capture(tester, binding, example, name);
    });
  }

  final demoApps = HomeScreen().demoApps;
  for (var index = 0; index < demoApps.length; index++) {
    final example = demoApps[index];
    final name = 'apps/${(index + 1).toString().padLeft(2, '0')}';
    testWidgets('${example.title} · $name', (tester) async {
      await _capture(tester, binding, example, name);
    });
  }
}

Future<void> _capture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  AnimationExample example,
  String name,
) async {
  await tester.pumpWidget(_frame(example));
  await _pumpFor(tester, const Duration(seconds: 3), name);

  if (name == 'apps/04') {
    // 平台视图不会进入 Flutter 截图，跳过自身截图，只留出宿主机抓屏的时间。
    await _pumpFor(tester, const Duration(seconds: 6), name);
    debugPrint('READY_FOR_NATIVE_SCREENSHOT');
    await Future<void>.delayed(const Duration(seconds: 15));
  } else {
    await binding.takeScreenshot(name);
  }

  await tester.pumpWidget(const SizedBox.shrink());
  await _pumpFor(tester, const Duration(milliseconds: 400), name);
}

Widget _frame(AnimationExample example) {
  return MaterialApp(
    title: 'Flutter 实验室',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey,
    ),
    home:
        example.isFullScreen
            ? FullScreen(example: example)
            : DetailScreen(example: example),
  );
}

Future<void> _pumpFor(
  WidgetTester tester,
  Duration duration,
  String name,
) async {
  const step = Duration(milliseconds: 100);
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += step) {
    await tester.pump(step);
    final error = tester.takeException();
    if (error != null) {
      debugPrint('[screenshot] $name 忽略异常: $error');
    }
  }
}
