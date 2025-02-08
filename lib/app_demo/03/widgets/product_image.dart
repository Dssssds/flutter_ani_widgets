import 'package:flutter/material.dart';

class ProductImage extends StatefulWidget {
  final String imageUrl;
  final int index;

  const ProductImage({super.key, required this.imageUrl, required this.index});

  @override
  State<StatefulWidget> createState() => ProductImageState();
}

class ProductImageState extends State<ProductImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + (widget.index * 100)));

    _animation = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.contain,
          // 加载错误的时候处理方式
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              width: 80,
              height: 80,
              child: Icon(Icons.error_outline, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
