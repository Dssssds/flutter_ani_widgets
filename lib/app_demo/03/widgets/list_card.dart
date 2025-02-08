import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/03/models/shopping_list.dart';
import 'package:flutter_x_widgets/app_demo/03/widgets/product_image.dart';
import 'package:flutter_x_widgets/app_demo/03/widgets/shared_avatars.dart';
import 'package:intl/intl.dart';

class ListCard extends StatefulWidget {
  final ShoppingList list;
  final VoidCallback? onTap;
  final VoidCallback? onOpenClose;

  const ListCard({super.key, required this.list, this.onTap, this.onOpenClose});

  @override
  State<ListCard> createState() => ListCardState();
}

class ListCardState extends State<ListCard> {
  bool _isExpanded = false;
  final _random = Random();
  List<Offset> _randomPositions = [];

  // 检查新位置是否与已有位置重叠
  bool _isOverlapping(
      Offset newPosition, double itemSize, List<Offset> existingPositions) {
    const minDistance = 20.0; // 最小间距
    final totalSize = itemSize + minDistance;

    for (final existingPosition in existingPositions) {
      final distance = (newPosition - existingPosition).distance;
      if (distance < totalSize) {
        return true;
      }
    }
    return false;
  }

  // 生成一个不重叠的随机位置
  Offset _generateNonOverlappingPosition(
      Size containerSize, double itemSize, List<Offset> existingPositions) {
    int attempts = 0;
    const maxAttempts = 100; // 最大尝试次数

    while (attempts < maxAttempts) {
      final newPosition = Offset(
        _random.nextDouble() * (containerSize.width - itemSize),
        _random.nextDouble() * (containerSize.height - itemSize),
      );

      if (!_isOverlapping(newPosition, itemSize, existingPositions)) {
        return newPosition;
      }
      attempts++;
    }

    // 如果实在找不到不重叠的位置，就返回一个网格位置
    final gridColumns = (containerSize.width / (itemSize + 20)).floor();
    final index = existingPositions.length;
    final row = index ~/ gridColumns;
    final col = index % gridColumns;

    return Offset(
      col * (itemSize + 20),
      row * (itemSize + 20),
    );
  }

  void _generateRandomPositions(Size containerSize, double itemSize) {
    final positions = <Offset>[];

    for (int i = 0; i < widget.list.items.length; i++) {
      final position =
          _generateNonOverlappingPosition(containerSize, itemSize, positions);
      positions.add(position);
    }

    _randomPositions = positions;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onOpenClose?.call();
  }

  // 计算展开和收起时的卡片高度
  double _calculateCardHeight(BuildContext context) {
    const double baseHeight = 200.0; // 基础内容高度
    if (!_isExpanded) return baseHeight;

    final int itemCount = widget.list.items.length;
    final int rowCount = (itemCount / 3).ceil(); // 每行3个商品
    return baseHeight + (rowCount * 120.0 * 2); // 每行高度120 * 2
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutBack,
        height: _calculateCardHeight(context),
        child: Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.hardEdge,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: GestureDetector(
            onLongPress: () {
              _toggleExpanded();
            },
            child: Column(
              children: [
                // 基本信息区域
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_isExpanded) {
                      _toggleExpanded();
                    } else {
                      widget.onTap?.call();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('yyyy MMM d')
                                      .format(widget.list.createdDate),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ],
                            ),
                            if (widget.list.sharedWith != null)
                              SharedAvatars(userIds: widget.list.sharedWith!),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.list.title,
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.list.description,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 商品展示区域
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOut,
                    child: Center(
                      child: _isExpanded
                          ? ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200], // 浅灰色背景
                                    borderRadius: BorderRadius.circular(16),
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          'assets/images/dot_pattern.jpg'),
                                      repeat: ImageRepeat.repeat,
                                    ),
                                  ),
                                  child: InteractiveViewer(
                                    boundaryMargin: EdgeInsets.all(
                                        MediaQuery.of(context).size.width * 5),
                                    minScale: 0.5,
                                    maxScale: 2.5,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final itemSize =
                                            constraints.maxWidth / 3 - 16;

                                        // 在构建之前确保有随机位置
                                        if (_randomPositions.length !=
                                            widget.list.items.length) {
                                          _generateRandomPositions(
                                            Size(
                                              constraints.maxWidth,
                                              constraints.maxHeight * 2,
                                            ),
                                            itemSize,
                                          );
                                        }

                                        return SizedBox(
                                          width: constraints.maxWidth,
                                          // height: constraints.maxWidth * 5,
                                          child: Stack(
                                            children: List.generate(
                                              widget.list.items.length,
                                              (index) {
                                                final position =
                                                    _randomPositions[index];
                                                return AnimatedPositioned(
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeInOut,
                                                  left: position.dx,
                                                  top: position.dy,
                                                  width: itemSize,
                                                  height: itemSize,
                                                  child: Hero(
                                                    tag:
                                                        'product_${widget.list.id}_$index',
                                                    child: ProductImage(
                                                      imageUrl: widget
                                                          .list
                                                          .items[index]
                                                          .imageUrl,
                                                      index: index,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 100,
                              child: Center(
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: (constraints.maxWidth -
                                                (widget.list.items.length *
                                                        80 + // 每个item宽度
                                                    (widget.list.items.length -
                                                            1) *
                                                        8)) /
                                            2 // item间距
                                        ),
                                    itemCount: widget.list.items.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Hero(
                                          tag:
                                              'product_${widget.list.id}_$index',
                                          child: ProductImage(
                                            imageUrl: widget
                                                .list.items[index].imageUrl,
                                            index: index,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
