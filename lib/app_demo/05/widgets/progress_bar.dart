import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// 自定义进度条组件
class SessionProgressBar extends StatelessWidget {
  final double progress;
  final String label;
  final int currentMinutes;
  final int currentSeconds;
  final int totalMinutes;

  const SessionProgressBar({
    super.key,
    required this.progress,
    required this.label,
    this.currentMinutes = 5,
    this.currentSeconds = 23,
    this.totalMinutes = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分段进度条
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                // 灰色背景条
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                // 蓝色进度条
                Container(
                  height: 10,
                  width: MediaQuery.of(context).size.width * 0.67 - 32, // 根据progress计算宽度，减去padding
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
                
                // 分隔线1 (1/3处)
                Positioned(
                  left: (MediaQuery.of(context).size.width - 32) / 3,
                  child: Container(
                    height: 10,
                    width: 2,
                    color: Colors.white,
                  ),
                ),
                
                // 分隔线2 (2/3处)
                Positioned(
                  left: (MediaQuery.of(context).size.width - 32) * 2 / 3,
                  child: Container(
                    height: 10,
                    width: 2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 进度信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 时间格式 5:23 / 8:00 minutes
                    Text(
                      '$currentMinutes:${currentSeconds.toString().padLeft(2, '0')} / $totalMinutes:00 minutes',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 4),
                    // Session Outcome
                    Text(
                      'Session Outcome:${(progress * 100).toInt()}%',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 右侧百分比
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: AppTextStyles.progress.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Train',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
