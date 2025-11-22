import 'dart:async';

import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/category_selector.dart';
import '../widgets/masonry_grid.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar.dart';
import 'edit_page.dart';
import 'gallery_page.dart';
import 'voice_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  // 动画控制器
  late AnimationController _navBarAnimationController;
  late Animation<Offset> _navBarAnimation;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 显示导航栏的定时器
  Timer? _showNavBarTimer;

  // 记录上次滚动位置
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _navBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 定义动画：从 (0,0) 到 (0,1) 即向下滑出
    _navBarAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(
      CurvedAnimation(
        parent: _navBarAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 监听滚动
    _scrollController.addListener(_onScroll);

    _pages = [
      _NotesView(scrollController: _scrollController),
      EditPage(onBack: () => _onTabTapped(0)),
      const _AddView(), // Placeholder for Add button
      const VoicePage(),
      const GalleryPage(),
    ];
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _navBarAnimationController.dispose();
    _showNavBarTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // 只在首页（_NotesView）时处理滚动
    if (_currentIndex != 0) return;

    final currentScrollOffset = _scrollController.offset;

    // 1. 滑动到顶部（过度滚动），不处理
    if (currentScrollOffset < 0) {
      return;
    }

    // 2. scrollOffset 递增 = 向上滑动 = 隐藏导航栏
    if (currentScrollOffset > _lastScrollOffset) {
      if (_navBarAnimationController.value == 0) {
        _navBarAnimationController.forward();
      }
    }
    // 3. scrollOffset 递减 = 向下滑动 = 不做处理（等待定时器显示）

    _lastScrollOffset = currentScrollOffset;

    // 取消之前的定时器
    _showNavBarTimer?.cancel();

    // 停止滚动300ms后显示导航栏
    _showNavBarTimer = Timer(const Duration(milliseconds: 300), () {
      if (_navBarAnimationController.value == 1) {
        _navBarAnimationController.reverse();
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // 切换到 EditPage (index 1) 时隐藏导航栏
    if (index == 1) {
      _navBarAnimationController.forward();
    }
    // 切换到其他页面时显示导航栏
    else {
      _navBarAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // Dark Background
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar:
          _currentIndex == 1
              ? null // EditPage 时完全不显示
              : SlideTransition(
                position: _navBarAnimation,
                child: CustomBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                ),
              ),
    );
  }
}

class _NotesView extends StatefulWidget {
  final ScrollController scrollController;

  const _NotesView({required this.scrollController});

  @override
  State<_NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<_NotesView> {
  int _selectedCategoryIndex = 0;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _updateCategories();
  }

  void _updateCategories() {
    final groups = mockNotes.map((e) => e.group).toSet().toList();
    _categories = ['All (${mockNotes.length})', ...groups];
  }

  @override
  Widget build(BuildContext context) {
    // Filter notes
    final filteredNotes =
        _selectedCategoryIndex == 0
            ? mockNotes
            : mockNotes
                .where(
                  (note) => note.group == _categories[_selectedCategoryIndex],
                )
                .toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomSearchBar(),
            const SizedBox(height: 24),
            CategorySelector(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onSelected: (index) {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
            ),
            const SizedBox(height: 24),
            MasonryGrid(
              // Key forces re-creation and animation when category changes
              key: ValueKey(_selectedCategoryIndex),
              spacing: 16,
              children:
                  filteredNotes.map((note) {
                    return NoteCard(note: note);
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddView extends StatelessWidget {
  const _AddView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1C1C1E),
      body: Center(
        child: Text(
          'New Note',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'SF Pro Display',
          ),
        ),
      ),
    );
  }
}
