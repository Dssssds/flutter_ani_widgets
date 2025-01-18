import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/example/card_scroll/card_add_button_sheet.dart';
import 'package:flutter_x_widgets/example/card_scroll/card_settings_page.dart';
import 'package:flutter_x_widgets/example/card_scroll/horizontal.dart';
import 'package:flutter_x_widgets/example/card_scroll/vertical.dart';

class CardScrollDemo extends StatefulWidget {
  const CardScrollDemo({super.key});
  @override
  CardScrollDemoState createState() => CardScrollDemoState();
}

// 定义卡片数据模型类
class CardData {
  final String title;
  final String date;
  final String? type;
  final int timestamp;
  const CardData({
    required this.title,
    required this.date,
    this.type,
    required this.timestamp,
  });
}

class CardScrollDemoState extends State<CardScrollDemo> {
  late final List<CardData> cards;
  bool showDate = true;
  bool isHorizontal = true;

  @override
  void initState() {
    super.initState();
    cards = [
      const CardData(title: '', date: '', type: 'add', timestamp: 0),
    ];

    // 给 Cards 增加 20 条默认数据
    for (int i = 0; i < 10; i++) {
      cards.add(CardData(
        title: '',
        date: '',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    for (int i = 0; i < 5; i++) {
      cards.add(CardData(
        title: 'XXX',
        date: '2024年1月1日',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    // 给 card 进行排序, 按照 timestamp 排序
    cards.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '卡片滚动',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardSettingsPage(
                    showDate: showDate,
                    isHorizontal: isHorizontal,
                    onShowDateChanged: (value) {
                      setState(() {
                        showDate = value;
                      });
                    },
                    onDirectionChanged: (value) {
                      setState(() {
                        isHorizontal = value;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            if (isHorizontal)
              CardHorizontalScroll(
                cards: cards,
                viewportHeight: MediaQuery.of(context).size.height * 0.8,
                onAddPressed: _showAddBottomSheet,
                showDate: showDate,
              )
            else
              CardVerticalScroll(
                cards: cards,
                viewportHeight: MediaQuery.of(context).size.height * 0.8,
                onAddPressed: _showAddBottomSheet,
                showDate: showDate,
              ),
          ],
        ),
      ),
    );
  }

  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const CardAddBottomSheet();
      },
    );
  }
}
