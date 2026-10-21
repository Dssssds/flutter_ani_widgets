import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/coin_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/rules/coin_rules.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/coin_view_model.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/coin/coin_motion.dart';

class SequenceRandom implements RandomSource {
  int calls = 0;
  @override
  bool nextBool() => calls++ % 2 == 0;
}

void main() {
  test('Every start and target combination preserves minimum turns and parity', () {
    for (final start in [0, 1, 10, 15]) {
      for (final side in CoinSide.values) {
        final end = CoinRules.targetHalfTurns(start, side);
        expect(end - start, greaterThanOrEqualTo(6));
        expect(end.isEven, side == CoinSide.heads);
        expect(CoinMotion.halfTurns(0, start, end, reduceMotion: false), start);
        expect(CoinMotion.halfTurns(.75, start, end, reduceMotion: false), end);
        expect(CoinMotion.showsHeads(end.toDouble()), side == CoinSide.heads);
        expect(math.cos(CoinMotion.faceAngle(end.toDouble())), closeTo(1, .00001));
      }
    }
  });

  test('Round locks, hides pending result and rejects stale or duplicate callbacks', () {
    final random = SequenceRandom();
    final vm = CoinViewModel(CoinRules(random));
    final round = vm.requestFlip(0)!;
    expect(vm.state.revealedSide, isNull);
    expect(vm.requestFlip(0), isNull);
    expect(random.calls, 1);
    expect(vm.finish(round.id), isFalse);
    expect(vm.reveal(round.id + 1), isFalse);
    expect(vm.reveal(round.id), isTrue);
    expect(vm.state.revealedSide, CoinSide.heads);
    expect(vm.reveal(round.id), isFalse);
    expect(vm.requestFlip(0), isNull);
    expect(vm.finish(round.id), isTrue);
    expect(vm.finish(round.id), isFalse);
    final next = vm.requestFlip(round.targetHalfTurns)!;
    expect(vm.reveal(round.id), isFalse);
    vm.settle(next.id);
    expect(vm.state.revealedSide, CoinSide.tails);
    vm.settle(next.id);
    expect(random.calls, 2);
    vm.dispose();
    expect(vm.requestFlip(0), isNull);
    expect(vm.reveal(next.id), isFalse);
  });

  test('Thirty rounds stay consistent and reduced motion commits final orientation', () {
    final random = SequenceRandom();
    final vm = CoinViewModel(CoinRules(random));
    var settled = 0;
    for (var i = 0; i < 30; i++) {
      final round = vm.requestFlip(settled)!;
      expect(round.startHalfTurns, settled);
      vm.reveal(round.id);
      vm.finish(round.id);
      settled = round.targetHalfTurns;
      expect(CoinMotion.halfTurns(1, round.startHalfTurns, settled, reduceMotion: true), settled);
      expect(settled.isEven, vm.state.revealedSide == CoinSide.heads);
    }
    expect(random.calls, 30);
    vm.dispose();
  });
}
