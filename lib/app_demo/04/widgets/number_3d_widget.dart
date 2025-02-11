import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class Number3DWidget extends StatefulWidget {
  final String number;
  final double size;

  const Number3DWidget({
    super.key,
    required this.number,
    this.size = 100,
  });

  @override
  State<Number3DWidget> createState() => _Number3DWidgetState();
}

class _Number3DWidgetState extends State<Number3DWidget>
    with AutomaticKeepAliveClientMixin {
  late Flutter3DController _controller;
  bool _isLoading = true;
  String? _modelPath;
  // 使用UUID来确保ID的唯一性
  final String _viewId = DateTime.now().microsecondsSinceEpoch.toString();
  bool _isDisposed = false;
  bool _isViewCreated = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
    _loadModel();
  }

  Future<void> _loadModel() async {
    if (!mounted || _isDisposed) return;

    setState(() {
      _isLoading = true;
      _isViewCreated = false;
    });

    try {
      // 根据数字加载对应的3D模型
      _modelPath = 'assets/3d_numbers/${widget.number}.glb';

      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _isViewCreated = true;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        debugPrint('加载3D模型失败: $e');
      }
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _isViewCreated = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(Number3DWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      _loadModel();
    }
  }

  @override
  void deactivate() {
    _isViewCreated = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isViewCreated = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading || _modelPath == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    // 使用 RepaintBoundary 和 ValueKey 来优化重建
    return RepaintBoundary(
      child: SizedBox(
        width: 150,
        height: widget.size,
        child: Visibility(
          visible: _isViewCreated,
          child: Flutter3DViewer(
            key: ValueKey(_viewId),
            src: _modelPath!,
            controller: _controller,
          ),
        ),
      ),
    );
  }
}
