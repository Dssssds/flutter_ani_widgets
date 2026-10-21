import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const _meteorLavender = Color(0xFFD9C3F3);
const _meteorCream = Color(0xFFFFF1CF);

/// All tweakables live here so the look of the meteor shower can be reshaped
/// from a single place.
///
/// The shower travels along a single axis: every streak enters through the
/// **top-right corner** and leaves through the **bottom-left corner**.
/// [axisAngleDeg] is that axis (135° in Flutter's y-down space, i.e.
/// `cos < 0 && sin > 0`), [fanSpreadDeg] opens the streaks into a shallow
/// fan around it, and [travelDistance] controls how far past the corner a
/// streak runs before it expires.
class MeteorConfig {
  const MeteorConfig({
    this.flightSeconds = 3.2,
    this.speedJitter = .2,
    this.minConcurrent = 2,
    this.maxConcurrent = 3,
    this.spawnRange = const Duration(milliseconds: 900),
    this.spawnJitter = const Duration(milliseconds: 700),
    this.appearFraction = .3,
    this.vanishFraction = .2,
    this.minBrightness = .3,
    this.maxBrightness = 1.0,
    this.farScale = .3,
    this.trailBase = .18,
    this.trailVanishFloor = .55,
    this.axisAngleDeg = 135,
    this.fanSpreadDeg = 7,
    this.angleJitterDeg = 2,
    this.travelDistance = 1.7,
    this.entryScatter = .07,
  });

  /// Lifetime of a single streak, in seconds.
  final double flightSeconds;

  /// Per-streak speed variation, ± this fraction of [flightSeconds].
  final double speedJitter;

  /// Lower bound on streaks kept alive at any moment.
  final int minConcurrent;

  /// Upper bound on streaks kept alive at any moment.
  final int maxConcurrent;

  /// Quiet time between two streaks once the shower is saturated.
  final Duration spawnRange;

  /// Random extra quiet time on top of [spawnRange].
  final Duration spawnJitter;

  /// Fraction of the lifetime spent fading in.
  final double appearFraction;

  /// Fraction of the lifetime spent fading out.
  final double vanishFraction;

  /// Per-streak opacity multiplier, lower bound.
  final double minBrightness;

  /// Per-streak opacity multiplier, upper bound.
  final double maxBrightness;

  /// Scale applied while the streak is still far away.
  final double farScale;

  /// Trail length as a fraction of the header diagonal.
  final double trailBase;

  /// Trail length floor, as a fraction of [trailBase], during the fade-out.
  final double trailVanishFloor;

  /// Direction of the main axis. 135° travels from the top-right corner to
  /// the bottom-left corner.
  final double axisAngleDeg;

  /// Half-width of the fan around [axisAngleDeg], in degrees.
  final double fanSpreadDeg;

  /// Extra random angle noise, in degrees, applied on top of the fan.
  final double angleJitterDeg;

  /// Normalized distance a streak travels before expiring. Must be large
  /// enough to carry the head past the bottom-left corner.
  final double travelDistance;

  /// Random spread of the entry point around the top-right corner.
  final double entryScatter;
}

/// A decorative, bounded header background. Route visibility and app-specific
/// reduced motion are supplied by the parent through [enabled].
class MenuMeteorBackground extends StatefulWidget {
  const MenuMeteorBackground({super.key, this.enabled = true, this.config = const MeteorConfig()});

  final bool enabled;
  final MeteorConfig config;

  @override
  State<MenuMeteorBackground> createState() => _MenuMeteorBackgroundState();
}

class _MenuMeteorBackgroundState extends State<MenuMeteorBackground> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  late final MeteorField _field;
  final _repaint = ValueNotifier<int>(0);

  /// Monotonic clock used for spawn scheduling. Kept separately from the
  /// ticker elapsed time so it survives ticker restarts.
  Duration _clock = Duration.zero;
  Duration _lastTickerElapsed = Duration.zero;
  Duration _nextSpawn = Duration.zero;
  Duration _lastSpawn = Duration.zero;
  bool _hasSpawned = false;

  AppLifecycleState? _lifecycle;
  bool _disableAnimations = false;
  bool _tickerEnabled = false;
  bool _allowed = false;

  /// Minimum gap between two streaks born inside the same burst.
  static const _stagger = Duration(milliseconds: 180);

  @override
  void initState() {
    super.initState();
    _lifecycle = WidgetsBinding.instance.lifecycleState;
    _ticker = createTicker(_onTick);
    _field = MeteorField();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.disableAnimationsOf(context);
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
    _synchronize();
  }

  @override
  void didUpdateWidget(covariant MenuMeteorBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchronize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    _synchronize();
  }

  void _synchronize() {
    final allowed =
        widget.enabled && !_disableAnimations && _tickerEnabled && (_lifecycle ?? AppLifecycleState.resumed) == AppLifecycleState.resumed;
    if (allowed == _allowed) return;
    _allowed = allowed;
    if (allowed) {
      _startTicker();
    } else {
      // Freeze the shower completely: drop the streaks so nothing is left
      // hanging in mid-air while the background is disabled.
      _ticker.stop();
      _field.clear();
      _hasSpawned = false;
    }
  }

  void _startTicker() {
    if (_ticker.isActive) return;
    _lastTickerElapsed = Duration.zero;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final config = widget.config;

    var delta = elapsed - _lastTickerElapsed;
    if (delta < Duration.zero) delta = Duration.zero; // the ticker just restarted
    _lastTickerElapsed = elapsed;
    _clock += delta;

    _field.advance(delta, config);

    if (_shouldSpawn(config)) {
      _field.spawn(config);
      _hasSpawned = true;
      _lastSpawn = _clock;
      _nextSpawn = _clock + _field.randomSpawnDelay(config);
    }

    _repaint.value++; // notify CustomPaint to repaint
  }

  /// Decides whether a new streak should be born this frame.
  ///
  /// While the shower is below [MeteorConfig.minConcurrent] the flow is
  /// replenished immediately (staggered by [_stagger] so a burst does not
  /// land on a single frame). Once saturated, streaks are born on the
  /// configured cadence instead.
  bool _shouldSpawn(MeteorConfig config) {
    if (!_field.canSpawn(config)) return false;
    if (_field.count < config.minConcurrent) {
      return !_hasSpawned || _clock - _lastSpawn >= _stagger;
    }
    return _clock >= _nextSpawn;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: ClipRect(
          child: SizedBox.expand(
            child: CustomPaint(painter: MenuMeteorPainter(field: _field, config: widget.config, repaint: _repaint)),
          ),
        ),
      ),
    ),
  );
}

/// The mutable pool of [Meteor] streaks. The widget owns one instance and
/// ticks it on every frame; the painter reads the snapshot.
class MeteorField {
  MeteorField({math.Random? random}) : _rng = random ?? math.Random();

  final math.Random _rng;
  final List<Meteor> _streaks = [];

  Iterable<Meteor> get streaks => _streaks;
  int get count => _streaks.length;

  void advance(Duration delta, MeteorConfig config) {
    if (delta == Duration.zero) return;
    for (final meteor in _streaks) {
      meteor.advance(delta);
    }
    // Remove in place to avoid allocations on every frame.
    _streaks.removeWhere((m) => m.age >= 1);
  }

  /// Drops every streak, e.g. when the background gets disabled.
  void clear() => _streaks.clear();

  bool canSpawn(MeteorConfig config) => _streaks.length < config.maxConcurrent;

  Duration randomSpawnDelay(MeteorConfig config) =>
      config.spawnRange + Duration(microseconds: (_rng.nextDouble() * config.spawnJitter.inMicroseconds).round());

  /// Spawns one streak entering through the top-right corner and heading for
  /// the bottom-left one.
  void spawn(MeteorConfig config) {
    if (!canSpawn(config)) return;

    final brightness = config.minBrightness + _rng.nextDouble() * (config.maxBrightness - config.minBrightness);
    final speedScale = 1 + (_rng.nextDouble() * 2 - 1) * config.speedJitter;
    final lifeSeconds = (config.flightSeconds * speedScale).clamp(0.1, double.infinity);

    // The fan: a stable lane in [-1, 1] spreads the streaks around the main
    // axis, so they diverge while leaving the same corner.
    final lane = _rng.nextDouble() * 2 - 1;
    final angleDeg = config.axisAngleDeg + lane * config.fanSpreadDeg + (_rng.nextDouble() - .5) * config.angleJitterDeg;

    // The entry point hugs the top-right corner.
    final origin = Offset(1 - _rng.nextDouble() * config.entryScatter, _rng.nextDouble() * config.entryScatter);

    _streaks.add(
      Meteor(
        direction: angleFrom(angleDeg),
        brightness: brightness,
        lifeSeconds: lifeSeconds,
        origin: origin,
        travelDistance: config.travelDistance,
      ),
    );
  }

  /// Spawns exactly [count] streaks, capped by [MeteorConfig.maxConcurrent].
  void spawnBatch(MeteorConfig config, int count) {
    for (var i = 0; i < count && canSpawn(config); i++) {
      spawn(config);
    }
  }

  /// Spawns a random number of streaks between [MeteorConfig.minConcurrent]
  /// and [maxBatch].
  void spawnRandomBatch(MeteorConfig config, int maxBatch) {
    final low = config.minConcurrent.clamp(1, maxBatch);
    spawnBatch(config, low + _rng.nextInt(maxBatch - low + 1));
  }
}

/// One streak's runtime state plus its immutable recipe.
class Meteor {
  Meteor({
    required this.direction,
    required this.brightness,
    required this.lifeSeconds,
    required this.origin,
    required this.travelDistance,
  });

  /// Unit vector pointing along the travel direction. For the default axis it
  /// points left and down: `dx < 0 && dy > 0`.
  final Offset direction;

  /// Visual prominence multiplier in [minBrightness, maxBrightness].
  final double brightness;

  /// Total lifetime; age grows towards this in seconds.
  final double lifeSeconds;

  /// Normalized entry point, in the top-right corner region.
  final Offset origin;

  /// Normalized distance travelled over the whole lifetime.
  final double travelDistance;

  Duration _age = Duration.zero;

  double get age {
    final fraction = _age.inMicroseconds / (lifeSeconds * 1e6);
    return fraction.clamp(0.0, 1.0);
  }

  void advance(Duration delta) {
    _age += delta;
  }

  /// Position of the head at a given age, normalized to header space.
  ///
  /// The streak leaves [origin] and travels along [direction] for
  /// [travelDistance] normalized units, so it enters through the top-right
  /// corner and runs out past the bottom-left one.
  Offset headPosition(double ageValue) {
    final travel = _travelCurve(ageValue);
    final base = origin + direction * (travelDistance * travel);
    return Offset(base.dx.clamp(-.5, 1.5), base.dy.clamp(-.5, 1.5));
  }

  /// Mild acceleration: the streak leaves the corner gently and crosses the
  /// header with speed.
  static double _travelCurve(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    return math.pow(t, 1.25).toDouble();
  }
}

const _stars = <Offset>[
  Offset(.09, .18),
  Offset(.26, .43),
  Offset(.39, .12),
  Offset(.57, .31),
  Offset(.72, .13),
  Offset(.85, .57),
  Offset(.95, .28),
  Offset(.04, .54),
  Offset(.12, .76),
  Offset(.18, .09),
  Offset(.21, .61),
  Offset(.29, .85),
  Offset(.33, .24),
  Offset(.36, .67),
  Offset(.43, .48),
  Offset(.47, .91),
  Offset(.51, .07),
  Offset(.54, .71),
  Offset(.62, .18),
  Offset(.65, .53),
  Offset(.68, .85),
  Offset(.74, .39),
  Offset(.78, .69),
  Offset(.82, .06),
  Offset(.88, .34),
  Offset(.91, .81),
  Offset(.97, .65),
  Offset(.08, .93),
];

/// Unit vector for an angle in degrees, in Flutter's y-down space.
Offset angleFrom(double degrees) {
  final rad = degrees * math.pi / 180;
  return Offset(math.cos(rad), math.sin(rad));
}

class MenuMeteorPainter extends CustomPainter {
  MenuMeteorPainter({super.repaint, required MeteorField field, required MeteorConfig config})
    : _field = field,
      _config = config;

  final MeteorField _field;
  final MeteorConfig _config;

  /// The streak pool being painted, exposed for tests and debugging.
  MeteorField get field => _field;

  /// The configuration in use, exposed for tests and debugging.
  MeteorConfig get config => _config;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.width.isFinite || !size.height.isFinite) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final starPaint = Paint()..color = _meteorCream.withValues(alpha: .12);
    for (final star in _stars) {
      canvas.drawCircle(Offset(star.dx * size.width, star.dy * size.height), .8, starPaint);
    }
    for (final meteor in _field.streaks) {
      _paintMeteor(canvas, size, meteor);
    }
    canvas.restore();
  }

  void _paintMeteor(Canvas canvas, Size size, Meteor meteor) {
    final age = meteor.age;
    if (age <= 0 || age >= 1) return;

    final appearEnd = _config.appearFraction;
    final vanishStart = 1 - _config.vanishFraction;

    // Visibility: ease-in over [0..appearEnd], hold, ease-out over [vanishStart..1].
    final double visibility;
    if (age < appearEnd) {
      visibility = Curves.easeIn.transform(age / appearEnd);
    } else if (age > vanishStart) {
      visibility = Curves.easeOut.transform((1 - age) / _config.vanishFraction);
    } else {
      visibility = 1;
    }

    // Distance scaling: far when young, full-size when closest.
    final distanceT = age < appearEnd ? Curves.easeOut.transform(age / appearEnd) : 1.0;
    final scale = _config.farScale + (1 - _config.farScale) * distanceT;

    // Trail shortening during vanish phase, never below the floor.
    final double trailScale;
    if (age > vanishStart) {
      final shrink = Curves.easeOut.transform((1 - age) / _config.vanishFraction);
      trailScale = _config.trailBase * (_config.trailVanishFloor + (1 - _config.trailVanishFloor) * shrink);
    } else {
      trailScale = _config.trailBase;
    }

    final headOffset = meteor.headPosition(age);
    final head = Offset(headOffset.dx * size.width, headOffset.dy * size.height);
    // Tail extends opposite to the direction of travel, i.e. back towards the
    // top-right corner the streak came from.
    final tailAxis = -meteor.direction;
    final tail = head + Offset(tailAxis.dx * size.width * trailScale, tailAxis.dy * size.height * trailScale);

    final peakAlpha = .72 * meteor.brightness;
    final opacity = visibility * peakAlpha;
    if (opacity <= 0) return;

    final baseWidth = (.9 + .9 * meteor.brightness) * scale;
    final headRadius = (1 + meteor.brightness * 1.6) * scale;

    // Soft halo around the head so the streak reads as a hot point.
    canvas.drawCircle(head, headRadius * 3.2, Paint()..color = _meteorCream.withValues(alpha: opacity * .07));

    final paint =
        Paint()
          ..strokeWidth = baseWidth
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              _meteorLavender.withValues(alpha: 0),
              _meteorLavender.withValues(alpha: opacity * .55),
              _meteorCream.withValues(alpha: opacity),
            ],
            stops: const [0, .65, 1],
          ).createShader(Rect.fromPoints(tail, head));
    canvas.drawLine(tail, head, paint);
    canvas.drawCircle(head, headRadius, Paint()..color = _meteorCream.withValues(alpha: opacity * .6));
  }

  @override
  bool shouldRepaint(covariant MenuMeteorPainter oldDelegate) =>
      oldDelegate._config != _config || !identical(oldDelegate._field, _field);
}
