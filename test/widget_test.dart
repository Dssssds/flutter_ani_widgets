import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/main.dart';

void main() {
  testWidgets('Showcase App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnimationShowcaseApp());
    expect(find.text('组件'), findsOneWidget);
    expect(find.text('DemoAPP'), findsOneWidget);
  });
}
