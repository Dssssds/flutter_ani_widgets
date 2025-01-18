import 'dart:math' as math;

import 'package:flutter/material.dart';

class Particle {
  Particle({
    required this.position,
    required this.size,
    required this.direction,
    required this.speedHorz,
    required this.speedUp,
    required this.spinSpeed,
    required this.spinVal,
    required this.color,
  });

  Offset position;
  double size;
  double direction;
  double speedHorz;
  double speedUp;
  double spinSpeed;
  double spinVal;
  Color color;

  void update() {
    position = Offset(
      position.dx - speedHorz * direction,
      position.dy - speedUp,
    );
    speedUp = math.min(size, speedUp - 1);
    spinVal += spinSpeed;
  }
}

class CoolMode extends StatefulWidget {
  const CoolMode({
    super.key,
    required this.child,
    this.particleCount = 45,
    this.speedHorz,
    this.speedUp,
    this.particleImage,
  });

  final Widget child;
  final int particleCount;
  final double? speedHorz;
  final double? speedUp;
  final String? particleImage;

  @override
  State<CoolMode> createState() => _CoolModeState();
}

class _CoolModeState extends State<CoolMode> with TickerProviderStateMixin {
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  bool _isPointerDown = false;
  late AnimationController _animationController;
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animationController.addListener(_updateParticles);
  }

  Offset _getWidgetPosition() {
    final RenderBox? renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? paintBox = context.findRenderObject() as RenderBox?;

    if (renderBox == null || paintBox == null) return Offset.zero;

    // Get the global position of the button
    final Offset globalPosition = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Convert global coordinates back to local coordinates relative to the CustomPaint
    final Offset localPosition = paintBox.globalToLocal(globalPosition);

    return Offset(
      localPosition.dx + size.width / 2,
      localPosition.dy + size.width / 4, // Start from top of the button
    );
  }

  void _updateParticles() {
    if (_isPointerDown && _particles.length < widget.particleCount) {
      _addParticle();
    }

    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update();

      // Remove particles that go off screen
      if (_particles[i].position.dy < -_particles[i].size ||
          _particles[i].position.dy >
              MediaQuery.of(context).size.height + _particles[i].size) {
        _particles.removeAt(i);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _addParticle() {
    // 定义一个粒子大小的列表,包含5个不同的大小值
    final List<double> sizes = [15, 18, 21, 23, 26];
    // 从sizes列表中随机选择一个大小值
    final size = sizes[_random.nextInt(sizes.length)].toDouble();
    // 设置水平速度,如果widget.speedHorz为空则随机生成一个0-10之间的值
    final speedHorz = widget.speedHorz ?? _random.nextDouble() * 10;
    // 设置向上的速度,如果widget.speedUp为空则随机生成一个0-25之间的值
    final speedUp = widget.speedUp ?? _random.nextDouble() * 25;
    // 随机生成一个0-360度之间的旋转角度
    final spinVal = _random.nextDouble() * 360;
    // 随机生成一个旋转速度,范围是-35到35之间
    final spinSpeed = _random.nextDouble() * 35 * (_random.nextBool() ? -1 : 1);
    // 随机决定粒子的方向,向左(-1)或向右(1)
    final direction = _random.nextBool() ? -1 : 1;

    // 获取widget的位置作为粒子的起始位置
    final widgetPosition = _getWidgetPosition();

    // 向粒子列表中添加一个新的粒子
    _particles.add(
      Particle(
        position: widgetPosition,
        size: size,
        direction: direction.toDouble(),
        speedHorz: speedHorz,
        speedUp: speedUp,
        spinSpeed: spinSpeed,
        spinVal: spinVal,
        // 使用HSL颜色空间创建一个随机颜色
        color: HSLColor.fromAHSL(
          1.0,
          _random.nextDouble() * 360, // 随机色相
          0.7, // 固定饱和度
          0.6, // 固定亮度
        ).toColor(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // First layer: The button
          Center(
              child: GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isPointerDown = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isPointerDown = false;
              });
            },
            onTapCancel: () {
              setState(() {
                _isPointerDown = false;
              });
            },
            child: KeyedSubtree(
              key: _childKey,
              child: widget.child,
            ),
          )),
          // Second layer: The particles (now on top)
          if (_particles.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter({
    required this.particles,
  });

  final List<Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      canvas.save();

      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.spinVal * math.pi / 180);

      final paint = Paint()..color = particle.color;
      canvas.drawCircle(
        Offset.zero,
        particle.size / 2,
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
