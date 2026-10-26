import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_icon.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/common/app_16_pressable.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/drawer/material_cover.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/drawer/material_tile.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/motion/app_16_motion_spec.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/app_16_theme.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/theme/design_tokens.dart';

class MaterialDrawerScreen extends StatelessWidget {
  const MaterialDrawerScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    final catalog = controller.catalog;
    final category = controller.category;
    final items = catalog.itemsFor(category);
    final info = catalog.infoFor(category);
    final coverHeight = metrics.narrow ? 177.0 : 108.0;
    final imageHeight = metrics.narrow ? 103.0 : 106.0;

    return Column(
      children: <Widget>[
        _DrawerHeader(controller: controller),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _MaterialTabs(controller: controller),
                const SizedBox(height: 12),
                MaterialCover(
                  category: category,
                  catalog: catalog,
                  height: coverHeight,
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        info.sectionTitle,
                        style: App16Typography.sectionLabel,
                      ),
                    ),
                    Text(
                      '${items.length} ${info.unit}',
                      style: App16Typography.helper,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: metrics.narrow ? 9 : 12,
                    mainAxisSpacing: metrics.narrow ? 14 : 15,
                    mainAxisExtent: metrics.narrow ? 137 : 140,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return MaterialTile(
                      key: ValueKey<String>(item.id),
                      item: item,
                      imageHeight: imageHeight,
                      selected: controller.selectedMaterial?.id == item.id,
                      onSelect: controller.selectMaterial,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: metrics.navTotalHeight),
          child: _SelectionTray(controller: controller),
        ),
      ],
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    return SizedBox(
      height: metrics.headerHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, metrics.short ? 6 : 8, 22, 8),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text('素材抽屉', style: App16Typography.screenTitle),
            ),
            App16Pressable(
              onTap: controller.goJournal,
              semanticLabel: '返回手账',
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(child: App16Icon(name: 'i-close', size: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialTabs extends StatelessWidget {
  const _MaterialTabs({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    const categories = MaterialCategory.values;
    final currentIndex = categories.indexOf(controller.category);
    final duration = App16MotionSpec.motion(context, App16MotionSpec.tab);
    return SizedBox(
      height: 45,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: App16Colors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / categories.length;
            return Stack(
              children: <Widget>[
                AnimatedPositioned(
                  duration: duration,
                  curve: App16MotionSpec.tabCurve,
                  left: currentIndex * itemWidth,
                  top: 0,
                  width: itemWidth,
                  height: 37,
                  child: Container(
                    decoration: BoxDecoration(
                      color: App16Colors.selected,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x0F704458),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: categories
                      .map((category) {
                        final active = controller.category == category;
                        return Expanded(
                          child: App16Pressable(
                            onTap: () => controller.selectCategory(category),
                            semanticLabel: category.label,
                            selected: active,
                            minSize: 37,
                            child: Center(
                              child: Text(
                                category.label,
                                style: App16Typography.materialTab.copyWith(
                                  color:
                                      active
                                          ? App16Colors.berry
                                          : App16Colors.muted,
                                  fontWeight:
                                      active
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SelectionTray extends StatelessWidget {
  const _SelectionTray({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final metrics = App16Metrics.of(context);
    final material = controller.selectedMaterial;
    final preview =
        material == null
            ? const SizedBox.shrink()
            : FittedBox(
              fit: BoxFit.scaleDown,
              child: MaterialPreview(
                item: material,
                width: 45,
                height: 45,
                noteColor: app16Color(
                  controller.catalog.noteTrayColor,
                  const Color(0xFFF3DEB2),
                ),
                photoPadding: 2,
              ),
            );

    return Container(
      height: metrics.trayHeight,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: App16Colors.line, width: 0.5)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 45, height: 45, child: preview),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              material?.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: App16Colors.ink),
            ),
          ),
          const SizedBox(width: 10),
          App16Pressable(
            key: const ValueKey<String>('app16-paste'),
            onTap:
                material == null
                    ? null
                    : () => controller.pasteMaterial(
                      material,
                      fromRect: controller.selectedMaterialRect,
                    ),
            semanticLabel: '贴到手账',
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 17),
              decoration: BoxDecoration(
                color: App16Colors.berry,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '贴到手账',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  App16Icon(name: 'i-chevron', size: 17, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
