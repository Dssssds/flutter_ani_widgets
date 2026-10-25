import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_x_widgets/app_demo/15/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/15/models/lesson.dart';
import 'package:flutter_x_widgets/app_demo/15/models/run_state.dart';
import 'package:flutter_x_widgets/app_demo/15/models/services/audio_service.dart';
import 'package:flutter_x_widgets/app_demo/15/models/view_models/pip_controller.dart';
import 'package:flutter_x_widgets/app_demo/15/screens/complete_screen.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_bird.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_icon_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_primary_button.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/common/pip_toast.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/motion/pip_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/design_tokens.dart';

class QuizScreen extends StatefulWidget {
  final PipController controller;
  final PipAudio audio;

  const QuizScreen({super.key, required this.controller, required this.audio});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _playing = false;
  bool _played = false;
  int? _audioQuestionIndex;

  PipController get controller => widget.controller;

  int get _questionIndex => controller.state.run?.qIndex ?? 0;

  bool get _isPlaying => _playing && _audioQuestionIndex == _questionIndex;

  bool get _isPlayed => _played && _audioQuestionIndex == _questionIndex;

  @override
  void dispose() {
    unawaited(widget.audio.stop());
    super.dispose();
  }

  Future<void> _leave() async {
    await widget.audio.stop();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _syncAudioQuestion() {
    if (_audioQuestionIndex != _questionIndex) {
      _audioQuestionIndex = _questionIndex;
      _playing = false;
      _played = false;
    }
  }

  Future<void> _toggleSound() async {
    final enable = !controller.state.soundOn;
    await controller.setSoundOn(enable);
    if (enable) unawaited(widget.audio.playAsset(PipAssets.chime));
  }

  Future<void> _playQuestionAudio() async {
    final question = controller.currentQuestion;
    if (question == null) return;
    final index = _questionIndex;
    setState(() {
      _audioQuestionIndex = index;
      _playing = true;
    });

    bool ok;
    if (question.audio != null) {
      ok = await widget.audio.playAsset(PipAssets.audio(question.audio!));
    } else if (question.audioText != null) {
      ok = await widget.audio.speak(question.audioText!);
    } else {
      ok = false;
      if (mounted) PipToast.show(context, '这道题没有音频。');
    }

    if (!mounted) return;
    setState(() {
      if (_audioQuestionIndex == index) {
        _playing = false;
        _played = ok;
      }
    });
    if (!ok) PipToast.show(context, '这次没播放出来，点一下再听。');
  }

  void _select(String value) {
    controller.selectAnswer(value);
  }

  void _check() {
    final result = controller.checkAnswer();
    if (result == AnswerCheck.correct && controller.state.soundOn) {
      unawaited(widget.audio.playAsset(PipAssets.chime));
    }
  }

  void _retry() {
    controller.retryAnswer();
  }

  Future<void> _next() async {
    await widget.audio.stop();
    final result = controller.advanceQuestion();
    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => CompleteScreen(controller: controller, audio: widget.audio, result: result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncAudioQuestion();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final run = controller.state.run;
        final question = controller.currentQuestion;
        final lesson = run == null ? null : controller.lessonFor(run.lessonId);
        if (run == null || question == null || lesson == null) {
          return const Scaffold(backgroundColor: App15Theme.paper, body: SizedBox.shrink());
        }

        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) unawaited(widget.audio.stop());
          },
          child: Scaffold(
            key: const ValueKey('quiz-screen'),
            backgroundColor: App15Theme.paper,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _QuizTopBar(answered: run.answered, total: lesson.questions.length, lives: controller.state.lives, onClose: _leave),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(App15Design.quizSidePadding, 8, App15Design.quizSidePadding, 24),
                      child: _QuizBody(
                        run: run,
                        lesson: lesson,
                        question: question,
                        soundOn: controller.state.soundOn,
                        playing: _isPlaying,
                        played: _isPlayed,
                        onToggleSound: _toggleSound,
                        onPlayAudio: _playQuestionAudio,
                        onSelect: _select,
                      ),
                    ),
                  ),
                  _QuizFooter(
                    run: run,
                    question: question,
                    lesson: lesson,
                    lives: controller.state.lives,
                    onCheck: _check,
                    onRetry: _retry,
                    onNext: _next,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuizTopBar extends StatelessWidget {
  final int answered;
  final int total;
  final int lives;
  final VoidCallback onClose;

  const _QuizTopBar({required this.answered, required this.total, required this.lives, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: App15Design.quizTopHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 18, 10),
        child: Row(
          children: [
            PipIconButton(
              key: const ValueKey('quiz-close'),
              icon: 'close',
              semanticsLabel: '退出本课，保留答题进度',
              onPressed: onClose,
              size: 22,
              color: App15Theme.quizClose,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Semantics(
                label: '本课进度',
                value: '$answered / $total',
                child: _QuizProgress(fraction: total == 0 ? 0 : answered / total),
              ),
            ),
            const SizedBox(width: 14),
            Semantics(
              label: '剩余 $lives 颗生命',
              child: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PipIcon(asset: 'assets/images/15/icons/heart.svg', size: 22),
                    const SizedBox(width: 4),
                    Text(
                      '$lives',
                      key: const ValueKey('quiz-lives'),
                      style: App15Theme.bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w900, height: 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizProgress extends StatelessWidget {
  final double fraction;

  const _QuizProgress({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFEBECE3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: App15Theme.ink, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: fraction.clamp(0, 1),
              heightFactor: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: App15Theme.yellow,
                  border: Border(right: BorderSide(color: App15Theme.ink, width: 2)),
                ),
                child: Align(alignment: Alignment.topCenter, child: Container(height: 3, color: const Color(0xFFFFF0A8))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizBody extends StatelessWidget {
  final RunState run;
  final Lesson lesson;
  final Question question;
  final bool soundOn;
  final bool playing;
  final bool played;
  final VoidCallback onToggleSound;
  final VoidCallback onPlayAudio;
  final ValueChanged<String> onSelect;

  const _QuizBody({
    required this.run,
    required this.lesson,
    required this.question,
    required this.soundOn,
    required this.playing,
    required this.played,
    required this.onToggleSound,
    required this.onPlayAudio,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final prefix =
        run.mode == RunMode.review
            ? '复习 · '
            : run.lessonId == 'challenge'
            ? '挑战 · '
            : '';
    final type = question.type == QuestionType.listen ? '听音选图' : '选词填空';
    final correct = run.feedback == AnswerFeedback.correct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$prefix$type · ${run.qIndex + 1} / ${lesson.questions.length}',
                key: const ValueKey('quiz-meta'),
                style: App15Theme.captionStyle.copyWith(color: App15Theme.muted, fontSize: 13, letterSpacing: 0.2),
              ),
            ),
            Semantics(
              button: true,
              toggled: soundOn,
              label: soundOn ? '关闭答题音效' : '开启答题音效',
              child: ExcludeSemantics(
                child: GestureDetector(
                  key: const ValueKey('quiz-sound-toggle'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggleSound,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(child: PipIcon(asset: PipAssets.icon(soundOn ? 'sound' : 'mute'), size: 22)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Semantics(header: true, child: Text(question.prompt, key: const ValueKey('quiz-title'), style: App15Theme.quizTitleStyle)),
        const SizedBox(height: 17),
        _Dialogue(question: question, correct: correct, listening: playing, played: played, onListen: onPlayAudio),
        if (question.type == QuestionType.listen) ...[
          const SizedBox(height: 17),
          _AudioPrompt(playing: playing, played: played, onTap: onPlayAudio),
          const SizedBox(height: 17),
          _ListenOptions(question: question, run: run, onSelect: onSelect),
        ] else ...[
          const SizedBox(height: 18),
          _FillQuestion(question: question, run: run, onSelect: onSelect),
        ],
      ],
    );
  }
}

class _Dialogue extends StatelessWidget {
  final Question question;
  final bool correct;
  final bool listening;
  final bool played;
  final VoidCallback onListen;

  const _Dialogue({required this.question, required this.correct, required this.listening, required this.played, required this.onListen});

  @override
  Widget build(BuildContext context) {
    final bubble = _SpeechBubble(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(question.cn, style: App15Theme.bodyStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w800, height: 1.45)),
          if (question.type == QuestionType.fill) ...[
            const SizedBox(height: 4),
            Semantics(
              button: true,
              label: listening ? '正在播放英文发音' : '播放英文发音',
              child: ExcludeSemantics(
                child: GestureDetector(
                  key: const ValueKey('quiz-listen-inline'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onListen,
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PipIcon(asset: PipAssets.icon('sound'), size: 17, color: App15Theme.mutedLabel),
                        const SizedBox(width: 6),
                        Text(
                          listening
                              ? '正在播放…'
                              : played
                              ? '再听一遍'
                              : '听听怎么说',
                          style: App15Theme.captionStyle.copyWith(fontSize: 12, color: App15Theme.mutedLabel),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!correct) ...[
          const PipBird(key: ValueKey('quiz-bird-think'), asset: PipAssets.birdThink, width: 108, height: 130, rotationDegrees: -6),
          const SizedBox(width: 6),
        ],
        Expanded(child: bubble),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final Widget child;

  const _SpeechBubble({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: -7, top: 34, child: CustomPaint(size: const Size(10, 20), painter: _BubbleTailPainter())),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 7),
            decoration: BoxDecoration(
              color: App15Theme.paper,
              border: Border.all(color: App15Theme.ink, width: 2),
              borderRadius: BorderRadius.circular(19),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(size.width, 0)
          ..lineTo(0, size.height / 2)
          ..lineTo(size.width, size.height);
    canvas.drawPath(path, Paint()..color = App15Theme.ink);
    final inner =
        Path()
          ..moveTo(size.width + 2, 4)
          ..lineTo(4, size.height / 2)
          ..lineTo(size.width + 2, size.height - 4);
    canvas.drawPath(inner, Paint()..color = App15Theme.paper);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AudioPrompt extends StatelessWidget {
  final bool playing;
  final bool played;
  final VoidCallback onTap;

  const _AudioPrompt({required this.playing, required this.played, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title =
        playing
            ? '正在播放…'
            : played
            ? '再听一遍'
            : '播放英文';
    final hint =
        playing
            ? '正在播放…'
            : played
            ? '点这里再听一遍'
            : '听完选出对应的图片';

    return Semantics(
      button: true,
      label: '播放英文',
      child: ExcludeSemantics(
        child: GestureDetector(
          key: const ValueKey('quiz-audio-prompt'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: App15Theme.yellowPale,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: App15Theme.ink, width: 2),
              boxShadow: const [BoxShadow(color: App15Theme.yellowDark, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: App15Theme.paper,
                    shape: BoxShape.circle,
                    border: Border.all(color: App15Theme.ink, width: 2),
                  ),
                  child: Center(child: PipIcon(asset: PipAssets.icon('sound'), size: 23)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: App15Theme.bodyStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w900, height: 1.2)),
                      const SizedBox(height: 3),
                      Text(hint, style: App15Theme.captionStyle.copyWith(fontSize: 12)),
                    ],
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

class _FillQuestion extends StatefulWidget {
  final Question question;
  final RunState run;
  final ValueChanged<String> onSelect;

  const _FillQuestion({required this.question, required this.run, required this.onSelect});

  @override
  State<_FillQuestion> createState() => _FillQuestionState();
}

class _FillQuestionState extends State<_FillQuestion> with SingleTickerProviderStateMixin {
  late final AnimationController _fly = AnimationController(vsync: this);
  final GlobalKey _blankKey = GlobalKey();
  final Map<String, GlobalKey> _wordKeys = {};

  Rect? _sourceRect;
  Offset _flyOffset = Offset.zero;
  double _flyScaleX = 1;
  double _flyScaleY = 1;
  bool _flying = false;

  @override
  void initState() {
    super.initState();
    _fly.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) setState(() => _flying = false);
    });
  }

  @override
  void didUpdateWidget(covariant _FillQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _sourceRect = null;
      _flying = false;
      _fly.reset();
    }

    final becameCorrect = oldWidget.run.feedback != AnswerFeedback.correct && widget.run.feedback == AnswerFeedback.correct;
    if (!becameCorrect || PipMotionSpec.of(context).reduceMotion) return;

    final box = _wordKeys[widget.run.selection]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || box.size.isEmpty) return;
    _sourceRect = box.localToGlobal(Offset.zero) & box.size;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startFlight());
  }

  void _startFlight() {
    final blankBox = _blankKey.currentContext?.findRenderObject() as RenderBox?;
    final source = _sourceRect;
    _sourceRect = null;
    if (!mounted || source == null || blankBox == null || !blankBox.attached || blankBox.size.isEmpty) return;

    final destination = blankBox.localToGlobal(Offset.zero);
    setState(() {
      _flyOffset = source.topLeft - destination;
      _flyScaleX = source.width / blankBox.size.width;
      _flyScaleY = source.height / blankBox.size.height;
      _flying = true;
    });
    _fly.duration = PipMotionSpec.of(context).wordFly;
    _fly.forward(from: 0);
  }

  @override
  void dispose() {
    _fly.dispose();
    super.dispose();
  }

  GlobalKey _wordKey(String word) => _wordKeys.putIfAbsent(word, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Sentence(
          question: widget.question,
          run: widget.run,
          blankKey: _blankKey,
          flight: _fly,
          flying: _flying,
          flightOffset: _flyOffset,
          flightScaleX: _flyScaleX,
          flightScaleY: _flyScaleY,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 13) / 2;
            return Wrap(
              spacing: 13,
              runSpacing: 14,
              children: [
                for (final word in widget.question.words)
                  SizedBox(
                    width: width,
                    child:
                        widget.run.feedback == AnswerFeedback.correct && widget.run.selection == word
                            ? const _EmptyWordSlot()
                            : _WordButton(
                              key: _wordKey(word),
                              word: word,
                              selected: widget.run.selection == word,
                              enabled: widget.run.feedback == AnswerFeedback.none,
                              onTap: () => widget.onSelect(word),
                            ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Sentence extends StatelessWidget {
  final Question question;
  final RunState run;
  final GlobalKey? blankKey;
  final Animation<double>? flight;
  final bool flying;
  final Offset flightOffset;
  final double flightScaleX;
  final double flightScaleY;

  const _Sentence({
    required this.question,
    required this.run,
    this.blankKey,
    this.flight,
    this.flying = false,
    this.flightOffset = Offset.zero,
    this.flightScaleX = 1,
    this.flightScaleY = 1,
  });

  @override
  Widget build(BuildContext context) {
    final selected = run.selection;
    final correct = run.feedback == AnswerFeedback.correct;
    final wrong = run.feedback == AnswerFeedback.wrong;
    final filled = selected.isNotEmpty;
    final semantics = '${question.first} ${question.prefix} ${selected.isEmpty ? '空白' : selected} ${question.suffix}';

    Widget blank = Transform.rotate(
      angle: filled ? -3 * math.pi / 180 : 0,
      child: Container(
        key: const ValueKey('quiz-blank'),
        constraints: const BoxConstraints(minWidth: 88),
        height: 47,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration:
            filled
                ? BoxDecoration(
                  color: wrong ? App15Theme.wrongSelected : App15Theme.yellow,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: App15Theme.ink, width: 2),
                  boxShadow: [BoxShadow(color: wrong ? App15Theme.wrongBorder : App15Theme.yellowDark, offset: const Offset(0, 4))],
                )
                : const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFB7B9AD), width: 3))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filled ? selected : '···',
              style: App15Theme.sentenceStyle.copyWith(fontSize: 26, height: 1, color: filled ? App15Theme.ink : App15Theme.muted),
            ),
            if (correct) ...[const SizedBox(width: 5), const PipIcon(asset: 'assets/images/15/icons/check.svg', size: 18)],
          ],
        ),
      ),
    );

    if (blankKey != null) {
      blank = KeyedSubtree(key: blankKey, child: blank);
    }

    final flightAnimation = flight;
    if (flightAnimation != null) {
      blank = AnimatedBuilder(
        animation: flightAnimation,
        builder: (context, child) {
          if (!flying) return child!;
          final progress = Curves.easeOutCubic.transform(flightAnimation.value);
          return Transform.translate(
            offset: Offset(flightOffset.dx * (1 - progress), flightOffset.dy * (1 - progress)),
            child: Transform.scale(
              scaleX: flightScaleX + (1 - flightScaleX) * progress,
              scaleY: flightScaleY + (1 - flightScaleY) * progress,
              alignment: Alignment.topLeft,
              child: child,
            ),
          );
        },
        child: blank,
      );
    }

    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.first.isNotEmpty)
              Text(question.first, key: const ValueKey('quiz-sentence-first'), style: App15Theme.sentenceStyle),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (question.prefix.isNotEmpty) ...[Text(question.prefix, style: App15Theme.sentenceStyle), const SizedBox(width: 7)],
                blank,
                if (question.suffix.isNotEmpty)
                  Text(question.suffix, key: const ValueKey('quiz-sentence-suffix'), style: App15Theme.sentenceStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WordButton extends StatelessWidget {
  final String word;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _WordButton({super.key, required this.word, required this.selected, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textColor =
        enabled
            ? App15Theme.ink
            : selected
            ? App15Theme.ink
            : App15Theme.disabledText;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: word,
      child: ExcludeSemantics(
        child: GestureDetector(
          key: ValueKey('quiz-word-$word'),
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 53,
            decoration: BoxDecoration(
              color: selected ? App15Theme.yellowSelected : App15Theme.paper,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? App15Theme.yellowDark : App15Theme.neutralBorder, width: 2),
              boxShadow: [BoxShadow(color: selected ? App15Theme.yellowDark : App15Theme.neutralShadow, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    word,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: App15Theme.bodyStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w800, color: textColor, height: 1),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 5),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(color: App15Theme.ink, shape: BoxShape.circle),
                    child: Center(child: PipIcon(asset: PipAssets.icon('check'), size: 12, color: App15Theme.paper)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyWordSlot extends StatelessWidget {
  const _EmptyWordSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      decoration: BoxDecoration(color: App15Theme.wordSlotFill, borderRadius: BorderRadius.circular(16)),
      child: const CustomPaint(foregroundPainter: _DashedRoundedBorder(color: App15Theme.wordSlotBorder, radius: 16)),
    );
  }
}

class _DashedRoundedBorder extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRoundedBorder({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + 6, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorder oldDelegate) => color != oldDelegate.color || radius != oldDelegate.radius;
}

class _ListenOptions extends StatelessWidget {
  final Question question;
  final RunState run;
  final ValueChanged<String> onSelect;

  const _ListenOptions({required this.question, required this.run, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < question.options.length; index++) ...[
          if (index > 0) const SizedBox(width: 11),
          Expanded(
            child: _ListenOptionCard(
              option: question.options[index],
              selected: run.selection == question.options[index].id,
              feedback: run.feedback,
              onTap: run.feedback == AnswerFeedback.none ? () => onSelect(question.options[index].id) : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _ListenOptionCard extends StatelessWidget {
  final ListenOption option;
  final bool selected;
  final AnswerFeedback feedback;
  final VoidCallback? onTap;

  const _ListenOptionCard({required this.option, required this.selected, required this.feedback, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final correct = feedback == AnswerFeedback.correct;
    final wrong = feedback == AnswerFeedback.wrong;
    final wrongSelection = selected && wrong;
    final disabled = feedback != AnswerFeedback.none;

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.fromLTRB(7, 13, 7, 11),
      decoration: BoxDecoration(
        color:
            wrongSelection
                ? App15Theme.wrongSelected
                : selected
                ? App15Theme.yellowSelected
                : App15Theme.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              wrongSelection
                  ? App15Theme.wrongBorder
                  : selected
                  ? App15Theme.yellowDark
                  : App15Theme.neutralBorder,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                wrongSelection
                    ? App15Theme.wrongBorder
                    : selected
                    ? App15Theme.yellowDark
                    : App15Theme.neutralShadow,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 66, height: 66, child: Padding(padding: const EdgeInsets.all(4), child: _OptionArt(art: option.art))),
              const SizedBox(height: 7),
              Text(option.label, style: App15Theme.bodyStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w900, height: 1.1)),
              const SizedBox(height: 3),
              Text(
                option.sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: App15Theme.captionStyle.copyWith(fontSize: 11, height: 1),
              ),
            ],
          ),
          if (selected && correct)
            const Positioned(
              top: -6,
              right: -6,
              child: _OptionMark(icon: 'check', background: App15Theme.ink, foreground: App15Theme.paper),
            ),
          if (wrongSelection)
            const Positioned(
              top: -6,
              right: -6,
              child: _OptionMark(icon: 'close', background: App15Theme.wrongBorder, foreground: App15Theme.paper),
            ),
        ],
      ),
    );

    if (disabled && !selected) card = Opacity(opacity: 0.55, child: card);

    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      label: '${option.label}，${option.sub}',
      child: ExcludeSemantics(
        child: GestureDetector(key: ValueKey('quiz-option-${option.id}'), behavior: HitTestBehavior.opaque, onTap: onTap, child: card),
      ),
    );
  }
}

class _OptionArt extends StatelessWidget {
  final String art;

  const _OptionArt({required this.art});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(PipAssets.option(art), fit: BoxFit.contain);
  }
}

class _OptionMark extends StatelessWidget {
  final String icon;
  final Color background;
  final Color foreground;

  const _OptionMark({required this.icon, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle, border: Border.all(color: App15Theme.paper, width: 2)),
      child: Center(child: PipIcon(asset: PipAssets.icon(icon), size: 13, color: foreground)),
    );
  }
}

class _QuizFooter extends StatelessWidget {
  final RunState run;
  final Question question;
  final Lesson lesson;
  final int lives;
  final VoidCallback onCheck;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  const _QuizFooter({
    required this.run,
    required this.question,
    required this.lesson,
    required this.lives,
    required this.onCheck,
    required this.onRetry,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (run.feedback == AnswerFeedback.correct) {
      final last = run.qIndex == lesson.questions.length - 1;
      final nextLabel = last ? (lesson.id == 'challenge' ? '查看挑战结果' : '查看本课成果') : '继续下一题';
      return _FeedbackPanel(
        correct: true,
        title: '答对了！',
        copy: question.explain,
        actionLabel: nextLabel,
        actionOnPressed: onNext,
        trailingIcon: 'arrow',
        streak: run.streak,
      );
    }
    if (run.feedback == AnswerFeedback.wrong) {
      return _FeedbackPanel(
        correct: false,
        title: '差一点，再试试',
        copy: '${question.explain}。把这个说法记住！',
        actionLabel: lives == 0 ? '补满生命，再试一次' : '再选一次',
        actionOnPressed: onRetry,
        trailingIcon: 'review',
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 19, 24, 20),
      decoration: const BoxDecoration(color: App15Theme.paper, border: Border(top: BorderSide(color: App15Theme.line, width: 2))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PipPrimaryButton(
            key: const ValueKey('quiz-check'),
            label: '检查答案',
            onPressed: run.selection.isEmpty ? null : onCheck,
            trailing: PipIcon(asset: PipAssets.icon('arrow'), size: 21),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 18,
            child: Text(
              run.selection.isEmpty ? '选一个答案，补全这道题。' : '',
              key: const ValueKey('quiz-hint'),
              style: App15Theme.captionStyle.copyWith(fontSize: 13, color: App15Theme.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final bool correct;
  final String title;
  final String copy;
  final String actionLabel;
  final VoidCallback actionOnPressed;
  final String trailingIcon;
  final int streak;

  const _FeedbackPanel({
    required this.correct,
    required this.title,
    required this.copy,
    required this.actionLabel,
    required this.actionOnPressed,
    required this.trailingIcon,
    this.streak = 0,
  });

  @override
  Widget build(BuildContext context) {
    final motion = PipMotionSpec.of(context);
    final background = correct ? App15Theme.mint : App15Theme.wrongFooter;
    final icon = correct ? 'check' : 'close';

    final panel = Container(
      constraints: const BoxConstraints(minHeight: 219),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: background,
        border: const Border(
          top: BorderSide(color: App15Theme.ink, width: 2),
          left: BorderSide(color: App15Theme.ink, width: 2),
          right: BorderSide(color: App15Theme.ink, width: 2),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (correct && streak >= 2) Align(alignment: Alignment.centerRight, child: _ComboBadge(streak: streak)),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: correct ? App15Theme.ink : App15Theme.wrongBorder, shape: BoxShape.circle),
                child: Center(child: PipIcon(asset: PipAssets.icon(icon), size: 17, color: App15Theme.paper)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  key: ValueKey(correct ? 'quiz-feedback-correct' : 'quiz-feedback-wrong'),
                  style: App15Theme.bodyStyle.copyWith(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -0.7, height: 1.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 39),
            child: Text(
              copy,
              style: App15Theme.bodyStyle.copyWith(fontSize: correct ? 17 : 15, fontWeight: FontWeight.w800, height: correct ? 1.5 : 1.4),
            ),
          ),
          const SizedBox(height: 14),
          PipPrimaryButton(
            key: ValueKey(correct ? 'quiz-next' : 'quiz-retry'),
            label: actionLabel,
            height: 58,
            trailing: PipIcon(asset: PipAssets.icon(trailingIcon), size: 21),
            onPressed: actionOnPressed,
          ),
        ],
      ),
    );

    return Semantics(
      liveRegion: true,
      label: '$title。$copy',
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: motion.reduceMotion ? 1 : 0, end: 1),
          duration: motion.feedbackRise,
          curve: Curves.easeOut,
          builder:
              (context, value, child) =>
                  Opacity(opacity: 0.65 + 0.35 * value, child: Transform.translate(offset: Offset(0, 14 * (1 - value)), child: child)),
          child: Stack(clipBehavior: Clip.none, children: [panel, if (correct) const Positioned(right: 24, top: -62, child: _CheerBird())]),
        ),
      ),
    );
  }
}

class _ComboBadge extends StatelessWidget {
  final int streak;

  const _ComboBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: PipMotionSpec.of(context).comboPop,
      builder: (context, value, child) {
        final peak = value < 0.65 ? value / 0.65 : (1 - value) / 0.35;
        final scale = value < 0.65 ? 0.88 + 0.16 * peak : 1.04 - 0.04 * ((value - 0.65) / 0.35);
        return Transform.rotate(angle: (5 + 2 * peak) * math.pi / 180, child: Transform.scale(scale: scale, child: child));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: App15Theme.ink, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PipIcon(asset: PipAssets.icon('bolt'), size: 15, color: App15Theme.yellow),
            const SizedBox(width: 4),
            Text('$streak 连击', style: App15Theme.captionStyle.copyWith(color: App15Theme.paper, fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _CheerBird extends StatelessWidget {
  const _CheerBird();

  @override
  Widget build(BuildContext context) {
    const bird = IgnorePointer(child: PipBird(asset: 'assets/images/15/bird_celebrate.svg', width: 106, height: 118, rotationDegrees: -2));
    final motion = PipMotionSpec.of(context);
    if (motion.reduceMotion) return bird;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: motion.cheer,
      builder: (context, value, child) {
        final double translateY;
        final double degrees;
        final double scale;
        final double opacity;
        if (value < 0.4) {
          final k = value / 0.4;
          translateY = 24 - 34 * k;
          degrees = 4 - 16 * k;
          scale = 0.86 + 0.2 * k;
          opacity = k;
        } else {
          final k = (value - 0.4) / 0.6;
          translateY = -10 + 10 * k;
          degrees = -12 + 10 * k;
          scale = 1.06 - 0.06 * k;
          opacity = 1;
        }
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.rotate(angle: (degrees + 2) * math.pi / 180, child: Transform.scale(scale: scale, child: child)),
          ),
        );
      },
      child: bird,
    );
  }
}
