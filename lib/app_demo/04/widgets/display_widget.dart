import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/04/animations/radial_animation.dart';
import 'package:flutter_x_widgets/app_demo/04/utils/constants.dart';
import 'package:flutter_x_widgets/app_demo/04/widgets/number_3d_widget.dart';

class DisplayWidget extends StatefulWidget {
  final String result;
  final String process;

  const DisplayWidget({
    super.key,
    required this.result,
    this.process = '',
  });

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;
  List<Widget> _numberWidgets = [];
  bool _shouldPlayRadialAnimation = false;

  // 用于跟踪当前显示的数字
  String _currentResult = '';
  // 用于跟踪上一次的输入，判断是否是等号

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _currentResult = widget.result;
    _updateNumberWidgets();
  }

  @override
  void didUpdateWidget(DisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查是否刚刚点击了等号
    final isEqualsPressed = widget.process.contains('=');
    // 更新状态
    if (widget.result != '0') {
      setState(() {
        _currentResult = widget.result;
        _updateNumberWidgets();

        // 只在点击等号时触发动画
        if (isEqualsPressed) {
          _triggerRadialAnimation();
        }
      });
    }

    // 更新上一次的输入状态
  }

  // 触发放射动画
  void _triggerRadialAnimation() {
    setState(() {
      _shouldPlayRadialAnimation = true;
    });
    // 动画结束后重置状态
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _shouldPlayRadialAnimation = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  // 创建3D数字组件
  Widget _create3DNumber(String number, int index) {
    // 使用组合键，包含数字和位置信息
    return KeyedSubtree(
      key: ValueKey('number_3d_${number}_$index'),
      child: Number3DWidget(
        number: number,
        size: 200,
      ),
    );
  }

  // 创建非数字显示组件
  Widget _createTextWidget(String text, int index) {
    return Container(
      key: ValueKey('text_${text}_$index'),
      alignment: Alignment.center,
      width: 40,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 60.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: AppFonts.neumaticGothicSemiBold,
        ),
      ),
    );
  }

  // 更新数字部件列表
  void _updateNumberWidgets() {
    final List<String> chars = _currentResult.split('');
    _numberWidgets = List.generate(chars.length, (index) {
      final char = chars[index];
      if (RegExp(r'[0-9]').hasMatch(char)) {
        return _create3DNumber(char, index);
      }
      return _createTextWidget(char, index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: RadialAnimation(
        isPlaying: _shouldPlayRadialAnimation,
        child: Container(
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    widget.process,
                    style: const TextStyle(
                      fontSize: 24.0,
                      color: Colors.white70,
                      fontFamily: AppFonts.sfProDisplayRegular,
                    ),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _numberWidgets,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
