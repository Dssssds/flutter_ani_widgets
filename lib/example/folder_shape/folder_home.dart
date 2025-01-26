import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/folder_shape/gradient_shadow.dart';

/// 文件夹动画相关的常量配置
class FolderAnimationConfig {
  /// 主动画时长
  static const Duration mainAnimationDuration = Duration(milliseconds: 800);

  /// 阴影动画时长
  static const Duration shadowAnimationDuration = Duration(milliseconds: 600);

  /// 阴影动画延迟
  static const Duration shadowAnimationDelay = Duration(milliseconds: 300);

  /// 文件夹尺寸
  static const double folderWidth = 150;
  static const double folderBackHeight = 120;
  static const double folderFrontHeight = 100;

  /// 文件夹位置
  static const double folderBottomPadding = 40;

  /// 3D 变换参数
  static const double perspective = 0.003;
  static const double rotationFactor = 1.3;
}

class FolderHomeWidget extends StatefulWidget {
  final String title;
  final Curve curve;

  const FolderHomeWidget({super.key, required this.title, required this.curve});

  @override
  State<FolderHomeWidget> createState() => _FolderHomeWidgetState();
}

class _FolderHomeWidgetState extends State<FolderHomeWidget>
    with TickerProviderStateMixin {
  late final AnimationController _mainAnimationController;
  late final Animation<double> _mainAnimation;
  late final AnimationController _shadowAnimationController;
  late final Animation<double> _shadowAnimation;

  bool _isOpen = false;
  bool _isInitialized = false;

  void _initializeAnimations() {
    if (_isInitialized) return;

    _mainAnimationController = AnimationController(
      vsync: this,
      duration: FolderAnimationConfig.mainAnimationDuration,
    );

    _shadowAnimationController = AnimationController(
      vsync: this,
      duration: FolderAnimationConfig.shadowAnimationDuration,
    );

    _mainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: widget.curve),
    );

    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shadowAnimationController, curve: widget.curve),
    );

    _isInitialized = true;
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeAnimations();
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _mainAnimationController.stop();
      _shadowAnimationController.stop();
      _mainAnimationController.dispose();
      _shadowAnimationController.dispose();
    }
    super.dispose();
  }

  void _handleFolderTap() {
    if (!mounted || !_isInitialized) return;

    try {
      if (_isOpen) {
        _mainAnimationController.reverse().orCancel.catchError((error) {
          if (error is TickerCanceled) return;
          throw error;
        });
        _shadowAnimationController.reverse().orCancel.catchError((error) {
          if (error is TickerCanceled) return;
          throw error;
        });
      } else {
        _mainAnimationController.forward().orCancel.catchError((error) {
          if (error is TickerCanceled) return;
          throw error;
        });
        Future.delayed(FolderAnimationConfig.shadowAnimationDelay, () {
          if (!mounted || !_isInitialized) return;
          _shadowAnimationController.forward().orCancel.catchError((error) {
            if (error is TickerCanceled) return;
            throw error;
          });
        });
      }
      setState(() {
        _isOpen = !_isOpen;
      });
    } catch (e) {
      debugPrint('Animation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.title,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _mainAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _handleFolderTap,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        bottom: FolderAnimationConfig.folderBottomPadding,
                        child: Image.asset(
                          'assets/images/folder_backcover.png',
                          width: FolderAnimationConfig.folderWidth,
                          height: FolderAnimationConfig.folderBackHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: FolderAnimationConfig.folderBottomPadding,
                        child: CustomPaint(
                          size: Size(
                            FolderAnimationConfig.folderWidth,
                            FolderAnimationConfig.folderBackHeight,
                          ),
                          painter:
                              FolderBackCoverGradientPainter(_shadowAnimation),
                        ),
                      ),
                      Positioned(
                        bottom: FolderAnimationConfig.folderBottomPadding,
                        child: _buildFolderFrontCover(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderFrontCover() {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, FolderAnimationConfig.perspective)
        ..rotateX(FolderAnimationConfig.rotationFactor * _mainAnimation.value),
      alignment: FractionalOffset.bottomCenter,
      child: SizedBox(
        width: FolderAnimationConfig.folderWidth,
        height: FolderAnimationConfig.folderFrontHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.asset(
              'assets/images/folder_frontcover.png',
              width: FolderAnimationConfig.folderWidth,
              height: FolderAnimationConfig.folderFrontHeight,
              fit: BoxFit.cover,
            ),
            ClipPath(
              clipper: LightningClipper(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ReflectionWidget(_mainAnimation, _shadowAnimation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
