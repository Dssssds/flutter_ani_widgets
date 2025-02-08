import 'package:flutter_x_widgets/app_demo/03/models/list_item.dart';

class ShoppingList {
  final String id;
  final String title;
  final String description;
  final DateTime createdDate;
  final List<ListItem> items;

  final bool isPinned;
  final List<String>? sharedWith;
  final bool isOpen;

  ShoppingList(
      {required this.id,
      required this.title,
      required this.description,
      required this.createdDate,
      required this.items,
      this.isPinned = false,
      this.sharedWith,
      this.isOpen = true});
}
