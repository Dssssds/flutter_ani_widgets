import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/game_definition.dart';
import 'package:flutter_x_widgets/app_demo/14/models/settings_state.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/game_menu_tile.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/menu/menu_band_shape.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/motion/motion_spec.dart';

void main() {
  test('Slanted paths share a 14px transition zone and last band stays flat', () {
    const size = Size(390, 104);
    final rising = const MenuBandClipper(edge: MenuBandEdge.rising).getClip(size);
    final falling = const MenuBandClipper(edge: MenuBandEdge.falling).getClip(size);
    final flat = const MenuBandClipper(edge: MenuBandEdge.straight).getClip(size);
    expect(rising.contains(const Offset(1, 100)), isTrue);
    expect(rising.contains(const Offset(389, 100)), isFalse);
    expect(falling.contains(const Offset(1, 100)), isFalse);
    expect(falling.contains(const Offset(389, 100)), isTrue);
    expect(flat.contains(const Offset(389, 103)), isTrue);
    for (final path in [rising, falling, flat]) {
      expect(path.contains(const Offset(195, 50)), isTrue);
      expect(path.contains(const Offset(195, 105)), isFalse);
    }
  });

  testWidgets('Slanted visible face owns taps and content remains horizontal', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 390,
            height: 104,
            child: GameMenuTile(
              game: const GameDefinition('coin', 'Coin Toss', '抛硬币', route: '/coin'),
              color: Colors.yellow,
              nextColor: Colors.green,
              icon: Icons.toll,
              seamless: true,
              edge: MenuBandEdge.rising,
              motion: MotionSpec(const SettingsState()),
              onPressed: () => taps++,
            ),
          ),
        ),
      ),
    );
    final rect = tester.getRect(find.byType(GameMenuTile));
    await tester.tapAt(rect.topLeft + const Offset(389, 100));
    await tester.pumpAndSettle();
    expect(taps, 0);
    await tester.tap(find.text('Coin Toss'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(find.ancestor(of: find.text('Coin Toss'), matching: find.byType(RotatedBox)), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
