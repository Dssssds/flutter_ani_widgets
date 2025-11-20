import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';

class RetroWaveformPainter extends CustomPainter {
  final Waveform waveform;
  final Duration currentPosition;
  final Duration totalDuration;
  final Color fixedWaveColor;
  final Color liveWaveColor;
  final Color seekLineColor;
  final double strokeWidth;
  final double pixelsPerStep;

  RetroWaveformPainter({
    required this.waveform,
    required this.currentPosition,
    required this.totalDuration,
    this.fixedWaveColor = const Color(0xFF3A3A3A),
    this.liveWaveColor = const Color(0xFFFFD200),
    this.seekLineColor = const Color(0xFFFFD200),
    this.strokeWidth = 3.0,
    this.pixelsPerStep = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalDuration == Duration.zero) return;

    final double width = size.width;
    final double height = size.height;

    // 计算播放进度
    final progress =
        currentPosition.inMilliseconds / totalDuration.inMilliseconds;
    final progressX = width * progress;

    // 绘制波形
    final waveformPixelsPerWindow =
        waveform.positionToPixel(totalDuration).toInt();
    final waveformPixelsPerDevicePixel = waveformPixelsPerWindow / width;
    final waveformPixelsPerStep = waveformPixelsPerDevicePixel * pixelsPerStep;

    for (var i = 0.0; i <= waveformPixelsPerWindow; i += waveformPixelsPerStep) {
      final sampleIdx = i.toInt();
      final x = i / waveformPixelsPerDevicePixel;

      // 根据播放进度选择颜色
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = x <= progressX ? liveWaveColor : fixedWaveColor;

      final minY = _normalise(waveform.getPixelMin(sampleIdx), height);
      final maxY = _normalise(waveform.getPixelMax(sampleIdx), height);

      canvas.drawLine(
        Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
        Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
        paint,
      );
    }

    // 绘制播放位置线
    final seekLinePaint = Paint()
      ..color = seekLineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(progressX, 0),
      Offset(progressX, height),
      seekLinePaint,
    );
  }

  double _normalise(int s, double height) {
    if (waveform.flags == 0) {
      final y = 32768 + s.clamp(-32768.0, 32767.0).toDouble();
      return height - 1 - y * height / 65536;
    } else {
      final y = 128 + s.clamp(-128.0, 127.0).toDouble();
      return height - 1 - y * height / 256;
    }
  }

  @override
  bool shouldRepaint(RetroWaveformPainter oldDelegate) {
    return oldDelegate.currentPosition != currentPosition;
  }
}
