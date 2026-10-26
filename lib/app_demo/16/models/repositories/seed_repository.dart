import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_x_widgets/app_demo/16/data/seed_data.dart';
import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';

abstract class SeedRepository {
  Future<SeedData> load();
}

class AssetSeedRepository implements SeedRepository {
  const AssetSeedRepository();

  static const materialsPath = 'assets/images/16/seed/materials.json';
  static const entriesPath = 'assets/images/16/seed/entries.json';

  @override
  Future<SeedData> load() async {
    final materialsJson = await rootBundle.loadString(materialsPath);
    final entriesJson = await rootBundle.loadString(entriesPath);
    return SeedData(
      catalog: parseMaterials(materialsJson),
      entries: parseEntries(entriesJson),
    );
  }

  static MaterialCatalog parseMaterials(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('materials.json must be an object');
    }
    return MaterialCatalog.fromJson(decoded);
  }

  static Map<String, DiaryEntry> parseEntries(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('entries.json must be an object');
    }
    final entries = <String, DiaryEntry>{};
    for (final raw in decoded.entries) {
      if (raw.value is! Map<String, dynamic>) {
        continue;
      }
      final entry = DiaryEntry.fromJson(raw.value as Map<String, dynamic>);
      entries[raw.key] = entry;
    }
    return entries;
  }
}
