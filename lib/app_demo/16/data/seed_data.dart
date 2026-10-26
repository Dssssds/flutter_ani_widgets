import 'package:flutter_x_widgets/app_demo/16/models/diary_entry.dart';
import 'package:flutter_x_widgets/app_demo/16/models/material.dart';

class SeedData {
  const SeedData({required this.catalog, required this.entries});

  final MaterialCatalog catalog;
  final Map<String, DiaryEntry> entries;
}
