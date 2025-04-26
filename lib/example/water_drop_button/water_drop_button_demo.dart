import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/water_drop_button/water_drop_animation.dart';

class WaterDropButtonDemo extends StatefulWidget {
  const WaterDropButtonDemo({super.key});

  @override
  State<WaterDropButtonDemo> createState() => WaterDropButtonDemoState();
}

class WaterDropButtonDemoState extends State<WaterDropButtonDemo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '水滴按钮',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const WaterDropAnimation());
  }
}
