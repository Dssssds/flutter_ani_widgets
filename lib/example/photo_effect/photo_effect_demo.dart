import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'photo_open.dart';

class PhotoEffectDemo extends StatefulWidget {
  const PhotoEffectDemo({super.key});

  @override
  State<PhotoEffectDemo> createState() => _PhotoEffectDemoState();
}

class _PhotoEffectDemoState extends State<PhotoEffectDemo>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  bool _isGridView = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isPreviewMode = false;
  int? _previewIndex;
  AnimationController? _previewAnimationController;
  Animation<double>? _previewAnimation;

  final List<Map<String, String>> _imageUrls = [
    {
      'url':
          'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-01.jpg',
      'subUrl':
          'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-01-01.jpg',
    },
    {
      'url':
          'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-02.jpg',
      'subUrl':
          'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-02-01.jpg',
    },
    {
      'url':
          'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-03.jpg',
      'subUrl':
          'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-03-01.jpg',
    },
    {
      'url':
          'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-04.jpg',
      'subUrl':
          'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/image/pic-04-01.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _previewAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _previewAnimation = CurvedAnimation(
      parent: _previewAnimationController!,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    _previewAnimationController?.dispose();
    super.dispose();
  }

  void _showPreview(int index) {
    setState(() {
      _previewIndex = index;
      _isPreviewMode = true;
    });
    _previewAnimationController?.forward();
  }

  void _hidePreview() {
    _previewAnimationController?.reverse().then((_) {
      setState(() {
        _isPreviewMode = false;
        _previewIndex = null;
      });
    });
  }

  double _getRandomRotation(int index) {
    final random = math.Random(index);
    return (random.nextDouble() * 50.0 - 25.0) * math.pi / 180.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) {
                      _pageController.jumpToPage(index);
                    },
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        return Colors.transparent;
                      },
                    ),
                    tabs: const [
                      Tab(text: 'cards'),
                      Tab(text: 'letters'),
                    ],
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[700],
                    indicatorColor: Colors.white60,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 2,
                    labelPadding: EdgeInsets.zero,
                    labelStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      _tabController.animateTo(index);
                    },
                    children: [
                      _buildCardsView(),
                      _buildLettersView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isPreviewMode &&
              _previewIndex != null &&
              _previewAnimation != null)
            AnimatedBuilder(
              animation: _previewAnimation!,
              builder: (context, child) {
                final scale = 1.0 + _previewAnimation!.value;

                return GestureDetector(
                  onTap: _hidePreview,
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.5 * _previewAnimation!.value),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10 * _previewAnimation!.value,
                        sigmaY: 10 * _previewAnimation!.value,
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'preview_$_previewIndex',
                          child: Transform.scale(
                            scale: scale,
                            child: AnimationPhoto(
                              width: 70.0,
                              height: 100.0,
                              coverChild: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Image.network(
                                    _imageUrls[_previewIndex!]['url']!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              pageChild: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: SizedBox(
                                    width: 180,
                                    height: 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: Image.network(
                                          _imageUrls[_previewIndex!]['subUrl']!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCardsView() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Stack(
                      children: List.generate(_imageUrls.length, (index) {
                        const width = 180.0;
                        const height = 240.0;
                        final baseX =
                            MediaQuery.of(context).size.width / 2.550 -
                                width / 2.550;
                        final baseY = MediaQuery.of(context).size.height * 0.18;
                        final rotation = _getRandomRotation(index);

                        final row = index ~/ 2;
                        final col = index % 2;
                        final targetX = col * (width + 1) -
                            (MediaQuery.of(context).size.width - 50) / 4;
                        final targetY = row * (height + 1) - height / 2;

                        final currentX = _animation.value * targetX;
                        final currentY =
                            _animation.value * (targetY - index * 2.0);
                        final scale = 0.7 + (0.3 * (1 - _animation.value));
                        final currentRotation =
                            rotation * (1 - _animation.value);

                        return Positioned(
                          left: baseX + currentX,
                          top: baseY + (index * 2.0) + currentY,
                          child: Transform.scale(
                            scale: _isGridView ? scale : 1.0,
                            child: Transform.rotate(
                              angle: currentRotation,
                              child: _buildCard(
                                imageUrl: _imageUrls[index]['url']!,
                                width: width,
                                height: height,
                                index: index,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (!_isGridView) {
                      _isGridView = true;
                      _animationController.forward();
                    } else {
                      _animationController.reverse().then((_) {
                        setState(() {
                          _isGridView = false;
                        });
                      });
                    }
                  });
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _isGridView ? '返回堆叠' : '展开网格',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLettersView() {
    return const Center(
      child: Text(
        '啥也没有, 下个案例见',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCard({
    required String imageUrl,
    required double width,
    required double height,
    int? index,
  }) {
    return GestureDetector(
      onTap: () {
        if (index != null) {
          _showPreview(index);
        }
      },
      child: Hero(
        tag: 'preview_${index ?? ""}',
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: Colors.white,
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
