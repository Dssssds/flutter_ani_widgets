import 'package:flutter/material.dart';

class CardSettingsPage extends StatefulWidget {
  final bool showDate;
  final bool isHorizontal;
  final Function(bool) onShowDateChanged;
  final Function(bool) onDirectionChanged;

  const CardSettingsPage({
    super.key,
    required this.showDate,
    required this.isHorizontal,
    required this.onShowDateChanged,
    required this.onDirectionChanged,
  });

  @override
  State<CardSettingsPage> createState() => _CardSettingsPageState();
}

class _CardSettingsPageState extends State<CardSettingsPage> {
  bool showDate = false;
  bool isHorizontal = false;

  @override
  void initState() {
    super.initState();
    showDate = widget.showDate;
    isHorizontal = widget.isHorizontal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '设置',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '列表设置',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isHorizontal = true;
                            });
                            widget.onDirectionChanged(true);
                          },
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: isHorizontal
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: const Center(
                                  child: Text(
                                    '什么什么什么事',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '水平',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isHorizontal = false;
                            });
                            widget.onDirectionChanged(false);
                          },
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: !isHorizontal
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: const Center(
                                  child: Text(
                                    '什么什么什么事',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '水平',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '日期显示',
                  style: TextStyle(color: Colors.white),
                ),
                Switch(
                  value: showDate,
                  onChanged: (value) {
                    setState(() {
                      showDate = value;
                    });
                    widget.onShowDateChanged(value);
                  },
                  activeColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
