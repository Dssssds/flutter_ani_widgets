<!-- @format -->

# App 10: 知识分享总结

本文档提供了 "App 10" 模块的全面概述，这是一个基于 Flutter 构建的现代化笔记应用。文档重点介绍了代码库中的架构决策、核心功能以及有趣的实现细节。

## 1. 项目概览

**App 10** 是一款现代化的暗黑主题笔记应用，支持富文本编辑（Markdown）、清单管理和图片笔记。它拥有精致的用户界面，包含流畅的动画、交错网格布局（瀑布流）以及沉浸式的编辑体验。

## 2. 架构与技术栈

项目在 `lib/app_demo/10` 下遵循基于功能的结构：

- **`models/`**: 数据定义（例如 `Note`）。
- **`screens/`**: 全屏页面组件（例如 `HomePage`, `EditPage`）。
- **`widgets/`**: 可复用的 UI 组件（例如 `MasonryGrid`, `MarkdownEditor`）。
- **`utils/`**: 辅助逻辑（例如 `DocumentHistory`）。

**关键技术：**

- **Flutter**: 核心框架。
- **`super_editor`**: 提供富文本编辑能力。
- **自定义动画**: 大量使用 `AnimationController` 和 `Tween` 实现自定义 UI 效果。

## 3. 核心功能与实现细节

### 3.1 自定义瀑布流布局 (`MasonryGrid`)

该应用没有使用标准的 Grid 包，而是实现了一个自定义的 `MasonryGrid` 来达到交错布局的效果。

- **逻辑**: 根据索引（奇/偶）将子元素分配到两列（左和右）中。
- **入场动画**: 网格中的每个项目都有一个交错的入场动画（上滑 + 淡入 +以此消除模糊）。这是通过在 `_MasonryGridItem` 中使用基于项目索引的 `Future.delayed` 和 `SingleTickerProviderStateMixin` 实现的。

### 3.2 高级 Markdown 编辑器 (`MarkdownEditor`)

编辑器基于 `super_editor` 包构建，但增加了显著的自定义功能：

- **自定义控制器**: `MarkdownEditorController` 封装了核心编辑器组件（`Editor`, `Composer`）并暴露了高级方法。
- **工具栏**: `BottomToolbar` 提供对格式选项（加粗、斜体、标题、列表）和键盘控制的快速访问。它会根据当前的选择和焦点状态进行自适应。
- **样式**: 定义了自定义的 `Stylesheet` 规则，以渲染与应用暗黑主题相匹配的 Markdown 元素（标题、引用、任务列表）。

### 3.3 文档历史与撤销/重做 (`DocumentHistory`)

在 `utils/document_history.dart` 中实现了自定义的撤销/重做机制。

- **快照策略**: 它通过将整个文档序列化为 Markdown 字符串（`serializeDocumentToMarkdown`）并将这些快照存储在列表中来工作。
- **恢复**: 在撤销/重做时，存储的 Markdown 字符串被反序列化回 `Document`，并替换编辑器的内容。
- **优化**: 它使用定时器来对快照进行防抖处理，防止每一次击键都创建历史记录条目，从而平衡内存使用和用户体验。

### 3.4 滚动驱动导航 (`HomePage`)

`HomePage` 具有一个底部导航栏，会根据用户的滚动方向自动隐藏/显示。

- **实现**: 一个 `ScrollController` 监听滚动事件。
- **逻辑**:
  - **向下**滚动（偏移量增加） -> 隐藏导航栏（滑出过渡）。
  - **向上**滚动（偏移量减少） -> 显示导航栏。
  - **自动显示**: 定时器确保在滚动停止一小段时间后导航栏重新出现。

## 4. 代码亮点

### 交错动画逻辑

在 `widgets/masonry_grid.dart` 中，交错延迟的计算非常简单：

```dart
delay: Duration(
  milliseconds: i * widget.staggerDuration.inMilliseconds,
),
```

这创造了一种项目依次出现的级联效果。

### 历史记录管理

在 `widgets/markdown_editor.dart` 中，历史记录的记录经过了防抖处理：

```dart
_recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
  if (!_isRestoringFromHistory) {
    _history.record(_doc);
  }
});
```

这种简单的定期检查是捕获“稳定”状态的有效方法，而不会使历史记录栈不堪重负。

### 自定义光标颜色

在 `SuperEditor` 中，光标颜色通过 `documentOverlayBuilders` 进行自定义：

```dart
documentOverlayBuilders: const [
  DefaultCaretOverlayBuilder(
    caretStyle: CaretStyle(color: Colors.white),
    displayCaretWithExpandedSelection: true,
    displayOnAllPlatforms: true,
  ),
],
```

这覆盖了默认的光标渲染，以匹配暗黑主题。
