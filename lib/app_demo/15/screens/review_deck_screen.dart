import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/15/models/review_topic.dart';
import 'package:flutter_x_widgets/app_demo/15/models/rules/review_rules.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/audio_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_bird.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_primary_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_secondary_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_toast.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/motion/pip_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class ReviewDeckScreen extends StatefulWidget {
  final PipController controller;
  final PipAudio audio;
  final String topicId;

  const ReviewDeckScreen({super.key, required this.controller, required this.audio, required this.topicId});

  @override
  State<ReviewDeckScreen> createState() => _ReviewDeckScreenState();
}

class _ReviewDeckScreenState extends State<ReviewDeckScreen> {
  late final ReviewTopic _topic;
  late int _index;
  bool _revealed = false;
  bool _done = false;
  bool _speaking = false;
  int _round = 1;

  PipController get controller => widget.controller;

  List<String> get _mastered => controller.masteredFor(_topic.id);

  ReviewTerm get _term => _topic.terms[_index];

  @override
  void initState() {
    super.initState();
    _topic = PipSeed.reviewTopicsById[widget.topicId] ?? PipSeed.reviewTopics.first;
    _index = ReviewRules.startIndex(_topic, _mastered);
  }

  @override
  void dispose() {
    unawaited(widget.audio.stop());
    super.dispose();
  }

  Future<void> _back() async {
    await widget.audio.stop();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _speak() async {
    setState(() => _speaking = true);
    final ok = await widget.audio.speak(_term.en);
    if (!mounted) return;
    setState(() => _speaking = false);
    if (!ok) PipToast.show(context, '这次没播放出来，点一下再听。');
  }

  Future<void> _advance() async {
    await widget.audio.stop();
    if (!mounted) return;
    setState(() {
      _speaking = false;
      _revealed = false;
      if (_index >= _topic.terms.length - 1) {
        _done = true;
      } else {
        _index += 1;
      }
    });
  }

  Future<void> _master() async {
    await controller.markReviewMastered(_topic.id, _term.en);
    if (!mounted) return;
    await _advance();
  }

  Future<void> _again() async {
    await widget.audio.stop();
    if (!mounted) return;
    setState(() {
      _index = 0;
      _revealed = false;
      _done = false;
      _speaking = false;
      _round += 1;
    });
  }

  void _toggleReveal() {
    setState(() => _revealed = !_revealed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('review-deck-screen'),
      backgroundColor: App15Theme.paper,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Column(
              children: [
                _DeckHeader(title: _topic.title, counter: _done ? null : '${_index + 1} / ${_topic.terms.length}', onBack: _back),
                Expanded(
                  child:
                      _done
                          ? _DeckFinish(topic: _topic, mastered: _mastered.length, round: _round, onAgain: _again, onBack: _back)
                          : _buildCards(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    final known = _mastered.contains(_term.en);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        children: [
          _DeckProgress(fraction: (_index + 1) / _topic.terms.length),
          const SizedBox(height: 14),
          Expanded(
            child: _FlashCard(key: ValueKey('review-card-$_index'), term: _term, revealed: _revealed, known: known, onTap: _toggleReveal),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              PipSecondaryButton(
                key: const ValueKey('review-listen'),
                label: _speaking ? '正在播放…' : '听发音',
                height: 46,
                expand: false,
                leading: PipIcon(asset: PipAssets.icon('sound'), size: 19),
                onPressed: _speaking ? null : _speak,
              ),
              const Spacer(),
              Text(
                '${_mastered.length} / ${_topic.terms.length} 已掌握',
                key: const ValueKey('review-deck-mastered'),
                style: App15Theme.captionStyle.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_revealed)
            Row(
              children: [
                Expanded(child: PipPrimaryButton(key: const ValueKey('review-reveal'), label: '看中文', height: 54, onPressed: _toggleReveal)),
                const SizedBox(width: 12),
                Expanded(
                  child: PipSecondaryButton(
                    key: const ValueKey('review-skip'),
                    label: '先跳过',
                    height: 54,
                    trailing: PipIcon(asset: PipAssets.icon('arrow'), size: 18),
                    onPressed: _advance,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: PipSecondaryButton(
                    key: const ValueKey('review-again'),
                    label: '还不熟',
                    height: 54,
                    leading: PipIcon(asset: PipAssets.icon('review'), size: 19),
                    onPressed: _advance,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PipPrimaryButton(
                    key: const ValueKey('review-master'),
                    label: known ? '再记一次' : '记住了',
                    height: 54,
                    trailing: PipIcon(asset: PipAssets.icon('check'), size: 19),
                    onPressed: _master,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DeckHeader extends StatelessWidget {
  final String title;
  final String? counter;
  final VoidCallback onBack;

  const _DeckHeader({required this.title, required this.counter, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            PipIconButton(icon: 'back', semanticsLabel: '返回复习列表', onPressed: onBack),
            const SizedBox(width: 4),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: App15Theme.pathTitleStyle),
              ),
            ),
            if (counter != null)
              Text(
                counter!,
                key: const ValueKey('review-deck-counter'),
                style: App15Theme.captionStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w900, color: App15Theme.muted),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _DeckProgress extends StatelessWidget {
  final double fraction;

  const _DeckProgress({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: App15Theme.lockedSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: App15Theme.ink, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fraction.clamp(0, 1),
            heightFactor: 1,
            child: const DecoratedBox(
              decoration: BoxDecoration(color: App15Theme.yellow, border: Border(right: BorderSide(color: App15Theme.ink))),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashCard extends StatefulWidget {
  final ReviewTerm term;
  final bool revealed;
  final bool known;
  final VoidCallback onTap;

  const _FlashCard({super.key, required this.term, required this.revealed, required this.known, required this.onTap});

  @override
  State<_FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<_FlashCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = PipMotionSpec.of(context);

    return Semantics(
      button: true,
      label: '翻转词卡',
      value: '${widget.term.en}，${widget.revealed ? widget.term.cn : '点一下，看中文'}',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: motion.buttonPress,
            transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [App15Theme.yellowPale, App15Theme.paper],
                stops: [0, 0.72],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: App15Theme.ink, width: 2),
              boxShadow: [BoxShadow(color: App15Theme.neutralShadow, offset: Offset(0, _pressed ? 3 : 6))],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: App15Theme.paper,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: App15Theme.ink, width: 1.5),
                    ),
                    child: Text(
                      widget.known ? '已掌握' : '还没掌握',
                      key: const ValueKey('review-card-tag'),
                      style: App15Theme.captionStyle.copyWith(fontSize: 10, fontWeight: FontWeight.w900, color: App15Theme.mutedLabel),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 46),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.term.en,
                          key: const ValueKey('review-card-en'),
                          textAlign: TextAlign.center,
                          style: App15Theme.bodyStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.7, height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: motion.modalPop,
                          child:
                              widget.revealed
                                  ? Text(
                                    widget.term.cn,
                                    key: const ValueKey('review-card-cn'),
                                    textAlign: TextAlign.center,
                                    style: App15Theme.bodyStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w900, height: 1.4),
                                  )
                                  : Text(
                                    '点一下，看中文',
                                    key: const ValueKey('review-card-prompt'),
                                    style: App15Theme.captionStyle.copyWith(fontSize: 13, color: const Color(0xFF858878), height: 1.4),
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.revealed ? '再点一下可以收起' : '点卡片翻面',
                          style: App15Theme.captionStyle.copyWith(fontSize: 11, color: const Color(0xFF838676)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckFinish extends StatelessWidget {
  final ReviewTopic topic;
  final int mastered;
  final int round;
  final VoidCallback onAgain;
  final VoidCallback onBack;

  const _DeckFinish({required this.topic, required this.mastered, required this.round, required this.onAgain, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final all = mastered >= topic.terms.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: math.max(0, constraints.maxHeight - 20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: -4 * math.pi / 180,
                  child: const PipBird(semanticsLabel: 'Pip 为你庆祝', asset: PipAssets.birdCelebrate, width: 150, height: 165),
                ),
                const SizedBox(height: 8),
                Text(
                  all ? '这一组，全记住了！' : '这一轮，复习完成！',
                  key: const ValueKey('review-deck-finish-title'),
                  textAlign: TextAlign.center,
                  style: App15Theme.finishTitleStyle.copyWith(fontSize: 27, letterSpacing: -0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  all ? '下次用到，可以直接开口。' : '不熟的词会留在牌堆里，再来一轮就好。',
                  textAlign: TextAlign.center,
                  style: App15Theme.bodyStyle.copyWith(fontSize: 14, color: App15Theme.muted),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFBF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: App15Theme.line, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('已掌握 $mastered / ${topic.terms.length}', style: App15Theme.captionStyle.copyWith(color: App15Theme.mutedLabel)),
                      const SizedBox(width: 16),
                      Text(
                        '本轮 $round 轮',
                        key: const ValueKey('review-deck-round'),
                        style: App15Theme.captionStyle.copyWith(color: App15Theme.mutedLabel),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: PipSecondaryButton(
                        key: const ValueKey('review-deck-restart'),
                        label: '再来一轮',
                        height: 54,
                        trailing: PipIcon(asset: PipAssets.icon('review'), size: 18),
                        onPressed: onAgain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PipPrimaryButton(
                        key: const ValueKey('review-deck-back'),
                        label: '返回复习',
                        height: 54,
                        trailing: PipIcon(asset: PipAssets.icon('arrow'), size: 18),
                        onPressed: onBack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
