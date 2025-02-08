import 'package:flutter_x_widgets/app_demo/03/models/list_item.dart';
import 'package:flutter_x_widgets/app_demo/03/models/shopping_list.dart';

class ListService {
  final List<ShoppingList> _allLists = [
    ShoppingList(
      id: '1',
      title: 'Sunday Brunch Prep',
      description: 'Ready for fresh croissants and OJ!',
      createdDate: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        ListItem(
            name: 'Pink Drink',
            imageUrl:
                'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/foods/01.png'),
        ListItem(
            name: 'Pesto',
            imageUrl:
                'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/foods/02.png'),
        ListItem(
            name: 'Note',
            imageUrl:
                'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/foods/03.png'),
      ],
      isPinned: true,
      sharedWith: ['user1', 'user2'],
      isOpen: true,
    ),
    ShoppingList(
      id: '2',
      title: 'Healthy Eats',
      description: 'Ready for fresh croissants and OJ!',
      createdDate: DateTime.now().subtract(const Duration(days: 1)),
      items: [
        ListItem(
            name: 'Spinach',
            imageUrl:
                'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/foods/04.png'),
        ListItem(
            name: 'Almond Milk',
            imageUrl:
                'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/foods/05.png'),
      ],
      isOpen: true,
    ),
    ShoppingList(
        id: '3',
        title: 'Dinner Party Essentials',
        description: 'Ready for fresh croissants and OJ!',
        createdDate: DateTime.now().subtract(const Duration(days: 4)),
        items: [
          ListItem(
              name: 'Spinach',
              imageUrl:
                  'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/foods/06.png'),
          ListItem(
              name: 'Almond Milk',
              imageUrl:
                  'https://purcotton-omni.oss-cn-shenzhen.aliyuncs.com/omni/purcotton/lbh5/assets/flutter/foods/07.png'),
        ],
        isOpen: false,
        sharedWith: ['user1']),
  ];

  // 获取所有列表
  Future<List<ShoppingList>> getAllLists() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    return _allLists;
  }

  // 获取置顶列表
  Future<List<ShoppingList>> getPinnedLists() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allLists.where((list) => list.isPinned).toList();
  }

  Future<List<ShoppingList>> getRecentLists() async {
    await Future.delayed(const Duration(milliseconds: 200));
    //按时间排序
    List<ShoppingList> sortedLists = List.from(_allLists);
    sortedLists
        .sort((a, b) => b.createdDate.compareTo(a.createdDate)); // 最新的在前面
    return sortedLists;
  }

  Future<List<ShoppingList>> getSharedLists() async {
    await Future.delayed(const Duration(milliseconds: 200)); // 模拟延迟
    return _allLists
        .where((list) => list.sharedWith != null && list.sharedWith!.isNotEmpty)
        .toList();
  }

  //切换开关状态
  Future<void> toggleListOpenStatus(String listId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ShoppingList? listToUpdate =
        _allLists.firstWhere((list) => list.id == listId);

    int index = _allLists.indexOf(listToUpdate);
    if (index != -1) {
      _allLists[index] = ShoppingList(
        id: listToUpdate.id,
        title: listToUpdate.title,
        description: listToUpdate.description,
        createdDate: listToUpdate.createdDate,
        items: listToUpdate.items,
        isPinned: listToUpdate.isPinned,
        sharedWith: listToUpdate.sharedWith,
        isOpen: !listToUpdate.isOpen, //切换状态
      );
    }
  }
}
