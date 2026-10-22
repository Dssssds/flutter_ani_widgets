import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

/// 三维向量。坐标系：x 向右、y 向上、z 朝向观察者。
typedef Vec3 = ({double x, double y, double z});

abstract final class V3 {
  static const zero = (x: 0.0, y: 0.0, z: 0.0);
  static Vec3 add(Vec3 a, Vec3 b) => (x: a.x + b.x, y: a.y + b.y, z: a.z + b.z);
  static Vec3 scale(Vec3 a, double k) => (x: a.x * k, y: a.y * k, z: a.z * k);
  static double dot(Vec3 a, Vec3 b) => a.x * b.x + a.y * b.y + a.z * b.z;
  static Vec3 cross(Vec3 a, Vec3 b) => (x: a.y * b.z - a.z * b.y, y: a.z * b.x - a.x * b.z, z: a.x * b.y - a.y * b.x);
  static double length(Vec3 a) => math.sqrt(dot(a, a));

  static Vec3 normalize(Vec3 a) {
    final len = length(a);
    return len == 0 ? a : scale(a, 1 / len);
  }
}

/// 3×3 旋转矩阵（按行存储）。不可变，`a * b` 表示先应用 b 再应用 a。
class Rot3 {
  const Rot3._(this._m);

  static const identity = Rot3._(<double>[1, 0, 0, 0, 1, 0, 0, 0, 1]);

  /// 绕任意轴旋转（罗德里格斯公式）。
  factory Rot3.axisAngle(Vec3 axis, double angle) {
    final n = V3.normalize(axis);
    final c = math.cos(angle);
    final s = math.sin(angle);
    final t = 1 - c;
    return Rot3._(<double>[
      t * n.x * n.x + c,
      t * n.x * n.y - s * n.z,
      t * n.x * n.z + s * n.y,
      t * n.x * n.y + s * n.z,
      t * n.y * n.y + c,
      t * n.y * n.z - s * n.x,
      t * n.x * n.z - s * n.y,
      t * n.y * n.z + s * n.x,
      t * n.z * n.z + c,
    ]);
  }

  factory Rot3.x(double angle) => Rot3.axisAngle((x: 1.0, y: 0.0, z: 0.0), angle);
  factory Rot3.y(double angle) => Rot3.axisAngle((x: 0.0, y: 1.0, z: 0.0), angle);
  factory Rot3.z(double angle) => Rot3.axisAngle((x: 0.0, y: 0.0, z: 1.0), angle);

  final List<double> _m;

  Vec3 apply(Vec3 v) => (
    x: _m[0] * v.x + _m[1] * v.y + _m[2] * v.z,
    y: _m[3] * v.x + _m[4] * v.y + _m[5] * v.z,
    z: _m[6] * v.x + _m[7] * v.y + _m[8] * v.z,
  );

  Rot3 operator *(Rot3 other) {
    final a = _m;
    final b = other._m;
    return Rot3._(<double>[
      for (var row = 0; row < 3; row++)
        for (var col = 0; col < 3; col++) a[row * 3] * b[col] + a[row * 3 + 1] * b[3 + col] + a[row * 3 + 2] * b[6 + col],
    ]);
  }

  /// 逐项比较，供测试和“是否已回到目标姿态”的判断使用。
  bool closeTo(Rot3 other, [double epsilon = 1e-9]) {
    for (var i = 0; i < 9; i++) {
      if ((_m[i] - other._m[i]).abs() > epsilon) return false;
    }
    return true;
  }
}

/// 骰子的一个面：法线、面内向右和向上的方向（右手系，right × up = normal）。
typedef DiceFace = ({int value, Vec3 normal, Vec3 right, Vec3 up});

/// 标准骰子：相对两面点数之和为 7。
///
/// 待机姿态下 1 点朝向观察者、2 点在上、3 点在右。
abstract final class DiceFaces {
  static const List<DiceFace> all = [
    (value: 1, normal: (x: 0.0, y: 0.0, z: 1.0), right: (x: 1.0, y: 0.0, z: 0.0), up: (x: 0.0, y: 1.0, z: 0.0)),
    (value: 6, normal: (x: 0.0, y: 0.0, z: -1.0), right: (x: -1.0, y: 0.0, z: 0.0), up: (x: 0.0, y: 1.0, z: 0.0)),
    (value: 2, normal: (x: 0.0, y: 1.0, z: 0.0), right: (x: 1.0, y: 0.0, z: 0.0), up: (x: 0.0, y: 0.0, z: -1.0)),
    (value: 5, normal: (x: 0.0, y: -1.0, z: 0.0), right: (x: 1.0, y: 0.0, z: 0.0), up: (x: 0.0, y: 0.0, z: 1.0)),
    (value: 3, normal: (x: 1.0, y: 0.0, z: 0.0), right: (x: 0.0, y: 0.0, z: -1.0), up: (x: 0.0, y: 1.0, z: 0.0)),
    (value: 4, normal: (x: -1.0, y: 0.0, z: 0.0), right: (x: 0.0, y: 0.0, z: 1.0), up: (x: 0.0, y: 1.0, z: 0.0)),
  ];

  static DiceFace of(int value) => all.firstWhere((face) => face.value == value);

  /// 让 [value] 点的面正对观察者、且面内上下左右与屏幕一致的姿态。
  static Rot3 canonical(int value) => switch (value) {
    1 => Rot3.identity,
    2 => Rot3.x(math.pi / 2),
    3 => Rot3.y(-math.pi / 2),
    4 => Rot3.y(math.pi / 2),
    5 => Rot3.x(-math.pi / 2),
    _ => Rot3.y(math.pi),
  };

  /// 当前最朝向观察者的面的点数。
  static int topFace(Rot3 rotation) {
    var best = all.first;
    var bestZ = double.negativeInfinity;
    for (final face in all) {
      final z = rotation.apply(face.normal).z;
      if (z > bestZ) {
        bestZ = z;
        best = face;
      }
    }
    return best.value;
  }

  /// 点数的布局，坐标取 [-0.5, 0.5]，x 向右、y 向上，按面内尺寸缩放。
  static List<Offset> pips(int value) => switch (value) {
    1 => const [Offset(0, 0)],
    2 => const [Offset(-.5, .5), Offset(.5, -.5)],
    3 => const [Offset(-.5, .5), Offset(0, 0), Offset(.5, -.5)],
    4 => const [Offset(-.5, .5), Offset(.5, .5), Offset(-.5, -.5), Offset(.5, -.5)],
    5 => const [Offset(-.5, .5), Offset(.5, .5), Offset(0, 0), Offset(-.5, -.5), Offset(.5, -.5)],
    _ => const [Offset(-.5, .5), Offset(-.5, 0), Offset(-.5, -.5), Offset(.5, .5), Offset(.5, 0), Offset(.5, -.5)],
  };
}

/// 一次掷骰的归一化时间轴（0..1）。
///
/// - 0–5%：蓄力，骰子轻微收缩，点击后立刻起动，不留静止期。
/// - 5%–78%：抛起翻滚，沿弧线位移，大幅旋转。
/// - 78%–100%：落地小幅弹跳、旋转减速直到停稳。
abstract final class DiceMotion {
  static const double chargeEnd = .05;
  static const double flightEnd = .78;

  static double _easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();

  /// 位移与旋转共用的进度：起步快、末尾慢，终点精确为 1。
  static double move(double progress) => _easeOutCubic(((progress - chargeEnd) / (1 - chargeEnd)).clamp(0.0, 1.0));

  /// 抛起高度的归一化值：飞行段为半个正弦弧，落地后再有一次衰减的小弹跳。
  static double lift(double progress) {
    if (progress <= chargeEnd) return 0;
    if (progress <= flightEnd) {
      return math.sin((progress - chargeEnd) / (flightEnd - chargeEnd) * math.pi);
    }
    final v = ((progress - flightEnd) / (1 - flightEnd)).clamp(0.0, 1.0);
    return .16 * math.sin(v * math.pi) * (1 - .55 * v);
  }

  /// 蓄力时的轻微收缩。
  static double chargeScale(double progress) {
    if (progress >= chargeEnd) return 1;
    return 1 - .06 * math.sin((progress / chargeEnd).clamp(0.0, 1.0) * math.pi);
  }
}

/// 舞台布局：所有位置用“占整屏的比例”归一化保存，旋转屏幕后按比例跟随。
///
/// 坐标原点在舞台左上角，也就是顶部栏之下；归一化 y 以整屏高度为基准。
class DiceStageLayout {
  const DiceStageLayout({required this.width, required this.screenHeight, required this.headerBottom});

  final double width;
  final double screenHeight;
  final double headerBottom;

  /// 骰子边长约为屏宽的 26%。
  double get side => width * .26;

  /// 待机时骰子中心约在屏高 49% 处。
  static const double restY = .49;

  /// 落点范围：中心 y 在屏高 30%–52% 之间，骰子下沿不会越过结果区（63%），上沿不会压到数量切换。
  static const double landingTop = .30;
  static const double landingBottom = .52;

  /// 距屏幕左右边缘的最小留白。
  static const double edgeMargin = 16;

  /// 旋转时立方体轮廓的最大外延（相对半边长）。
  static const double _extent = 1.36;

  Offset toPx(Offset norm) => Offset(norm.dx * width, norm.dy * screenHeight - headerBottom);
  Offset toNorm(Offset px) => Offset(px.dx / width, (px.dy + headerBottom) / screenHeight);
  double yFor(double fraction) => fraction * screenHeight - headerBottom;

  /// 落点中心的取值范围（像素）。
  Rect get landing {
    final ext = side / 2 * _extent;
    final left = edgeMargin + ext;
    final top = yFor(landingTop);
    return Rect.fromLTRB(left, top, math.max(left, width - edgeMargin - ext), math.max(top, yFor(landingBottom)));
  }

  /// 翻滚途中途经点的取值范围（像素）：比落点范围大得多，骰子会跑向屏幕两侧。
  Rect get roam {
    final half = side / 2;
    final left = 20 + half;
    final top = yFor(.16) + half;
    return Rect.fromLTRB(left, top, math.max(left, width - 20 - half), math.max(top, yFor(.68) - half));
  }

  /// 待机时各枚骰子的归一化中心：一枚居中；两枚并排，间距为边长的 55%。
  static List<Offset> restCenters(int count) {
    if (count == 1) return const [Offset(.5, restY)];
    // 中心距 = 边长 × 1.55，边长 = 屏宽 × 0.26，所以每侧偏移 = 0.26 × 0.775。
    const offset = .26 * .775;
    return const [Offset(.5 - offset, restY), Offset(.5 + offset, restY)];
  }

  /// 待机姿态：第 i 枚朝上的点数是 i + 1。
  static List<Rot3> restRotations(int count) => [for (var i = 0; i < count; i++) DiceFaces.canonical(i + 1)];
}

/// 某一帧一枚骰子的渲染状态。
class DiceVisual {
  const DiceVisual({
    required this.center,
    required this.floor,
    required this.rotation,
    this.lift = 0,
    this.scale = 1,
    this.opacity = 1,
  });

  /// 骰子中心（像素）。
  final Offset center;

  /// 投影落在地面上的位置（像素）：不含抛起高度。
  final Offset floor;
  final Rot3 rotation;

  /// 抛起高度的归一化值 0..1，用来缩小、变淡投影，也用来决定叠放顺序。
  final double lift;
  final double scale;
  final double opacity;
}

/// 一枚骰子在本次投掷中的完整运动计划。位置均为归一化坐标。
class DiePlan {
  const DiePlan({
    required this.start,
    required this.waypoint,
    required this.end,
    required this.finalRotation,
    required this.axisA,
    required this.axisB,
    required this.angleA,
    required this.angleB,
    required this.toss,
  });

  final Offset start;
  final Offset waypoint;
  final Offset end;

  /// 落定姿态：点数面朝向观察者，再叠加一点随机的倾斜和面内旋转。
  final Rot3 finalRotation;
  final Vec3 axisA;
  final Vec3 axisB;
  final double angleA;
  final double angleB;

  /// 抛起的最大高度，占整屏高度的比例。
  final double toss;
}

/// 一次掷骰的运动计划：落点、途经点、翻滚轴都在点击时确定，动画只负责呈现。
class DiceMotionPlan {
  const DiceMotionPlan({required this.dice, required this.reduceMotion});

  final List<DiePlan> dice;

  /// 减少动态效果：不翻滚，骰子直接淡入落定姿态。
  final bool reduceMotion;

  List<Offset> get landings => [for (final die in dice) die.end];
  List<Rot3> get finals => [for (final die in dice) die.finalRotation];

  /// [starts] 是各枚骰子当前的位置；[values] 是已经确定的点数，落定姿态必须朝上这些点数。
  factory DiceMotionPlan.create({
    required DiceStageLayout layout,
    required List<Offset> starts,
    required List<int> values,
    required math.Random random,
    required bool reduceMotion,
  }) {
    assert(starts.length == values.length);
    final ends = pickLanding(layout, values.length, random);
    final roam = layout.roam;
    double range(double min, double max) => min + random.nextDouble() * (max - min);
    Vec3 axis() {
      // 在立方体内取点再归一化；落在原点附近时退回 y 轴，避免零向量。
      final v = (x: range(-1, 1), y: range(-1, 1), z: range(-1, 1));
      return V3.length(v) < .2 ? (x: 0.0, y: 1.0, z: 0.0) : V3.normalize(v);
    }

    double turns(double min, double max) => (random.nextBool() ? 1 : -1) * range(min, max) * math.pi;

    return DiceMotionPlan(
      reduceMotion: reduceMotion,
      dice: [
        for (var i = 0; i < values.length; i++)
          DiePlan(
            start: starts[i],
            waypoint: layout.toNorm(Offset(range(roam.left, roam.right), range(roam.top, roam.bottom))),
            end: ends[i],
            // 落定姿态 = 面内旋转 · 倾斜 · 点数面朝前。倾斜很小，点数面仍然占主导。
            finalRotation:
                Rot3.z(range(-.26, .26)) * Rot3.x(range(-.12, .12)) * Rot3.y(range(-.12, .12)) * DiceFaces.canonical(values[i]),
            axisA: axis(),
            axisB: axis(),
            angleA: turns(2.5, 5),
            angleB: turns(1.5, 3.5),
            toss: range(.12, .20),
          ),
      ],
    );
  }

  /// 在舞台区内随机取落点；两枚时保证中心距不小于边长的 1.3 倍，不重叠。
  static List<Offset> pickLanding(DiceStageLayout layout, int count, math.Random random) {
    final area = layout.landing;
    Offset sample() => Offset(area.left + random.nextDouble() * area.width, area.top + random.nextDouble() * area.height);
    if (count == 1) return [layout.toNorm(sample())];
    final minDistance = layout.side * 1.3;
    for (var attempt = 0; attempt < 80; attempt++) {
      final a = sample();
      final b = sample();
      if ((a - b).distance < minDistance) continue;
      // 第一枚落在左边，分项 “第一枚 + 第二枚” 从左到右读才与屏幕上的点数顺序一致。
      final (left, right) = a.dx <= b.dx ? (a, b) : (b, a);
      return [layout.toNorm(left), layout.toNorm(right)];
    }
    // 范围太窄时退回并排摆放：以随机的高度为准，左右对称。
    final y = area.top + random.nextDouble() * area.height;
    final cx = area.center.dx;
    return [layout.toNorm(Offset(cx - minDistance / 2, y)), layout.toNorm(Offset(cx + minDistance / 2, y))];
  }

  /// 第 [index] 枚骰子在 [progress]（0..1）时的渲染状态。
  DiceVisual visualAt(int index, double progress, DiceStageLayout layout) {
    final die = dice[index];
    final end = layout.toPx(die.end);
    if (reduceMotion) {
      return DiceVisual(center: end, floor: end, rotation: die.finalRotation, opacity: progress.clamp(0.0, 1.0));
    }
    final m = DiceMotion.move(progress);
    final start = layout.toPx(die.start);
    final via = layout.toPx(die.waypoint);
    // 二次贝塞尔：起点 → 途经点 → 落点。
    final u = 1 - m;
    final floor = start * (u * u) + via * (2 * u * m) + end * (m * m);
    final lift = DiceMotion.lift(progress);
    final spin = 1 - m;
    return DiceVisual(
      center: floor - Offset(0, lift * die.toss * layout.screenHeight),
      floor: floor,
      rotation: Rot3.axisAngle(die.axisA, die.angleA * spin) * Rot3.axisAngle(die.axisB, die.angleB * spin) * die.finalRotation,
      lift: lift,
      scale: DiceMotion.chargeScale(progress),
    );
  }

  /// 静止状态（待机、落定后）的渲染状态。
  static DiceVisual restVisual(Offset norm, Rot3 rotation, DiceStageLayout layout) {
    final center = layout.toPx(norm);
    return DiceVisual(center: center, floor: center, rotation: rotation);
  }
}
