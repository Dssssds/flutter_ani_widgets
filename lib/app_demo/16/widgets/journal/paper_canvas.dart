import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/data/asset_manifest.dart';
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_pressable.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/draggable_stamp.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/paper_dot_painter.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/placed_item_view.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/polaroid.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/journal/weather_ticket.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/motion/app_16_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/design_tokens.dart';

class PaperCanvas extends StatefulWidget {
  const PaperCanvas({super.key, required this.controller});

  final DiaryController controller;

  @override
  State<PaperCanvas> createState() => _PaperCanvasState();
}

class _PaperCanvasState extends State<PaperCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  bool _started = false;

  DiaryController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: App16MotionSpec.paperEntrance,
      value: 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion || !controller.firstEntrance) {
      _entrance.value = 1;
    } else {
      _entrance.forward();
    }
    controller.consumeFirstEntrance();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    final paperWidth = metrics.paperWidth;
    final paperHeight = metrics.paperHeight;
    final narrow = metrics.narrow;
    final entry = controller.entry;
    final base = entry.basePhotos;

    final mainWidth = narrow ? paperWidth * 0.62 : 219.0;
    final mainImageHeight = narrow ? 234.0 : 226.0;
    const mainCaptionHeight = 27.0;
    final mainHeight = 8 + mainImageHeight + mainCaptionHeight + 5;
    final sideWidth = narrow ? paperWidth * 0.39 : 139.0;
    const sideImageHeight = 138.0;
    const sideCaptionHeight = 25.0;
    const sideHeight = 6 + sideImageHeight + sideCaptionHeight + 3;

    final selectionText = entry.day.toString().padLeft(2, '0');
    final longNote = DiaryRules.isLongNote(entry.note);

    final paper = SizedBox(
      width: paperWidth,
      height: paperHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: App16Colors.paper,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(9),
                  bottomLeft: Radius.circular(3),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x1069465B),
                    offset: Offset(0, 2),
                    blurRadius: 3,
                  ),
                  BoxShadow(
                    color: Color(0x1269465B),
                    offset: Offset(0, 9),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
          ),
          const Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(3),
                bottomRight: Radius.circular(9),
                bottomLeft: Radius.circular(3),
              ),
              child: CustomPaint(painter: PaperDotPainter()),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.clearPhotoSelection,
            ),
          ),
          ..._holes(),
          if (base)
            Positioned(
              top: 84,
              right: narrow ? paperWidth * 0.04 : 15,
              child: Transform.rotate(
                angle: 6 * math.pi / 180,
                child: const WeatherTicket(),
              ),
            ),
          Positioned(
            left: 25,
            top: 21,
            width: math.min(290, paperWidth - 50),
            child: Text(
              entry.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: App16Typography.handTitle.copyWith(
                fontSize: narrow ? 23 : 25,
              ),
            ),
          ),
          if (base)
            Positioned(
              left: entry.mainX * paperWidth,
              top: entry.mainY * paperHeight,
              child: DraggableStamp(
                position: Offset(entry.mainX, entry.mainY),
                paperSize: Size(paperWidth, paperHeight),
                itemSize: Size(mainWidth, mainHeight),
                rotation: -6,
                selected: controller.photoSelected == PhotoSlot.main,
                onPress: () => controller.selectPhoto(PhotoSlot.main),
                onFirstMove: controller.snapshot,
                onMoved: (x, y) => controller.movePhoto(PhotoSlot.main, x, y),
                child: Polaroid(
                  width: mainWidth,
                  imageHeight: mainImageHeight,
                  src: entry.mainSrc,
                  caption: entry.mainCaption,
                  captionStyle: App16Typography.hand(
                    fontSize: 14,
                    height: mainCaptionHeight / 14,
                    color: App16Colors.captionInk,
                  ),
                ),
              ),
            ),
          _bottomLabel(selectionText),
          Positioned(
            left: narrow ? paperWidth * 0.07 : 29,
            top: base ? 346 : 102,
            width:
                base
                    ? (narrow ? paperWidth * 0.48 : 170)
                    : math.min(paperWidth - 58, 280),
            child:
                longNote
                    ? ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 98),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: _noteText(entry.note, narrow),
                      ),
                    )
                    : _noteText(entry.note, narrow),
          ),
          if (base)
            Positioned(
              left: entry.sideX * paperWidth,
              top: entry.sideY * paperHeight,
              child: DraggableStamp(
                position: Offset(entry.sideX, entry.sideY),
                paperSize: Size(paperWidth, paperHeight),
                itemSize: Size(sideWidth, sideHeight),
                rotation: 7,
                selected: controller.photoSelected == PhotoSlot.side,
                onPress: () => controller.selectPhoto(PhotoSlot.side),
                onFirstMove: controller.snapshot,
                onMoved: (x, y) => controller.movePhoto(PhotoSlot.side, x, y),
                child: Polaroid(
                  width: sideWidth,
                  imageHeight: sideImageHeight,
                  src: entry.sideSrc,
                  caption: entry.sideCaption,
                  captionStyle: App16Typography.hand(
                    fontSize: 12,
                    height: sideCaptionHeight / 12,
                    color: App16Colors.captionInk,
                  ),
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 3),
                  tapeStyle: 'check',
                  tapeWidth: 60,
                  tapeHeight: 22,
                  tapeLeft: 41,
                  tapeRotation: -5,
                ),
              ),
            ),
          ...entry.items.map((item) {
            if (controller.flyingId == item.id) {
              return const SizedBox.shrink();
            }
            final size = controller.catalog.sizeFor(item.kind);
            return Positioned(
              left: item.x * paperWidth,
              top: item.y * paperHeight,
              child: DraggableStamp(
                position: Offset(item.x, item.y),
                paperSize: Size(paperWidth, paperHeight),
                itemSize: size,
                rotation: item.rotation,
                onFirstMove: controller.snapshot,
                onMoved: (x, y) => controller.movePlaced(item.id, x, y),
                child: Semantics(
                  label: '移动${item.name}',
                  child: PlacedItemView(
                    item: item,
                    width: size.width,
                    height: size.height,
                  ),
                ),
              ),
            );
          }),
          const Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(9),
                  bottomLeft: Radius.circular(3),
                ),
                child: Opacity(
                  opacity: 0.18,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(App16Assets.paperGrain),
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.none,
                        alignment: Alignment.topLeft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _entrance,
        child: paper,
        builder: (context, child) {
          final value = Curves.easeOut.transform(_entrance.value);
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 7 * (1 - value)),
              child: Transform.rotate(
                angle: (1 - value) * 0.5 * math.pi / 180,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _holes() {
    return <Widget>[
      for (var index = 0; index < 3; index++)
        Positioned(
          left: -4,
          top: 41 + index * 170,
          child: Container(
            width: 9,
            height: 11,
            decoration: BoxDecoration(
              color: App16Colors.appBg,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
    ];
  }

  Widget _bottomLabel(String dayText) {
    final entry = controller.entry;
    final selected = controller.photoSelected != PhotoSlot.none;
    return Positioned(
      left: 25,
      right: 23,
      bottom: 6,
      height: 44,
      child: Row(
        children: <Widget>[
          if (selected) ...<Widget>[
            const Expanded(
              child: Text(
                '按住照片移动',
                style: TextStyle(fontSize: 12, color: App16Colors.berry),
              ),
            ),
            App16Pressable(
              onTap: controller.clearPhotoSelection,
              semanticLabel: '完成移动照片',
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '完成',
                  style: TextStyle(fontSize: 12, color: App16Colors.berry),
                ),
              ),
            ),
          ] else ...<Widget>[
            const Spacer(),
            Text(
              '${entry.month.toString().padLeft(2, '0')}.$dayText',
              style: App16Typography.number(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _noteText(String note, bool narrow) {
    return Text(
      note,
      style: App16Typography.handBody.copyWith(fontSize: narrow ? 17 : 18),
    );
  }
}
