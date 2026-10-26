import 'dart:convert';
import 'dart:io';

import 'package:flutter_x_widgets/app_demo/16/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/repositories/diary_repository.dart';
import 'package:flutter_x_widgets/app_demo/16/models/repositories/seed_repository.dart';
import 'package:flutter_x_widgets/app_demo/16/models/services/photo_service.dart';
import 'package:flutter_x_widgets/app_demo/16/models/view_models/diary_controller.dart';

Future<SeedData> loadSeedData() async {
  final materials =
      await File('assets/images/16/seed/materials.json').readAsString();
  final entries =
      await File('assets/images/16/seed/entries.json').readAsString();
  return SeedData(
    catalog: AssetSeedRepository.parseMaterials(materials),
    entries: AssetSeedRepository.parseEntries(entries),
  );
}

class StaticSeedRepository implements SeedRepository {
  const StaticSeedRepository(this.data);

  final SeedData data;

  @override
  Future<SeedData> load() async => data;
}

class MemoryDiaryRepository implements DiaryRepository {
  MemoryDiaryRepository([Map<String, DiaryEntry>? initial])
    : entries = <String, DiaryEntry>{...?initial};

  final Map<String, DiaryEntry> entries;
  bool fail = false;
  int saveCount = 0;

  @override
  Future<Map<String, DiaryEntry>> load() async => <String, DiaryEntry>{
    ...entries,
  };

  @override
  Future<void> save(Map<String, DiaryEntry> next) async {
    saveCount++;
    if (fail) {
      throw const FileSystemException('disk full');
    }
    entries
      ..clear()
      ..addAll(next);
  }
}

class FakePhotoService implements PhotoService {
  FakePhotoService({this.nextPath, this.failure = false});

  String? nextPath;
  bool failure;
  int calls = 0;

  @override
  Future<String?> pickAndStore() async {
    calls++;
    if (failure) {
      throw const PhotoPickFailure('这张照片没有读出来，换一张试试');
    }
    return nextPath;
  }
}

DiaryController buildController({
  required SeedData seed,
  DiaryRepository? repository,
  PhotoService? photos,
}) {
  return DiaryController(
    repository: repository ?? MemoryDiaryRepository(),
    seeds: StaticSeedRepository(seed),
    photos: photos ?? FakePhotoService(),
    today: DateTime(2026, 10, 4),
  );
}

Map<String, dynamic> roundTrip(Map<String, dynamic> source) {
  return jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
}
