import 'dart:ui' show Size;

enum MaterialCategory { sticker, tape, note, photo }

enum MaterialKind { sticker, tape, note, photo }

extension MaterialCategoryX on MaterialCategory {
  MaterialKind get kind {
    switch (this) {
      case MaterialCategory.sticker:
        return MaterialKind.sticker;
      case MaterialCategory.tape:
        return MaterialKind.tape;
      case MaterialCategory.note:
        return MaterialKind.note;
      case MaterialCategory.photo:
        return MaterialKind.photo;
    }
  }

  String get label {
    switch (this) {
      case MaterialCategory.sticker:
        return '贴纸';
      case MaterialCategory.tape:
        return '胶带';
      case MaterialCategory.note:
        return '便签';
      case MaterialCategory.photo:
        return '照片';
    }
  }
}

MaterialKind materialKindFromName(String? value) {
  return MaterialKind.values.firstWhere(
    (kind) => kind.name == value,
    orElse: () => MaterialKind.sticker,
  );
}

MaterialCategory materialCategoryFromName(String? value) {
  return MaterialCategory.values.firstWhere(
    (category) => category.name == value,
    orElse: () => MaterialCategory.sticker,
  );
}

class MaterialItem {
  const MaterialItem({
    required this.id,
    required this.name,
    required this.kind,
    this.src,
    this.tapeStyle,
    this.text,
    this.color,
  });

  final String id;
  final String name;
  final MaterialKind kind;
  final String? src;
  final String? tapeStyle;
  final String? text;
  final String? color;

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as String? ?? 'material',
      name: json['name'] as String? ?? '素材',
      kind: materialKindFromName(json['kind'] as String?),
      src: json['src'] as String?,
      tapeStyle: json['style'] as String? ?? json['tapeStyle'] as String?,
      text: json['text'] as String?,
      color: json['color'] as String?,
    );
  }
}

class MaterialCategoryInfo {
  const MaterialCategoryInfo({
    required this.category,
    required this.label,
    required this.coverTitle,
    required this.coverSubtitle,
    required this.sectionTitle,
    required this.unit,
  });

  final MaterialCategory category;
  final String label;
  final String coverTitle;
  final String coverSubtitle;
  final String sectionTitle;
  final String unit;

  factory MaterialCategoryInfo.fromJson(Map<String, dynamic> json) {
    return MaterialCategoryInfo(
      category: materialCategoryFromName(json['id'] as String?),
      label: json['label'] as String? ?? '贴纸',
      coverTitle: json['coverTitle'] as String? ?? '',
      coverSubtitle: json['coverSubtitle'] as String? ?? '',
      sectionTitle: json['sectionTitle'] as String? ?? '',
      unit: json['unit'] as String? ?? '枚',
    );
  }
}

class PasteDefault {
  const PasteDefault({
    required this.x,
    required this.y,
    required this.rotation,
  });

  final double x;
  final double y;
  final double rotation;

  factory PasteDefault.fromJson(Map<String, dynamic> json) {
    return PasteDefault(
      x: (json['x'] as num?)?.toDouble() ?? 0.5,
      y: (json['y'] as num?)?.toDouble() ?? 0.5,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MaterialCatalog {
  const MaterialCatalog({
    required this.categories,
    required this.itemsByCategory,
    required this.pasteDefaults,
    required this.uploadedPhotoDefault,
    required this.sizes,
    required this.noteTrayColor,
  });

  final List<MaterialCategoryInfo> categories;
  final Map<MaterialCategory, List<MaterialItem>> itemsByCategory;
  final Map<MaterialKind, PasteDefault> pasteDefaults;
  final PasteDefault uploadedPhotoDefault;
  final Map<MaterialKind, Size> sizes;
  final String noteTrayColor;

  List<MaterialItem> itemsFor(MaterialCategory category) =>
      itemsByCategory[category] ?? const <MaterialItem>[];

  MaterialCategoryInfo infoFor(MaterialCategory category) {
    return categories.firstWhere(
      (info) => info.category == category,
      orElse:
          () => const MaterialCategoryInfo(
            category: MaterialCategory.sticker,
            label: '贴纸',
            coverTitle: '',
            coverSubtitle: '',
            sectionTitle: '',
            unit: '枚',
          ),
    );
  }

  Size sizeFor(MaterialKind kind) {
    return sizes[kind] ?? const Size(108, 90);
  }

  PasteDefault defaultFor(MaterialKind kind) {
    return pasteDefaults[kind] ??
        const PasteDefault(x: 0.5, y: 0.5, rotation: -9);
  }

  factory MaterialCatalog.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MaterialCategoryInfo.fromJson)
        .toList(growable: false);

    final itemsByCategory = <MaterialCategory, List<MaterialItem>>{
      for (final category in MaterialCategory.values)
        category: <MaterialItem>[],
    };
    for (final key in const ['stickers', 'tapes', 'notes', 'photos']) {
      final raw = json[key];
      if (raw is! List) {
        continue;
      }
      for (final item in raw.whereType<Map<String, dynamic>>().map(
        MaterialItem.fromJson,
      )) {
        final category = MaterialCategory.values.firstWhere(
          (value) => value.kind == item.kind,
        );
        itemsByCategory[category]!.add(item);
      }
    }

    final pasteDefaults = <MaterialKind, PasteDefault>{};
    var uploadedPhotoDefault = const PasteDefault(
      x: 0.45,
      y: 0.45,
      rotation: 5,
    );
    final rawDefaults = json['pasteDefaults'];
    if (rawDefaults is Map<String, dynamic>) {
      for (final kind in MaterialKind.values) {
        final raw = rawDefaults[kind.name];
        if (raw is Map<String, dynamic>) {
          pasteDefaults[kind] = PasteDefault.fromJson(raw);
        }
      }
      final uploaded = rawDefaults['uploadedPhoto'];
      if (uploaded is Map<String, dynamic>) {
        uploadedPhotoDefault = PasteDefault.fromJson(uploaded);
      }
    }

    final sizes = <MaterialKind, Size>{};
    final rawSizes = json['materialSizes'];
    if (rawSizes is Map<String, dynamic>) {
      for (final kind in MaterialKind.values) {
        final raw = rawSizes[kind.name];
        if (raw is Map<String, dynamic>) {
          sizes[kind] = Size(
            (raw['w'] as num?)?.toDouble() ?? 100,
            (raw['h'] as num?)?.toDouble() ?? 90,
          );
        }
      }
    }

    return MaterialCatalog(
      categories: categories,
      itemsByCategory: itemsByCategory,
      pasteDefaults: pasteDefaults,
      uploadedPhotoDefault: uploadedPhotoDefault,
      sizes: sizes,
      noteTrayColor: json['noteTrayColor'] as String? ?? '#F3DEB2',
    );
  }
}
