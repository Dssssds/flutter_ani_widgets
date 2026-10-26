import 'dart:ui' show Rect;
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_x_widgets/app_demo/16/models/app_screen.dart';
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';
import 'package:flutter_x_widgets/app_demo/16/models/placed_item.dart';
import 'package:flutter_x_widgets/app_demo/16/models/repositories/diary_repository.dart';
import 'package:flutter_x_widgets/app_demo/16/models/repositories/seed_repository.dart';
import 'package:flutter_x_widgets/app_demo/16/models/rules/diary_rules.dart';
import 'package:flutter_x_widgets/app_demo/16/models/services/clock.dart';
import 'package:flutter_x_widgets/app_demo/16/models/services/photo_service.dart';
import 'package:flutter_x_widgets/app_demo/16/widgets/motion/app_16_motion_spec.dart';
import 'package:uuid/uuid.dart';

class FlyingRequest {
  const FlyingRequest({
    required this.item,
    required this.from,
    required this.target,
  });

  final PlacedItem item;
  final Rect from;
  final Rect target;
}

class DiaryController extends ChangeNotifier {
  DiaryController({
    required this.repository,
    required this.seeds,
    required this.photos,
    DateTime? today,
  }) : today = today ?? AppClock.today;

  final DiaryRepository repository;
  final SeedRepository seeds;
  final PhotoService photos;
  final DateTime today;

  bool loading = true;
  String loadError = '';
  bool _initializing = false;
  bool _disposed = false;

  AppScreen screen = AppScreen.journal;
  MaterialCategory category = MaterialCategory.sticker;
  MaterialItem? selectedMaterial;
  Rect? selectedMaterialRect;

  late MaterialCatalog catalog;
  late DiaryEntry entry;
  final List<DiaryEntry> history = <DiaryEntry>[];
  bool saved = false;
  bool saving = false;
  String saveError = '';

  String toast = '';
  Timer? _toastTimer;

  bool firstEntrance = true;
  bool reduceMotion = false;
  String? flyingId;
  FlyingRequest? flyingRequest;
  PhotoSlot photoSelected = PhotoSlot.none;

  bool editing = false;
  String editTitle = '';
  String editNote = '';

  int viewYear = 2026;
  int viewMonth = 9;
  int selectedDay = 27;

  final Map<String, DiaryEntry> savedEntries = <String, DiaryEntry>{};
  final Map<String, DiaryEntry> seedEntries = <String, DiaryEntry>{};
  final Map<String, _Draft> _draftEntries = <String, _Draft>{};
  final Map<MaterialCategory, MaterialItem> _selectedByCategory =
      <MaterialCategory, MaterialItem>{};

  bool _uploadingPhoto = false;
  final Uuid _uuid = const Uuid();

  Rect? Function()? paperRectProvider;

  bool get ready => !loading && loadError.isEmpty;

  Future<void> initialize() async {
    if (_initializing || !loading) {
      return;
    }
    _initializing = true;
    try {
      final seed = await seeds.load();
      final stored = await repository.load();
      catalog = seed.catalog;
      seedEntries
        ..clear()
        ..addAll(seed.entries);
      savedEntries
        ..clear()
        ..addAll(stored);

      final todayKey = entryKey(today.year, today.month, today.day);
      final initial = savedEntries[todayKey] ?? seedEntries[todayKey];
      entry = (initial ?? DiaryRules.defaultEntry(today)).deepCopy();
      saved = savedEntries.containsKey(todayKey);

      for (final category in MaterialCategory.values) {
        final items = catalog.itemsFor(category);
        if (items.isNotEmpty) {
          _selectedByCategory[category] = items.first;
        }
      }
      selectedMaterial = _selectedByCategory[MaterialCategory.sticker];

      if (AppClock.useRealDate) {
        viewYear = today.year;
        viewMonth = today.month;
        selectedDay = today.day;
      } else {
        viewYear = 2026;
        viewMonth = 9;
        selectedDay = 27;
      }

      loading = false;
      loadError = '';
    } on Object {
      loading = false;
      loadError = '这一页暂时打不开，请重新进入。';
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void consumeFirstEntrance() {
    firstEntrance = false;
  }

  void goJournal() {
    if (screen == AppScreen.journal) {
      return;
    }
    screen = AppScreen.journal;
    _notify();
  }

  void openDrawer(MaterialCategory next) {
    category = next;
    selectedMaterial = _selectedByCategory[next] ?? _firstItemOf(next);
    screen = AppScreen.drawer;
    _notify();
  }

  void selectCategory(MaterialCategory next) {
    if (category == next) {
      return;
    }
    category = next;
    selectedMaterial = _selectedByCategory[next] ?? _firstItemOf(next);
    selectedMaterialRect = null;
    _notify();
  }

  void selectMaterial(MaterialItem item, Rect? rect) {
    selectedMaterial = item;
    selectedMaterialRect = rect;
    _selectedByCategory[category] = item;
    _notify();
  }

  MaterialItem? _firstItemOf(MaterialCategory category) {
    final items = catalog.itemsFor(category);
    return items.isEmpty ? null : items.first;
  }

  void goMonth() {
    if (screen == AppScreen.month) {
      return;
    }
    screen = AppScreen.month;
    _notify();
  }

  void toggleMood() {
    snapshot();
    entry = entry.copyWith(mood: entry.mood == '好心情' ? '被治愈了' : '好心情');
    _notify();
  }

  void openEditor() {
    editing = true;
    editTitle = entry.title;
    editNote = entry.note;
    _notify();
  }

  void cancelEditor() {
    if (!editing) {
      return;
    }
    editing = false;
    _notify();
  }

  bool applyEditor() {
    return applyText(editTitle, editNote);
  }

  bool applyText(String title, String note) {
    final trimmedTitle = title.trim();
    final trimmedNote = note.trim();
    if (trimmedTitle.isEmpty || trimmedNote.isEmpty) {
      return false;
    }
    snapshot();
    entry = entry.copyWith(title: trimmedTitle, note: trimmedNote);
    editing = false;
    _notify();
    return true;
  }

  void snapshot() {
    history.add(entry.deepCopy());
    if (history.length > DiaryRules.undoLimit) {
      history.removeAt(0);
    }
    saved = false;
    saveError = '';
  }

  void undo() {
    if (history.isEmpty) {
      return;
    }
    entry = history.removeLast();
    saved = false;
    showToast('已撤销上一次修改');
  }

  Future<void> saveEntry() async {
    if (saving) {
      return;
    }
    saving = true;
    saveError = '';
    _notify();
    final snapshotEntry = entry.deepCopy();
    final next = <String, DiaryEntry>{
      ...savedEntries,
      snapshotEntry.key: snapshotEntry,
    };
    try {
      await repository.save(next);
      savedEntries[snapshotEntry.key] = snapshotEntry;
      saved = true;
      saving = false;
      showToast('这一页，收好了');
    } on Object {
      saved = false;
      saving = false;
      saveError = '这一页没能保存，内容还在。请腾出一些空间后再试。';
      _notify();
    }
  }

  Future<void> uploadPhoto() async {
    if (_uploadingPhoto || saving) {
      return;
    }
    _uploadingPhoto = true;
    try {
      final path = await photos.pickAndStore();
      if (path == null) {
        return;
      }
      final defaults = catalog.uploadedPhotoDefault;
      final item = PlacedItem(
        id: _uuid.v4(),
        kind: MaterialKind.photo,
        name: '新照片',
        src: path,
        x: defaults.x,
        y: defaults.y,
        rotation: defaults.rotation,
      );
      snapshot();
      entry = entry.copyWith(items: <PlacedItem>[...entry.items, item]);
      showToast('照片已放好，按住可以移动');
    } on PhotoPickFailure catch (error) {
      showToast(error.message);
    } finally {
      _uploadingPhoto = false;
    }
  }

  void pasteMaterial(MaterialItem material, {Rect? fromRect}) {
    final defaults = catalog.defaultFor(material.kind);
    final item = PlacedItem(
      id: _uuid.v4(),
      kind: material.kind,
      name: material.name,
      src: material.src,
      tapeStyle: material.tapeStyle,
      text: material.text,
      color: material.color,
      x: defaults.x,
      y: defaults.y,
      rotation: defaults.rotation,
    );
    snapshot();
    entry = entry.copyWith(items: <PlacedItem>[...entry.items, item]);
    screen = AppScreen.journal;

    Rect? target;
    final paperRect = paperRectProvider?.call();
    if (material.kind == MaterialKind.sticker &&
        !reduceMotion &&
        fromRect != null &&
        paperRect != null) {
      target = Rect.fromLTWH(
        paperRect.left + item.x * paperRect.width,
        paperRect.top + item.y * paperRect.height,
        83,
        83,
      );
    }

    if (target != null) {
      flyingId = item.id;
      flyingRequest = FlyingRequest(
        item: item,
        from: fromRect!,
        target: target,
      );
    } else {
      flyingId = null;
      flyingRequest = null;
      _showToastNow('已贴上，按住可以移动');
    }
    _notify();
  }

  void finishFlying() {
    if (flyingRequest == null && flyingId == null) {
      return;
    }
    flyingRequest = null;
    flyingId = null;
    _showToastNow('已贴上，按住可以移动');
  }

  void selectPhoto(PhotoSlot slot) {
    if (photoSelected == slot) {
      return;
    }
    photoSelected = slot;
    _notify();
  }

  void clearPhotoSelection() {
    if (photoSelected == PhotoSlot.none) {
      return;
    }
    photoSelected = PhotoSlot.none;
    _notify();
  }

  void movePhoto(PhotoSlot slot, double x, double y) {
    if (slot == PhotoSlot.none) {
      return;
    }
    entry =
        slot == PhotoSlot.main
            ? entry.copyWith(mainX: x, mainY: y)
            : entry.copyWith(sideX: x, sideY: y);
    _notify();
  }

  void movePlaced(String id, double x, double y) {
    final next = entry.items
        .map((item) => item.id == id ? item.copyWith(x: x, y: y) : item)
        .toList(growable: false);
    entry = entry.copyWith(items: next);
    _notify();
  }

  void loadEntry(int year, int month, int day) {
    final previousKey = entry.key;
    _draftEntries[previousKey] = _Draft(entry.deepCopy(), saved);

    final targetDate = DateTime(year, month, day);
    final key = entryKey(year, month, day);
    final draft = _draftEntries[key];
    if (draft != null) {
      entry = draft.entry.deepCopy();
      saved = draft.saved;
    } else if (savedEntries.containsKey(key)) {
      entry = savedEntries[key]!.deepCopy();
      saved = true;
    } else if (seedEntries.containsKey(key)) {
      entry = seedEntries[key]!.deepCopy();
      saved = false;
    } else {
      entry = DiaryRules.defaultEntry(targetDate);
      saved = false;
    }
    history.clear();
    saveError = '';
    photoSelected = PhotoSlot.none;
    editing = false;
    screen = AppScreen.journal;
    _notify();
  }

  void openDate(int year, int month, int day) {
    loadEntry(year, month, day);
  }

  void goToday() {
    loadEntry(today.year, today.month, today.day);
  }

  Map<int, DiaryEntry> entriesForMonth(int year, int month) {
    final prefix =
        '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-';
    final result = <int, DiaryEntry>{};
    for (final item in seedEntries.entries) {
      if (item.key.startsWith(prefix)) {
        result[item.value.day] = item.value;
      }
    }
    for (final item in savedEntries.entries) {
      if (item.key.startsWith(prefix)) {
        result[item.value.day] = item.value;
      }
    }
    return result;
  }

  int entryCountForMonth(int year, int month) {
    return entriesForMonth(year, month).length;
  }

  DiaryEntry? entryForDate(int year, int month, int day) {
    final key = entryKey(year, month, day);
    return savedEntries[key] ?? seedEntries[key];
  }

  DiaryEntry? get selectedEntry =>
      entryForDate(viewYear, viewMonth, selectedDay);

  void selectDay(int day) {
    final date = DateTime(viewYear, viewMonth, day);
    if (DiaryRules.isFuture(date, today)) {
      return;
    }
    selectedDay = day;
    _notify();
  }

  bool canGoNextMonth() {
    final currentYear = today.year;
    final currentMonth = today.month;
    return viewYear < currentYear ||
        (viewYear == currentYear && viewMonth < currentMonth);
  }

  void previousMonth() {
    final nextMonth = viewMonth == 1 ? 12 : viewMonth - 1;
    final nextYear = viewMonth == 1 ? viewYear - 1 : viewYear;
    _setMonth(nextYear, nextMonth);
  }

  void nextMonth() {
    if (!canGoNextMonth()) {
      return;
    }
    final nextMonth = viewMonth == 12 ? 1 : viewMonth + 1;
    final nextYear = viewMonth == 12 ? viewYear + 1 : viewYear;
    _setMonth(nextYear, nextMonth);
  }

  void _setMonth(int year, int month) {
    viewYear = year;
    viewMonth = month;
    final entries = entriesForMonth(year, month);
    selectedDay =
        entries.isEmpty
            ? 1
            : entries.keys.reduce((left, right) => left > right ? left : right);
    _notify();
  }

  bool isFutureDay(int day) {
    return DiaryRules.isFuture(DateTime(viewYear, viewMonth, day), today);
  }

  void showToast(String message) {
    if (_disposed) {
      return;
    }
    _showToastNow(message);
    _notify();
  }

  void _showToastNow(String message) {
    if (_disposed) {
      return;
    }
    _toastTimer?.cancel();
    toast = message;
    _toastTimer = Timer(App16MotionSpec.toast, () {
      toast = '';
      _toastTimer = null;
      _notify();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _toastTimer?.cancel();
    super.dispose();
  }
}

class _Draft {
  const _Draft(this.entry, this.saved);

  final DiaryEntry entry;
  final bool saved;
}
