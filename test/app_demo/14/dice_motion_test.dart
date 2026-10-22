import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/14/widgets/dice/dice_motion.dart';

void main() {
  const layout = DiceStageLayout(width: 390, screenHeight: 844, headerBottom: 103);
  Vec3 v(double x, double y, double z) => (x: x, y: y, z: z);

  group('Rot3', () {
    test('identity leaves vectors unchanged and a quarter turn about z maps x to y', () {
      expect(Rot3.identity.apply(v(1, 2, 3)), v(1, 2, 3));
      final r = Rot3.z(math.pi / 2).apply(v(1, 0, 0));
      expect(r.x, closeTo(0, 1e-12));
      expect(r.y, closeTo(1, 1e-12));
      expect(r.z, closeTo(0, 1e-12));
    });

    test('rotations preserve length and compose right to left', () {
      final a = Rot3.x(.7);
      final b = Rot3.axisAngle(v(1, 2, -1), 1.3);
      final p = v(.3, -.8, .5);
      final both = (a * b).apply(p);
      final steps = a.apply(b.apply(p));
      expect(both.x, closeTo(steps.x, 1e-12));
      expect(both.y, closeTo(steps.y, 1e-12));
      expect(both.z, closeTo(steps.z, 1e-12));
      expect(V3.length(both), closeTo(V3.length(p), 1e-12));
    });

    test('a zero angle is exactly the identity', () {
      expect(Rot3.axisAngle(v(.2, .5, .9), 0).closeTo(Rot3.identity, 0), isTrue);
    });
  });

  group('DiceFaces', () {
    test('opposite faces sum to seven and normals are unit and orthogonal to the face frame', () {
      for (final face in DiceFaces.all) {
        final opposite = DiceFaces.all.firstWhere((other) => V3.dot(other.normal, face.normal) < -.9);
        expect(face.value + opposite.value, 7);
        expect(V3.length(face.normal), closeTo(1, 1e-12));
        expect(V3.dot(face.normal, face.right), 0);
        expect(V3.dot(face.normal, face.up), 0);
        final handed = V3.cross(face.right, face.up);
        expect(handed, face.normal, reason: 'right × up must equal the outward normal for face ${face.value}');
      }
      expect({for (final face in DiceFaces.all) face.value}, {1, 2, 3, 4, 5, 6});
    });

    test('each face shows exactly its number of pips inside the face', () {
      for (var value = 1; value <= 6; value++) {
        final pips = DiceFaces.pips(value);
        expect(pips.length, value);
        expect(pips, everyElement(predicate<Offset>((p) => p.dx.abs() <= .5 && p.dy.abs() <= .5)));
        expect(pips.toSet().length, value, reason: 'No two pips may sit on the same spot');
      }
    });

    test('the canonical pose brings each value to the front, upright', () {
      for (var value = 1; value <= 6; value++) {
        final rotation = DiceFaces.canonical(value);
        expect(DiceFaces.topFace(rotation), value);
        final face = DiceFaces.of(value);
        final normal = rotation.apply(face.normal);
        final right = rotation.apply(face.right);
        final up = rotation.apply(face.up);
        expect(normal.z, closeTo(1, 1e-12), reason: 'Face $value faces the viewer');
        expect(right.x, closeTo(1, 1e-12), reason: 'Face $value is not mirrored or turned');
        expect(up.y, closeTo(1, 1e-12));
      }
    });
  });

  group('DiceMotion timeline', () {
    test('the toss starts and ends on the ground and peaks in the middle of the flight', () {
      expect(DiceMotion.lift(0), 0);
      expect(DiceMotion.lift(DiceMotion.chargeEnd), 0);
      expect(DiceMotion.lift(1), closeTo(0, 1e-12));
      const mid = (DiceMotion.chargeEnd + DiceMotion.flightEnd) / 2;
      expect(DiceMotion.lift(mid), closeTo(1, 1e-9));
      for (var i = 0; i <= 200; i++) {
        expect(DiceMotion.lift(i / 200), inInclusiveRange(0, 1));
      }
    });

    test('there is a small bounce after landing that is lower than the toss', () {
      final bounce = [for (var i = 0; i <= 100; i++) DiceMotion.lift(DiceMotion.flightEnd + (1 - DiceMotion.flightEnd) * i / 100)];
      expect(bounce.reduce(math.max), inExclusiveRange(.03, .2));
    });

    test('movement is monotonic, decelerates and ends exactly at the landing', () {
      var previous = 0.0;
      for (var i = 0; i <= 100; i++) {
        final m = DiceMotion.move(i / 100);
        expect(m, greaterThanOrEqualTo(previous));
        previous = m;
      }
      expect(DiceMotion.move(0), 0);
      expect(DiceMotion.move(1), 1);
      expect(DiceMotion.move(.5) - DiceMotion.move(.4), greaterThan(DiceMotion.move(.9) - DiceMotion.move(.8)), reason: 'Slowing down');
    });

    test('charging squeezes the die slightly and then returns to full size', () {
      expect(DiceMotion.chargeScale(0), 1);
      expect(DiceMotion.chargeScale(DiceMotion.chargeEnd / 2), lessThan(1));
      expect(DiceMotion.chargeScale(DiceMotion.chargeEnd), 1);
      expect(DiceMotion.chargeScale(.5), 1);
    });
  });

  group('DiceStageLayout', () {
    test('die side is 26% of the width and the idle poses follow the spec', () {
      expect(layout.side, closeTo(390 * .26, 1e-9));
      expect(DiceStageLayout.restCenters(1), [const Offset(.5, .49)]);
      final two = DiceStageLayout.restCenters(2);
      expect(two[0].dy, .49);
      expect((two[1].dx - two[0].dx) * layout.width, closeTo(layout.side * 1.55, 1e-9), reason: 'Gap between dice is 55% of the side');
      expect((two[0].dx + two[1].dx) / 2, closeTo(.5, 1e-12));
      expect(DiceStageLayout.restRotations(2).map(DiceFaces.topFace), [1, 2], reason: 'Idle dice show 1 and 2');
    });

    test('the landing area keeps dice above the result text, below the selector and off the edges', () {
      final ext = layout.side / 2 * 1.36;
      final area = layout.landing;
      expect(area.left - ext, greaterThanOrEqualTo(DiceStageLayout.edgeMargin - 1e-9));
      expect(area.right + ext, lessThanOrEqualTo(layout.width - DiceStageLayout.edgeMargin + 1e-9));
      final globalBottom = area.bottom + layout.headerBottom + ext;
      final globalTop = area.top + layout.headerBottom - ext;
      expect(globalBottom, lessThan(844 * .63), reason: 'Below this line is the result text');
      expect(globalTop, greaterThan(844 * .17 + 22), reason: 'Above this line is the count selector');
      expect(area.width, greaterThan(layout.side * 1.3), reason: 'Two dice must fit');
    });

    test('normalised and pixel coordinates round trip', () {
      const px = Offset(123, 245);
      final back = layout.toPx(layout.toNorm(px));
      expect(back.dx, closeTo(px.dx, 1e-9));
      expect(back.dy, closeTo(px.dy, 1e-9));
    });
  });

  group('DiceMotionPlan', () {
    DiceMotionPlan plan(int seed, List<int> values, {bool reduce = false}) => DiceMotionPlan.create(
      layout: layout,
      starts: DiceStageLayout.restCenters(values.length),
      values: values,
      random: math.Random(seed),
      reduceMotion: reduce,
    );

    test('the final pose of every die shows exactly the rolled value', () {
      for (var seed = 0; seed < 300; seed++) {
        final values = [seed % 6 + 1, (seed ~/ 6) % 6 + 1];
        final p = plan(seed, values);
        expect([for (final die in p.dice) DiceFaces.topFace(die.finalRotation)], values, reason: 'seed $seed');
        // 倾斜很小，点数面依然基本正对观察者。
        for (var i = 0; i < 2; i++) {
          final z = p.dice[i].finalRotation.apply(DiceFaces.of(values[i]).normal).z;
          expect(z, greaterThan(.9));
        }
      }
    });

    test('landings stay in the landing area, never overlap and the first die is on the left', () {
      final area = layout.landing;
      final minDistance = layout.side * 1.3;
      for (var seed = 0; seed < 300; seed++) {
        final one = plan(seed, [3]).landings.map(layout.toPx).single;
        expect(area.inflate(1e-9).contains(one), isTrue, reason: 'seed $seed');
        final both = plan(seed, [5, 2]).landings.map(layout.toPx).toList();
        for (final point in both) {
          expect(area.inflate(1e-9).contains(point), isTrue, reason: 'seed $seed');
        }
        expect((both[0] - both[1]).distance, greaterThanOrEqualTo(minDistance - 1e-9), reason: 'seed $seed');
        expect(both[0].dx, lessThanOrEqualTo(both[1].dx), reason: 'The breakdown reads first + second from left to right');
      }
    });

    test('landing positions really vary from roll to roll', () {
      final spots = {for (var seed = 0; seed < 40; seed++) layout.toPx(plan(seed, [3]).landings.single).dx.round() ~/ 10};
      expect(spots.length, greaterThan(5));
    });

    test('the animation starts where the dice were and ends exactly on the landing pose', () {
      for (var seed = 0; seed < 100; seed++) {
        final p = plan(seed, [4, 6]);
        for (var i = 0; i < 2; i++) {
          final first = p.visualAt(i, 0, layout);
          expect((first.center - layout.toPx(p.dice[i].start)).distance, lessThan(1e-9));
          final last = p.visualAt(i, 1, layout);
          expect((last.center - layout.toPx(p.dice[i].end)).distance, lessThan(1e-9));
          expect(last.rotation.closeTo(p.dice[i].finalRotation, 1e-9), isTrue);
          expect(last.lift, closeTo(0, 1e-12));
          expect(last.scale, 1);
        }
      }
    });

    test('dice stay on screen during the whole roll and really travel and spin', () {
      final half = layout.side / 2;
      var maxDistance = 0.0;
      var orientations = <int>{};
      for (var seed = 0; seed < 60; seed++) {
        final p = plan(seed, [2, 5]);
        for (var i = 0; i < 2; i++) {
          for (var step = 0; step <= 200; step++) {
            final visual = p.visualAt(i, step / 200, layout);
            expect(visual.center.dx, inInclusiveRange(half, layout.width - half), reason: 'seed $seed die $i step $step');
            expect(visual.lift, inInclusiveRange(0, 1));
            maxDistance = math.max(maxDistance, (visual.center - layout.toPx(p.dice[i].start)).distance);
            orientations.add(DiceFaces.topFace(visual.rotation));
          }
        }
      }
      expect(maxDistance, greaterThan(100), reason: 'Dice travel across the screen, not on the spot');
      expect(orientations.length, 6, reason: 'Every face shows up while tumbling');
    });

    test('the die rises well above its landing spot mid flight', () {
      final p = plan(3, [6]);
      const mid = (DiceMotion.chargeEnd + DiceMotion.flightEnd) / 2;
      final visual = p.visualAt(0, mid, layout);
      expect(visual.floor.dy - visual.center.dy, greaterThan(844 * .1));
    });

    test('two dice follow different paths', () {
      final p = plan(11, [3, 3]);
      final a = p.visualAt(0, .4, layout).center;
      final b = p.visualAt(1, .4, layout).center;
      expect((a - b).distance, greaterThan(20));
      expect(p.dice[0].axisA, isNot(p.dice[1].axisA));
    });

    test('reduced motion does not travel or spin: the dice fade in on their landing pose', () {
      final p = plan(5, [4, 1], reduce: true);
      for (var i = 0; i < 2; i++) {
        final start = p.visualAt(i, 0, layout);
        final mid = p.visualAt(i, .5, layout);
        final end = p.visualAt(i, 1, layout);
        expect(start.opacity, 0);
        expect(mid.opacity, closeTo(.5, 1e-12));
        expect(end.opacity, 1);
        for (final visual in [start, mid, end]) {
          expect((visual.center - layout.toPx(p.dice[i].end)).distance, lessThan(1e-9));
          expect(visual.rotation.closeTo(p.dice[i].finalRotation), isTrue);
          expect(visual.lift, 0);
        }
      }
    });

    test('rest visuals are static and fully opaque', () {
      final visual = DiceMotionPlan.restVisual(const Offset(.5, .49), DiceFaces.canonical(1), layout);
      expect(visual.opacity, 1);
      expect(visual.lift, 0);
      expect(visual.center, layout.toPx(const Offset(.5, .49)));
    });
  });
}
