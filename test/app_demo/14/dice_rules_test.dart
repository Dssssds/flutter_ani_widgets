import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/models/dice_state.dart';
import 'package:flutter_x_widgets/app_demo/14/models/rules/dice_rules.dart';
import 'package:flutter_x_widgets/app_demo/14/models/services/random_source.dart';
import 'package:flutter_x_widgets/app_demo/14/models/view_models/dice_view_model.dart';

/// 按给定序列依次返回“面数 - 1”，所以传入点数即可。
class ScriptedDice implements IntRandomSource {
  ScriptedDice(List<int> faces) : _faces = faces;
  final List<int> _faces;
  int calls = 0;

  @override
  int nextInt(int max) {
    expect(max, DiceRules.faces);
    return _faces[calls++ % _faces.length] - 1;
  }
}

void main() {
  group('DiceRules', () {
    test('every random index maps to a face between 1 and 6', () {
      for (var face = 1; face <= 6; face++) {
        expect(DiceRules(ScriptedDice([face])).roll(1), [face]);
      }
    });

    test('rolls one value per die, in order, and the list cannot be modified', () {
      final random = ScriptedDice([5, 2]);
      final values = DiceRules(random).roll(2);
      expect(values, [5, 2]);
      expect(random.calls, 2);
      expect(() => values.add(1), throwsUnsupportedError);
    });

    test('the default source only produces legal faces and uses every face', () {
      final rules = DiceRules(DartIntRandomSource());
      final seen = <int>{};
      for (var i = 0; i < 600; i++) {
        final values = rules.roll(2);
        expect(values, everyElement(inInclusiveRange(1, 6)));
        seen.addAll(values);
      }
      expect(seen, {1, 2, 3, 4, 5, 6});
    });

    test('two dice give a total between 2 and 12 computed only from the final values', () {
      final totals = <int>{};
      for (var a = 1; a <= 6; a++) {
        for (var b = 1; b <= 6; b++) {
          final vm = DiceViewModel(DiceRules(ScriptedDice([a, b])))..setCount(2);
          final round = vm.requestRoll()!;
          vm.finish(round.id);
          expect(vm.state.total, a + b);
          totals.add(vm.state.total!);
          vm.dispose();
        }
      }
      expect(totals, {for (var t = 2; t <= 12; t++) t});
    });
  });

  group('DiceViewModel', () {
    test('starts idle with one die and no result', () {
      final vm = DiceViewModel(DiceRules(ScriptedDice([3])));
      expect(vm.state.phase, DicePhase.idle);
      expect(vm.state.count, 1);
      expect(vm.state.values, isNull);
      expect(vm.state.total, isNull);
      vm.dispose();
    });

    test('rolling locks, hides the pending values and rejects duplicate or stale calls', () {
      final random = ScriptedDice([4, 1]);
      final vm = DiceViewModel(DiceRules(random))..setCount(2);
      final round = vm.requestRoll()!;
      expect(round.values, [4, 1]);
      expect(round.count, 2);
      expect(vm.state.phase, DicePhase.rolling);
      expect(vm.state.values, isNull, reason: 'Values stay hidden until the dice land');
      expect(vm.requestRoll(), isNull);
      expect(random.calls, 2, reason: 'A rejected request must not draw again');
      expect(vm.finish(round.id + 1), isFalse);
      expect(vm.finish(round.id), isTrue);
      expect(vm.state.values, [4, 1]);
      expect(vm.finish(round.id), isFalse, reason: 'Finishing is idempotent');
      vm.dispose();
    });

    test('switching the count clears the result and goes back to idle', () {
      final vm = DiceViewModel(DiceRules(ScriptedDice([5, 2, 3])))..setCount(2);
      vm.finish(vm.requestRoll()!.id);
      expect(vm.state.phase, DicePhase.result);
      expect(vm.setCount(1), isTrue);
      expect(vm.state.phase, DicePhase.idle);
      expect(vm.state.count, 1);
      expect(vm.state.values, isNull);
      vm.dispose();
    });

    test('selecting the current count changes nothing and does not notify', () {
      final vm = DiceViewModel(DiceRules(ScriptedDice([5])));
      vm.finish(vm.requestRoll()!.id);
      var notifications = 0;
      vm.addListener(() => notifications++);
      expect(vm.setCount(1), isFalse);
      expect(vm.state.phase, DicePhase.result, reason: 'The result must survive re-selecting the same count');
      expect(notifications, 0);
      vm.dispose();
    });

    test('the count cannot change while rolling and unsupported counts are rejected', () {
      final vm = DiceViewModel(DiceRules(ScriptedDice([5])));
      expect(vm.setCount(0), isFalse);
      expect(vm.setCount(3), isFalse);
      expect(vm.state.count, 1);
      final round = vm.requestRoll()!;
      expect(vm.setCount(2), isFalse);
      expect(vm.state.count, 1);
      expect(vm.finish(round.id), isTrue);
      vm.dispose();
    });

    test('round ids increase and a stale round cannot finish a newer one', () {
      final vm = DiceViewModel(DiceRules(ScriptedDice([1, 2, 3])));
      final first = vm.requestRoll()!;
      vm.finish(first.id);
      final second = vm.requestRoll()!;
      expect(second.id, first.id + 1);
      expect(vm.finish(first.id), isFalse);
      expect(vm.state.phase, DicePhase.rolling);
      expect(vm.finish(second.id), isTrue);
      expect(vm.state.values, [2]);
      vm.dispose();
    });

    test('after dispose nothing changes or throws', () {
      final vm = DiceViewModel(DiceRules(ScriptedDice([1])));
      final round = vm.requestRoll()!;
      vm.dispose();
      expect(vm.finish(round.id), isFalse);
      expect(vm.requestRoll(), isNull);
      expect(vm.setCount(2), isFalse);
    });
  });
}
