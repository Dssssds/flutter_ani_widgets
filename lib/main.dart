import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/background_ripples/background_ripples.dart';
import 'package:flutter_x_widgets/example/blurfade/blur_fade.dart';
import 'package:flutter_x_widgets/example/border_beam/border_beam_demo.dart';
import 'package:flutter_x_widgets/example/calendar/calendar_demo.dart';
import 'package:flutter_x_widgets/example/card_scroll/card_scroll_demo.dart';
import 'package:flutter_x_widgets/example/card_scroll_joystick/card_scroll_joystick.dart';
import 'package:flutter_x_widgets/example/celebrate/celebrate_demo.dart';
import 'package:flutter_x_widgets/example/dots/dots_demo.dart';
import 'package:flutter_x_widgets/example/gemini_splash/gemini_splash_demo.dart';
import 'package:flutter_x_widgets/example/grid_animation/grid_animated.dart';
import 'package:flutter_x_widgets/example/loader_square/loader_square_demo.dart';
import 'package:flutter_x_widgets/example/neon_card/neon_card_demo.dart';
import 'package:flutter_x_widgets/example/notification_list/notification_list.dart';
import 'package:flutter_x_widgets/example/photo_effect/photo_effect_demo.dart';
import 'package:flutter_x_widgets/example/progress/progress_bar_demo.dart';
import 'package:flutter_x_widgets/example/scroll_progress/scroll_progress_demo.dart';
import 'package:flutter_x_widgets/example/stacked_cards/stacked_card.dart';
import 'package:flutter_x_widgets/example/text_hyper/hyper_text_demo.dart';
import 'package:flutter_x_widgets/example/text_on_path/text_on_path_demo.dart';
import 'package:flutter_x_widgets/example/text_reveal/text_reveal_demo.dart';
import 'package:flutter_x_widgets/example/text_shine/text_shine.dart';
import 'package:flutter_x_widgets/example/theme_mode/light_bulb_demo.dart';

void main() {
  runApp(const AnimationShowcaseApp());
}

class AnimationShowcaseApp extends StatelessWidget {
  const AnimationShowcaseApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 实验室',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey,
      ),
      home: HomeScreen(),
    );
  }
}

class AnimationExample {
  final String title;
  final Color? appbarColor;
  final bool isFullScreen;
  final Widget Function(BuildContext) builder;

  AnimationExample({
    required this.title,
    this.appbarColor,
    this.isFullScreen = false, // 默认 false
    required this.builder,
  });
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<AnimationExample> example = [
    AnimationExample(
        title: '网格动画',
        appbarColor: Colors.black,
        builder: (context) => const GridAnimatedDemo(),
        isFullScreen: false),
    AnimationExample(
        title: '文字模糊渐变',
        appbarColor: Colors.black,
        builder: (context) => const BlurFadeDemo(),
        isFullScreen: false),
    AnimationExample(
      title: '文字动画',
      builder: (context) => const AnimationDemoScreen(),
      appbarColor: Colors.black,
    ),
    AnimationExample(
      title: '滚动进度',
      builder: (context) => const ScrollProgressDemo(),
      appbarColor: Colors.black,
    ),
    AnimationExample(
      title: '花样进度条',
      builder: (context) => const ProgressBarDemo(),
      appbarColor: Colors.black,
    ),
    AnimationExample(
        title: '主题灯泡切换',
        builder: (context) => const NightModeDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '文字闪烁',
        builder: (context) => const TextShiningDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '文字滚动',
        builder: (context) => const HyperTextDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '自定义滑动列表',
        builder: (context) => const CardScrollDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '点阵图案',
        builder: (context) => const DotPatternWidget(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: 'Gemini Loading 飞溅动画',
        builder: (context) => const SparkleDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '呼吸动画',
        builder: (context) => const BackgroundRippleDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '相片效果',
        builder: (context) => const PhotoEffectDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '日历效果',
        builder: (context) => const CalendarDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '通知列表',
        builder: (context) => NotificationDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '庆祝动画',
        builder: (context) => const CelebrateDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '方形动画',
        builder: (context) => const LoaderSquareDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '摇杆卡片',
        builder: (context) => const CardScrollJoystick(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '边框线条动画',
        builder: (context) => const BorderBeamDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '卡片霓虹灯背景',
        builder: (context) => const NeonGradientCardDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '卡片堆叠提示',
        builder: (context) => const StackedCardDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
    AnimationExample(
        title: '文字控制器',
        builder: (context) => const TextOnPathDemo(),
        appbarColor: Colors.black,
        isFullScreen: true),
  ];

  @override
  Widget build(context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter 的实验中心.'),
          elevation: 0,
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: example.length,
          itemBuilder: (context, index) {
            if (index < example.length) {
              return Hero(
                  tag: 'Demo_${example[index].title}',
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            if (example[index].isFullScreen) {
                              return FullScreen(
                                  key: UniqueKey(), example: example[index]);
                            } else {
                              return DetailScreen(
                                key: UniqueKey(),
                                example: example[index],
                              );
                            }
                          }));
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.animation,
                                size: 45, color: Colors.white),
                            Text(
                              example[index].title,
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )),
                  ));
            } else {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const Text('Null'),
              );
            }
          },
        ));
  }
}

class FullScreen extends StatelessWidget {
  final AnimationExample example;

  const FullScreen({super.key, required this.example});

  @override
  Widget build(BuildContext context) {
    return example.builder(context);
  }
}

class DetailScreen extends StatelessWidget {
  final AnimationExample example;

  const DetailScreen({
    super.key,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(example.title),
        elevation: 0,
        backgroundColor: example.appbarColor ?? Theme.of(context).primaryColor,
      ),
      body: Hero(tag: 'Demo_${example.title}', child: example.builder(context)),
    );
  }
}
