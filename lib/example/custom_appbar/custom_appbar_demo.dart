import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/custom_appbar/components/app_bar/custom_strechy_appbar.dart';
import 'package:flutter_x_widgets/example/custom_appbar/components/inherited_widgets/directionalit_manager.dart';
import 'package:flutter_x_widgets/example/custom_appbar/components/models/page_content.dart';

class CustomAppBarDemo extends StatefulWidget {
  const CustomAppBarDemo({super.key});

  @override
  State<CustomAppBarDemo> createState() => _CustomAppBarDemoState();
}

class _CustomAppBarDemoState extends State<CustomAppBarDemo> {
  /// 自定义滑动控制器
  late ScrollController _scrollController;

  /// 文本方向
  TextDirection _textDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 切换文本方向
  void _toggleTextDirection() {
    setState(() {
      _textDirection = _textDirection == TextDirection.ltr
          ? TextDirection.rtl
          : TextDirection.ltr;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 文本方向管理器
    return DirectionalityManager(
      textDirection: _textDirection,
      toggleDirection: _toggleTextDirection,

      /// 子组件
      /// Directionality 是一个 Flutter 内置的 InheritedWidget,用于确定文本和其他需要方向性的渲染对象的环境方向性
      /// 它有两个主要作用:
      /// 1. 控制文本的阅读方向(从左到右 LTR 或从右到左 RTL)
      /// 2. 控制一些组件(如 Padding)中方向相关的属性解析
      ///
      /// 在这里我们使用它来包裹整个应用,以便可以动态切换整个应用的文本方向
      ///
      child: Directionality(
        textDirection: _textDirection,
        child: Scaffold(
          body: Stack(
            children: [
              Scrollbar(
                controller: _scrollController,

                /// 自定义滑动组件
                /// 自定义滑动组件是一个可以自定义滑动效果的组件,它可以让我们自定义滑动组件的滑动效果
                /// 在这里我们使用它来包裹整个应用,以便可以动态切换整个应用的滑动效果
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // -- App Bar
                    const CustomStrechyAppBar(
                      mainTitle: '2025年 运势',
                      subTitle: '好运连连',
                      image: 'assets/images/test1.png',
                    ),

                    /// 页面内容
                    SliverList.builder(
                      itemCount: pageContents.length,
                      itemBuilder: (context, index) {
                        final pageContent = pageContents[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                pageContent.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: index != 0 ? 18 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                pageContent.content,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
