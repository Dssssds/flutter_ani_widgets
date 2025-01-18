import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/text_reveal/strategies/FadeBlurStrategy.dart';
import 'package:flutter_x_widgets/example/text_reveal/strategies/FlipUpStragegy.dart';
import 'package:flutter_x_widgets/example/text_reveal/strategies/FlyingCharactersStrategy.dart';
import 'package:flutter_x_widgets/example/text_reveal/strategies/SwirlFloatStrategy.dart';
import 'package:flutter_x_widgets/example/text_reveal/text_reveal_widget.dart';

// Animation Strategy Selection Model
class AnimationPreset {
  final String name;
  final TextAnimationStrategy strategy;
  final String description;

  const AnimationPreset({
    required this.name,
    required this.strategy,
    required this.description,
  });
}

class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({super.key});

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen> {
  bool _isAnimating = false;
  final String _demoText = "动画是一种魔法! ✨";
  AnimationUnit _selectedUnit = AnimationUnit.character;
  AnimationDirection _direction = AnimationDirection.forward;
  late AnimationPreset _selectedPreset;
  final TextEditingController _textController = TextEditingController();

  // Define animation presets
  final List<AnimationPreset> presets = const [
    AnimationPreset(
      name: "经典淡入淡出",
      strategy: FadeBlurStrategy(),
      description: "平滑的淡入淡出效果配合高斯模糊",
    ),
    AnimationPreset(
      name: "轻柔上浮",
      strategy: FlyingCharactersStrategy(
        maxOffset: 50,
        randomDirection: false,
        angle: -math.pi / 2,
      ),
      description: "字符轻柔地向上浮动",
    ),
    AnimationPreset(
      name: "轻柔上浮带模糊",
      strategy: FlyingCharactersStrategy(
        maxOffset: 50,
        randomDirection: false,
        enableBlur: true,
        angle: -math.pi / 2,
      ),
      description: "字符轻柔地向上浮动并带有模糊效果",
    ),
    AnimationPreset(
      name: "混沌散射",
      strategy: FlyingCharactersStrategy(
        maxOffset: 50,
        randomDirection: true,
      ),
      description: "字符向随机方向散射",
    ),
    AnimationPreset(
      name: "混沌散射带模糊",
      strategy: FlyingCharactersStrategy(
        maxOffset: 50,
        randomDirection: true,
        enableBlur: true,
      ),
      description: "字符向随机方向散射并带有模糊效果",
    ),
    AnimationPreset(
      name: "漩涡浮动",
      strategy: SwirlFloatStrategy(
        yOffset: -200.0,
        maxXDeviation: 60.0,
        maxBlur: 10.0,
        enableBlur: false,
        curveIntensity: 0.7, // 更明显的S曲线
        synchronizeAnimation: true,
      ),
      description: "字符以漩涡状浮动",
    ),
    AnimationPreset(
      name: "漩涡浮动带模糊",
      strategy: SwirlFloatStrategy(
        yOffset: -200.0,
        maxXDeviation: 60.0,
        maxBlur: 10.0,
        enableBlur: true,
        curveIntensity: 0.7,
        synchronizeAnimation: true, // 更明显的S曲线
      ),
      description: "字符以漩涡状浮动并带有模糊效果",
    ),
    AnimationPreset(
      name: '翻转上浮',
      strategy: FlipUpStrategy(
        perspectiveValue: 0.02, // 调整以获得更多/更少的透视效果
      ),
      description: "字符使用3D变换进行翻转",
    )
  ];

  @override
  void initState() {
    super.initState();
    _selectedPreset = presets[0];
    _textController.text = _demoText;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      // Animation Preview Area
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 100.0,
                        ),
                        child: EnhancedTextRevealEffect(
                          text: _demoText,
                          trigger: _isAnimating,
                          strategy: _selectedPreset.strategy,
                          unit: _selectedUnit,
                          direction: _direction,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ), // Replace with your actual widget
                      ),

                      const SizedBox(height: 32),

                      // Controls Section
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isAnimating = !_isAnimating;
                            });
                          },
                          icon: Icon(_isAnimating
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded),
                          label: Text(_isAnimating ? '重置' : '播放',
                              style: const TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Animation Settings
                      Column(
                        children: [
                          // 动画预设选择器
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonHideUnderline(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<AnimationPreset>(
                                  isExpanded: true,
                                  value: _selectedPreset,
                                  menuMaxHeight: 300,
                                  items: presets.map((preset) {
                                    return DropdownMenuItem(
                                      value: preset,
                                      child: Text(
                                        preset.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (preset) {
                                    if (preset != null) {
                                      setState(() {
                                        _selectedPreset = preset;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),

                          // 控制按钮组
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              // 动画单位选择器
                              SegmentedButton<AnimationUnit>(
                                segments: const [
                                  ButtonSegment(
                                    value: AnimationUnit.character,
                                    label: Text('字符'),
                                    icon: Icon(Icons.text_fields),
                                  ),
                                  ButtonSegment(
                                    value: AnimationUnit.word,
                                    label: Text('单词'),
                                    icon: Icon(Icons.wrap_text),
                                  ),
                                ],
                                selected: {_selectedUnit},
                                onSelectionChanged:
                                    (Set<AnimationUnit> selection) {
                                  setState(() {
                                    _selectedUnit = selection.first;
                                  });
                                },
                              ),

                              // 方向选择器
                              SegmentedButton<AnimationDirection>(
                                segments: const [
                                  ButtonSegment(
                                    value: AnimationDirection.forward,
                                    label: Text('正向'),
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                  ButtonSegment(
                                    value: AnimationDirection.reverse,
                                    label: Text('反向'),
                                    icon: Icon(Icons.arrow_back),
                                  ),
                                ],
                                selected: {_direction},
                                onSelectionChanged:
                                    (Set<AnimationDirection> selection) {
                                  setState(() {
                                    _direction = selection.first;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
