import 'package:flutter/material.dart';

class ControlPad extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onSpeedDown;
  final VoidCallback? onBackward;
  final VoidCallback? onPlayPause;
  final VoidCallback? onForward;
  final VoidCallback? onSpeedUp;

  const ControlPad({
    super.key,
    this.isPlaying = false,
    this.onSpeedDown,
    this.onBackward,
    this.onPlayPause,
    this.onForward,
    this.onSpeedUp,
  });

  @override
  State<ControlPad> createState() => _ControlPadState();
}

class _ControlPadState extends State<ControlPad> {
  String? _activeButton;

  void _handleTap(String buttonId, VoidCallback? callback) {
    if (callback == null) return;
    
    setState(() {
      _activeButton = buttonId;
    });
    
    callback();
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _activeButton = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLeftBtn(),
        const SizedBox(width: 20),
        _buildCenterBtnWithImage(isBackward: true, buttonId: 'backward'),
        const SizedBox(width: 20),
        _buildStopBtn(),
        const SizedBox(width: 20),
        _buildCenterBtnWithImage(isBackward: false, buttonId: 'forward'),
        const SizedBox(width: 20),
        _buildRightBtn(),
      ],
    );
  }

  Widget _buildLeftBtn() {
    final isActive = _activeButton == 'speedDown';
    
    return GestureDetector(
      onTap: () => _handleTap('speedDown', widget.onSpeedDown),
      child: AnimatedScale(
        scale: isActive ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? Colors.grey[900] : Colors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Image.asset(
              'assets/images/grid-view.png',
              width: 26,
              height: 26,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterBtnWithImage({
    required bool isBackward,
    required String buttonId,
  }) {
    final isActive = _activeButton == buttonId;
    final callback = isBackward ? widget.onBackward : widget.onForward;
    
    return GestureDetector(
      onTap: () => _handleTap(buttonId, callback),
      child: AnimatedScale(
        scale: isActive ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? Colors.grey[900] : Colors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Transform.rotate(
              angle: isBackward ? 3.14159 : 0,
              child: Image.asset(
                'assets/images/forward.png',
                width: 26,
                height: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStopBtn() {
    final isActive = _activeButton == 'playPause';
    
    return GestureDetector(
      onTap: () => _handleTap('playPause', widget.onPlayPause),
      child: AnimatedScale(
        scale: isActive ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? Colors.grey[900] : Colors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Image.asset(
              widget.isPlaying
                  ? 'assets/images/stop-circle.png'
                  : 'assets/images/play.png',
              width: 28,
              height: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightBtn() {
    final isActive = _activeButton == 'speedUp';
    
    return GestureDetector(
      onTap: () => _handleTap('speedUp', widget.onSpeedUp),
      child: AnimatedScale(
        scale: isActive ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? Colors.grey[900] : Colors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Center(
            child: Image.asset(
              'assets/images/shuffle.png',
              width: 26,
              height: 26,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
