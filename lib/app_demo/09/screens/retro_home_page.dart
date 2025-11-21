import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../example/celebrate/celebrate.dart';
import '../models/user_model.dart';
import '../widgets/control_pad.dart';
import '../widgets/header_controls.dart';
import '../widgets/list_section.dart';
import '../widgets/retro_dashboard.dart';
import '../widgets/top_banner.dart';

class RetroHomePage extends StatefulWidget {
  const RetroHomePage({super.key});

  @override
  State<RetroHomePage> createState() => _RetroHomePageState();
}

class _RetroHomePageState extends State<RetroHomePage> {
  // Tab 状态
  int _selectedTabIndex = 0;

  // 长按状态（用于控制粒子生成）
  bool _isLongPressing = false;

  // TopBanner 的 GlobalKey（用于获取位置）
  final GlobalKey _topBannerKey = GlobalKey();

  // 每个 Tab 对应的用户数据
  final Map<int, List<User>> _tabUsers = {
    0: [
      // Public
      const User(
        name: 'CoolGamer123',
        iconPath: 'assets/images/data/a.png',
        friends: [
          'assets/images/rule/barbarian.png',
          'assets/images/rule/ninja.png',
        ],
      ),
      const User(
        name: 'ProPlayer456',
        iconPath: 'assets/images/data/b.png',
        friends: [],
      ),
      const User(
        name: 'MasterChief',
        iconPath: 'assets/images/data/c.png',
        friends: [],
      ),
    ],
    1: [
      // Duo
      const User(name: 'TeamMate1', iconPath: 'assets/images/data/d.png'),
      const User(
        name: 'PartnerX',
        iconPath: 'assets/images/data/e.png',
        friends: [
          'assets/images/rule/magician.png',
          'assets/images/rule/swordsman.png',
        ],
      ),
    ],
    2: [
      // Private
      const User(name: 'BestFriend', iconPath: 'assets/images/data/a.png'),
      const User(name: 'CloseAlly', iconPath: 'assets/images/data/b.png'),
      const User(name: 'TrustedOne', iconPath: 'assets/images/data/c.png'),
      const User(name: 'SecretAgent', iconPath: 'assets/images/data/f.png'),
    ],
  };

  // 播放状态
  bool _isPlaying = false;

  // 播放速度
  double _playbackSpeed = 1.0;
  static const double minSpeed = 0.33;
  static const double maxSpeed = 3.0;
  static const double speedStep = 0.5;

  // 音频播放
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 波形数据
  Waveform? _waveform;

  // 播放进度
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      // 1. 设置音频播放器
      await _audioPlayer.setAsset('assets/audio/gaobai.mp3');

      // 等待音频加载完成
      await _audioPlayer.durationStream.firstWhere(
        (duration) => duration != null,
      );
      _totalDuration = _audioPlayer.duration ?? Duration.zero;

      // 2. 监听播放进度
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentPosition = position;
        });
      });

      // 3. 默认暂停状态（不自动播放）
      setState(() {
        _isPlaying = false;
      });

      // 4. 尝试提取波形数据（在后台异步进行）
      _extractWaveform();
    } catch (e) {
      debugPrint('Failed to initialize audio: $e');
    }
  }

  Future<void> _extractWaveform() async {
    try {
      debugPrint('Loading waveform from assets...');

      // 1. 从 assets 加载 WAV 文件（gaobai.wave 是标准 WAV 音频格式）
      final waveData = await rootBundle.load('assets/audio/gaobai.wave');

      // 2. 写入临时文件
      final tempDir = await getTemporaryDirectory();
      final audioFile = File(p.join(tempDir.path, 'gaobai.wave'));

      await audioFile.writeAsBytes(waveData.buffer.asUint8List());

      // 3. 从 WAV 文件提取波形数据
      final waveOutFile = File(p.join(tempDir.path, 'gaobai_waveform.wave'));

      final progressStream = JustWaveform.extract(
        audioInFile: audioFile,
        waveOutFile: waveOutFile,
        zoom: const WaveformZoom.pixelsPerSecond(100),
      );

      await for (final progress in progressStream) {
        debugPrint(
          'Waveform extraction progress: ${(progress.progress * 100).toInt()}%',
        );

        if (progress.waveform != null) {
          setState(() {
            _waveform = progress.waveform;
          });
          debugPrint('Waveform extraction completed!');
          break;
        }
      }
    } catch (e) {
      debugPrint('Failed to load waveform: $e');
    }
  }

  void _handlePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _audioPlayer.play();
      debugPrint('▶️ Playing at ${_playbackSpeed.toStringAsFixed(1)}x');
    } else {
      _audioPlayer.pause();
      debugPrint('⏸️ Paused');
    }
  }

  void _handleSpeedUp() {
    setState(() {
      _playbackSpeed = (_playbackSpeed + speedStep).clamp(1.0, maxSpeed);
    });

    _audioPlayer.setSpeed(_playbackSpeed);

    if (!_isPlaying) {
      setState(() {
        _isPlaying = true;
      });
      _audioPlayer.play();
    }

    debugPrint('⏩ Speed up to: ${_playbackSpeed.toStringAsFixed(1)}x');
  }

  void _handleSpeedDown() {
    setState(() {
      _playbackSpeed = (_playbackSpeed - speedStep).clamp(minSpeed, 1.0);
    });

    _audioPlayer.setSpeed(_playbackSpeed);

    if (!_isPlaying) {
      setState(() {
        _isPlaying = true;
      });
      _audioPlayer.play();
    }

    debugPrint('⏪ Speed down to: ${_playbackSpeed.toStringAsFixed(1)}x');
  }

  void _handleForward() {
    // 向前跳转 10 秒
    var newPosition = _currentPosition + const Duration(seconds: 10);
    if (newPosition > _totalDuration) newPosition = _totalDuration;
    _audioPlayer.seek(newPosition);
    debugPrint('⏭️ Forward 10s');
  }

  void _handleBackward() {
    // 向后跳转 10 秒
    var newPosition = _currentPosition - const Duration(seconds: 10);
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    _audioPlayer.seek(newPosition);
    debugPrint('⏮️ Backward 10s');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 获取 TopBanner 中心位置（用于粒子起点）
  Offset _getTopBannerCenter() {
    final RenderBox? topBannerBox =
        _topBannerKey.currentContext?.findRenderObject() as RenderBox?;

    // 2. 获取 SafeArea（当前 context）的 RenderBox
    final RenderBox? safeAreaBox = context.findRenderObject() as RenderBox?;

    if (topBannerBox == null || safeAreaBox == null) {
      return Offset.zero;
    }

    // 3. 获取 TopBanner 的全局位置和尺寸
    final Offset topBannerGlobalPosition = topBannerBox.localToGlobal(
      Offset.zero,
    );
    final Size topBannerSize = topBannerBox.size;

    // 4. 将全局坐标转换为 SafeArea 内的局部坐标
    final Offset topBannerLocalPosition = safeAreaBox.globalToLocal(
      topBannerGlobalPosition,
    );

    // 调试输出
    debugPrint('=== TopBanner Position Debug ===');
    debugPrint('TopBanner Global: $topBannerGlobalPosition');
    debugPrint('TopBanner Local: $topBannerLocalPosition');
    debugPrint('TopBanner Size: $topBannerSize');

    // 5. 计算 TopBanner 的中心点（局部坐标）
    final center = Offset(
      topBannerLocalPosition.dx + topBannerSize.width / 2,
      topBannerLocalPosition.dy + topBannerSize.height / 2,
    );

    debugPrint('Particle Origin: $center');
    debugPrint('================================');

    return center;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ========== 主内容区 ==========
            Column(
              children: [
                const SizedBox(height: 8),
                // 1. Top Banner
                TopBanner(
                  key: _topBannerKey,
                  onLongPressChanged: (isLongPressing) {
                    setState(() {
                      _isLongPressing = isLongPressing;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // 2. Header Controls (Segment + Icons)
                HeaderControls(
                  selectedIndex: _selectedTabIndex,
                  onTabChanged: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // 3. Dashboard (The Black Box)
                RetroDashboard(
                  waveform: _waveform,
                  currentPosition: _currentPosition,
                  totalDuration: _totalDuration,
                ),
                const SizedBox(height: 10),

                // 4. Control Pad
                ControlPad(
                  isPlaying: _isPlaying,
                  onSpeedDown: _handleSpeedDown,
                  onBackward: _handleBackward,
                  onPlayPause: _handlePlayPause,
                  onForward: _handleForward,
                  onSpeedUp: _handleSpeedUp,
                ),
                const SizedBox(height: 16),

                // 5. List Section
                Expanded(
                  child: ListSection(
                    key: ValueKey(_selectedTabIndex),
                    users: _tabUsers[_selectedTabIndex] ?? [],
                  ),
                ),
              ],
            ),

            // ========== 粒子覆盖层（最顶层）==========
            Positioned(
              top: -50,
              child: IgnorePointer(
                child: CustomPaint(
                  // painter: _DebugOriginPainter(origin: _getTopBannerCenter()),
                  child: CoolMode(
                    particleCount: 40,
                    triggerParticles: _isLongPressing,
                    enableInternalGesture: false,
                    particleOrigin: _getTopBannerCenter(),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 调试用的 Painter - 在粒子起点绘制红色十字标记
class _DebugOriginPainter extends CustomPainter {
  final Offset origin;
  const _DebugOriginPainter({required this.origin});

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制红色圆点
    canvas.drawCircle(
      origin,
      8,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    );

    // 绘制十字线
    final linePaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2;

    // 水平线
    canvas.drawLine(
      Offset(origin.dx - 30, origin.dy),
      Offset(origin.dx + 30, origin.dy),
      linePaint,
    );

    // 垂直线
    canvas.drawLine(
      Offset(origin.dx, origin.dy - 30),
      Offset(origin.dx, origin.dy + 30),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
