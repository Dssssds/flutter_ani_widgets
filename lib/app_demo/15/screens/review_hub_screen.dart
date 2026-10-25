import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/root_tab.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/audio_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/review_deck_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_ring.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_screen_header.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/design_tokens.dart';

class ReviewHubScreen extends StatelessWidget {
  final PipController controller;
  final PipAudio audio;

  const ReviewHubScreen({super.key, required this.controller, required this.audio});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final mastered = controller.totalMastered;
        final total = controller.totalTermCount;
        final percent = total == 0 ? 0 : (mastered / total * 100).round();

        return Column(
          key: const ValueKey('review-hub-screen'),
          children: [
            PipScreenHeader(title: '复习', onBack: () => controller.setTab(RootTab.path)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
                child: Column(
                  children: [
                    _SummaryCard(mastered: mastered, total: total, percent: percent),
                    const SizedBox(height: 20),
                    for (var index = 0; index < PipSeed.reviewTopics.length; index++) ...[
                      if (index > 0) const SizedBox(height: 15),
                      _TopicCard(
                        topicId: PipSeed.reviewTopics[index].id,
                        controller: controller,
                        onTap: () => _openDeck(context, PipSeed.reviewTopics[index].id),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openDeck(BuildContext context, String topicId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => ReviewDeckScreen(controller: controller, audio: audio, topicId: topicId)));
  }
}

class _SummaryCard extends StatelessWidget {
  final int mastered;
  final int total;
  final int percent;

  const _SummaryCard({required this.mastered, required this.total, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('review-summary'),
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 17),
      decoration: BoxDecoration(
        color: App15Theme.yellow,
        borderRadius: BorderRadius.circular(App15Design.panelRadius),
        border: Border.all(color: App15Theme.ink, width: 2),
        boxShadow: const [BoxShadow(color: App15Theme.yellowDark, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: App15Theme.paper,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: App15Theme.ink, width: 2),
            ),
            child: Center(child: PipIcon(asset: PipAssets.icon('review'), size: 25)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已经掌握 $mastered / $total 个表达',
                  key: const ValueKey('review-mastered-total'),
                  style: App15Theme.bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w900, height: 1.25),
                ),
                const SizedBox(height: 4),
                Text('翻一翻词卡，把学过的句子变成自己的。', style: App15Theme.captionStyle.copyWith(fontSize: 12, color: App15Theme.ink)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          PipRing(
            fraction: total == 0 ? 0 : mastered / total,
            size: 55,
            thickness: 4.5,
            trackColor: const Color(0xFFF1E7AD),
            child: Container(
              width: 41,
              height: 41,
              decoration: const BoxDecoration(color: App15Theme.yellow, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$percent%',
                  style: App15Theme.captionStyle.copyWith(fontSize: 11, color: App15Theme.ink, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String topicId;
  final PipController controller;
  final VoidCallback onTap;

  const _TopicCard({required this.topicId, required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final topic = PipSeed.reviewTopicsById[topicId]!;
    final done = controller.masteredFor(topicId).length;
    final total = topic.terms.length;
    final fraction = total == 0 ? 0.0 : done / total;

    return Semantics(
      button: true,
      label: '${topic.title}，已掌握 $done / $total',
      child: ExcludeSemantics(
        child: GestureDetector(
          key: ValueKey('review-topic-$topicId'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
            decoration: BoxDecoration(
              color: App15Theme.paper,
              borderRadius: BorderRadius.circular(App15Design.cardRadius),
              border: Border.all(color: App15Theme.ink, width: 2),
              boxShadow: App15Design.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: App15Theme.yellowPale,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: App15Theme.yellowDark, width: 1.5),
                  ),
                  child: Center(child: PipIcon(asset: PipAssets.icon(topic.icon), size: 25)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topic.title, style: App15Theme.bodyStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w900, height: 1.15)),
                      const SizedBox(height: 4),
                      Text(
                        topic.copy,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: App15Theme.captionStyle.copyWith(fontSize: 12, height: 1.35),
                      ),
                      const SizedBox(height: 9),
                      _TopicProgress(fraction: fraction),
                      const SizedBox(height: 5),
                      Text('已掌握 $done / $total', style: App15Theme.captionStyle.copyWith(fontSize: 10, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                PipIcon(asset: PipAssets.icon('arrow'), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicProgress extends StatelessWidget {
  final double fraction;

  const _TopicProgress({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      decoration: BoxDecoration(
        color: App15Theme.progressTrack,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: App15Theme.ink, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(widthFactor: fraction.clamp(0, 1), heightFactor: 1, child: const ColoredBox(color: App15Theme.mint)),
        ),
      ),
    );
  }
}
