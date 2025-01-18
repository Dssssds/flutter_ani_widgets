import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/card_scroll/card_scroll_demo.dart';

// 自定义ScrollBehavior
class CustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}

class CardHorizontalScroll extends StatefulWidget {
  final List<CardData> cards;
  final Function()? onAddPressed;
  final double viewportHeight;
  final bool showDate;

  const CardHorizontalScroll({
    super.key,
    required this.cards,
    this.onAddPressed,
    required this.viewportHeight,
    required this.showDate,
  });

  @override
  State<CardHorizontalScroll> createState() => _CardHorizontalScrollState();
}

class _CardHorizontalScrollState extends State<CardHorizontalScroll>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0.0;
  int? selectedCardIndex;
  AnimationController? animationController;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    animation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: SizedBox(
        height: widget.viewportHeight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: SizedBox(
            width: MediaQuery.of(context).size.width +
                (widget.cards.length - 1) * 50.0,
            height: widget.viewportHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: widget.cards.asMap().entries.map((entry) {
                final index = widget.cards.length - 1 - entry.key; // 反序索引
                final card = entry.value;

                _scrollController.addListener(() {
                  setState(() {
                    scrollOffset = _scrollController.offset;
                  });
                });

                // 调整卡片的变换参数
                final double horizontalOffset = index * 60.0 - 250; // 水平间距
                // 缩放
                final scale =
                    min(1.0, 1.0 - index * 0.0495 + scrollOffset / 1000);
                // 旋转
                final angle = min(-10 / 180,
                    -10 / 180 - index * 0.0595 + scrollOffset / 1000);

                return Positioned(
                  top: widget.viewportHeight * 0.04,
                  left: horizontalOffset,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() {
                      selectedCardIndex = index;
                      animationController?.forward();
                    }),
                    onTapUp: (_) {
                      setState(() {
                        animationController?.reverse().then((value) {
                          selectedCardIndex = null;
                        });
                      });
                      if (card.type == 'add') {
                        widget.onAddPressed?.call();
                      }
                    },
                    onTapCancel: () => setState(() {
                      animationController?.reverse().then((value) {
                        selectedCardIndex = null;
                      });
                    }),
                    child: AnimatedBuilder(
                      animation: animation!,
                      builder: (context, child) {
                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(
                                3, 2, 0.105) // Matrix4的维度是4x4,索引从0开始,所以最大索引是3
                            ..scale(scale)
                            ..translate(
                              selectedCardIndex == index
                                  ? animation!.value * 10
                                  : 0.0,
                              selectedCardIndex == index
                                  ? -animation!.value * 10
                                  : 0.0,
                            ),
                          alignment: Alignment.center, // 修改为中心对齐
                          child: Transform.rotate(
                            angle: angle, // 逆时针旋转10度
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: widget.viewportHeight * 0.9,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 2, sigmaY: 5),
                                  child: Card(
                                    color: selectedCardIndex == index
                                        ? HSLColor.fromColor(Color.lerp(
                                            const Color(0xFF4A3F35), // 棕色
                                            const Color(0xFF1A1A1A), // 深灰色
                                            index / widget.cards.length,
                                          )!)
                                            .withLightness(0.6)
                                            .toColor() // 增加亮度来实现高亮效果
                                        : Color.lerp(
                                            const Color(0xFF4A3F35), // 棕色
                                            const Color(0xFF1A1A1A), // 深灰色
                                            index / widget.cards.length,
                                          )?.withOpacity(0.95),
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      child: card.type == 'add'
                                          ? Container(
                                              alignment: Alignment.centerRight,
                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  card.title
                                                      .split('')
                                                      .join('\n'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                if (widget.showDate)
                                                  Text(
                                                    card.date
                                                        .split('')
                                                        .join('\n'),
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                              ],
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
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    animationController?.dispose();
    super.dispose();
  }
}
