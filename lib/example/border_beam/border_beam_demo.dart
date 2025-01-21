import 'package:flutter/material.dart';

import 'border_beam.dart';
import 'border_beam_theme.dart';

class BorderBeamDemo extends StatefulWidget {
  const BorderBeamDemo({super.key});

  @override
  State<BorderBeamDemo> createState() => _BorderBeamDemoState();
}

class _BorderBeamDemoState extends State<BorderBeamDemo> {
  BorderBeamTheme _currentTheme = BorderBeamThemes.ocean;

  // 定义固定的展示区域大小
  static const double _demoWidth = 300;
  static const double _demoHeight = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('边框光束效果')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 展示区域
          Expanded(
            child: Center(
              child: SizedBox(
                width: _demoWidth,
                height: _demoHeight,
                child: BorderBeam(
                  theme: _currentTheme,
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text(
                      '边框光束效果',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 主题切换按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: BorderBeamThemes.all.map((theme) {
                return _buildThemeButton(theme);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(BorderBeamTheme theme) {
    final isSelected = _currentTheme == theme;
    return GestureDetector(
      onTap: () => setState(() => _currentTheme = theme),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [theme.colorFrom, theme.colorTo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorFrom.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : null,
          border: Border.all(
            color: isSelected ? theme.colorTo : Colors.transparent,
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            theme.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
