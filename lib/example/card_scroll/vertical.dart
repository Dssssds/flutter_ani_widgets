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

class CardVerticalScroll extends StatefulWidget {
  final List<CardData> cards;
  final Function()? onAddPressed;
  final double viewportHeight;
  final bool showDate;

  const CardVerticalScroll({
    super.key,
    required this.cards,
    this.onAddPressed,
    required this.viewportHeight,
    required this.showDate,
  });

  @override
  State<CardVerticalScroll> createState() => _CardVerticalScrollState();
}

class _CardVerticalScrollState extends State<CardVerticalScroll>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double scrollOffset = 0.0;
  int? selectedCardIndex;
  AnimationController? animationController;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    _scrollController.addListener(() {
      setState(() {
        scrollOffset = _scrollController.offset;
      });
    });

    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    animation = Tween<double>(begin: 0.0, end: -30).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardHeight = size.height * 0.3;
    final cardOffset = cardHeight * 0.25;
    final cardOverlap = cardHeight - cardOffset - 5;

    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: SizedBox(
        height: widget.viewportHeight,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            height: cardHeight * widget.cards.length -
                (cardOverlap * widget.cards.length) +
                cardOverlap,
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(widget.cards.length, (index) {
                final progress =
                    (scrollOffset - (index * cardHeight * 0.25)) / 180;
                final horizontalOffset =
                    sin(progress * 0.9) * size.width * 0.35;
                final twistAngle = sin(progress * 1.2) * pi / 30;

                return Positioned(
                  top: index * cardOffset,
                  left: 155,
                  right: 0,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        selectedCardIndex = index;
                        animationController!.forward();
                      });
                    },
                    onLongPressEnd: (details) {
                      setState(() {
                        animationController!.reverse().then((value) {
                          selectedCardIndex = null;
                        });
                      });
                    },
                    onTap: widget.cards[index].type == 'add'
                        ? widget.onAddPressed
                        : null,
                    child: AnimatedBuilder(
                      animation: animation!,
                      builder: (context, child) {
                        final scaleFactor =
                            1 - (progress * 0.2).clamp(-0.2, 0.2);

                        return Transform(
                          transform: Matrix4.identity()
                            ..translate(
                              selectedCardIndex == index
                                  ? horizontalOffset + animation!.value * 0.1
                                  : horizontalOffset,
                              selectedCardIndex == index
                                  ? animation!.value
                                  : 0.0,
                              0.0,
                            )
                            ..rotateZ(twistAngle)
                            ..scale(scaleFactor),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 5),
                              child: Card(
                                color: selectedCardIndex == index
                                    ? HSLColor.fromColor(Color.lerp(
                                        const Color.fromARGB(
                                            255, 188, 188, 188),
                                        const Color.fromARGB(
                                            255, 196, 172, 115),
                                        index / widget.cards.length,
                                      )!)
                                        .withLightness(0.7)
                                        .toColor() // 增加亮度来实现高亮效果
                                    : Color.lerp(
                                        const Color.fromARGB(
                                            255, 188, 188, 188),
                                        const Color.fromARGB(
                                            255, 196, 172, 115),
                                        index / widget.cards.length,
                                      )?.withOpacity(0.8),
                                elevation: 1,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Container(
                                  height: 300,
                                  padding: const EdgeInsets.all(15),
                                  child: widget.cards[index].type == 'add'
                                      ? const Center(
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: widget.showDate
                                                  ? MainAxisAlignment
                                                      .spaceBetween
                                                  : MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  widget.cards[index].title,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                if (widget.showDate)
                                                  Text(
                                                    widget.cards[index].date,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
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
              }),
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
