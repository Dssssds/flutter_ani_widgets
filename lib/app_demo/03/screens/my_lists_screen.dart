import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/03/models/shopping_list.dart';
import 'package:flutter_x_widgets/app_demo/03/services/list_services.dart';
import 'package:flutter_x_widgets/app_demo/03/widgets/list_card.dart';
import 'package:flutter_x_widgets/app_demo/03/widgets/shared_avatars.dart';

class MyListsScreen extends StatefulWidget {
  const MyListsScreen({super.key});

  @override
  MyListsScreenState createState() => MyListsScreenState();
}

class MyListsScreenState extends State<MyListsScreen> {
  final ListService _listService = ListService(); // 实例化服务
  List<ShoppingList> _allLists = [];
  List<ShoppingList> _pinnedLists = [];
  List<ShoppingList> _recentLists = [];
  List<ShoppingList> _sharedLists = [];

  //当前选中的tab
  int _selectedTabIndex = 0; // 0: All, 1: Pinned, 2: Recent, 3: Shared

  @override
  void initState() {
    super.initState();
    _loadLists(); // 在 initState 中加载数据
  }

  // 模拟异步加载数据 (实际应用中应从数据库或API获取)
  Future<void> _loadLists() async {
    // 使用 await 等待异步操作完成
    _allLists = await _listService.getAllLists();
    _pinnedLists = await _listService.getPinnedLists();
    _recentLists = await _listService.getRecentLists();
    _sharedLists = await _listService.getSharedLists();
    setState(() {}); // 更新UI
  }

  List<ShoppingList> _getFilteredLists() {
    switch (_selectedTabIndex) {
      case 0:
        return _allLists;
      case 1:
        return _pinnedLists;
      case 2:
        return _recentLists;
      case 3:
        return _sharedLists;
      default:
        return _allLists;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 修改为实际的tab数量
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title:
                const Text('My Lists', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings), // 设置图标
                onPressed: () {
                  // 打开设置页面 (如果需要)
                },
              ),
            ],
            // TabBar 作为 AppBar 的 bottom
            bottom: TabBar(
              labelStyle: const TextStyle(fontSize: 16, color: Colors.white),
              indicatorColor: Colors.white,
              isScrollable: true, // 允许滚动,避免内容挤压
              splashFactory: NoSplash.splashFactory,
              dividerColor: Colors.transparent,
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0), // 调整tab间距
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              tabs: [
                const Tab(text: 'All'),
                const Tab(text: 'Pinned'),
                const Tab(text: 'Recent'),
                Tab(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 120), // 限制最大宽度
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Shared', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 5),
                        if (_sharedLists.isNotEmpty)
                          Flexible(
                            child: SharedAvatars(
                              userIds: _sharedLists.first.sharedWith ?? [],
                              avatarSize: 18.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: _buildListBody()),
    );
  }

  //根据tab切换,来展示不同的列表
  Widget _buildListBody() {
    List<ShoppingList> filteredLists = _getFilteredLists();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredLists.length, // 使用过滤后的列表
      itemBuilder: (context, index) {
        return ListCard(
          list: filteredLists[index],
          onTap: () {
            // 处理列表点击事件
            if (kDebugMode) {
              print('Tapped on list: ${filteredLists[index].title}');
            }
          },
          onOpenClose: () {
            //修改状态
            _listService.toggleListOpenStatus(filteredLists[index].id);
            _loadLists(); //重新加载
          },
        );
      },
    );
  }
}
