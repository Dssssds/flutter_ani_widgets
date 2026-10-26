# 「拾页」Flutter 落地实现规格书

- 版本：v1.0
- 依据：Web 原型 `https://ui.oiloil.org/works/diary/live/index.html`（2026-10 审阅）
- 目标：用 Flutter 1:1 还原产品行为与视觉，移动端优先
- 配套：`assets/`（原素材）、`seed/`（种子数据）、`reference/`（界面截图）

> 阅读优先级：本规格书 > `reference/` 截图 > 原 Web 原型。
> 本文所有尺寸均为 390×844 设计稿下的逻辑像素；位置若写作百分比，是相对纸张宽高。数据模型中的 `x/y` 统一用 0.0–1.0 的归一化值。

## 目录

1. 产品概览
2. 技术架构
3. 设计系统
4. 数据模型与持久化
5. 种子数据
6. 应用壳与导航
7. 手账页
8. 素材抽屉
9. 翻看页
10. 全局交互状态机
11. 视觉实现细节
12. 响应式与平台适配
13. 原型怪癖与实现决策
14. 实施顺序
15. 验收标准
16. 测试计划
17. 非目标
附录 A–E：资产、pubspec、常量、JSON 示例、常见错误

---

## 1. 产品概览

### 1.1 定位

「拾页」是一个手机端电子手账 / 拼贴工具。用户选一天，在固定纸质页面上贴照片、贴纸、胶带、便签，写标题与正文，保存后用月历回看。

关键词：手账、拼贴、纸张质感、手写体、低门槛、即时反馈。

### 1.2 三个页面

| 页面 | 作用 | 核心内容 |
|---|---|---|
| 手账 `journal` | 编辑某一天 | 日期头部、纸面拼贴、编辑工具条 |
| 素材 `drawer` | 选择素材 | 4 类素材、预览、贴到手账 |
| 翻看 `month` | 回看与补写 | 月历、缩略页、选中日期摘要 |

底部导航在三个页面常驻，顺序为：手账、素材、翻看。

### 1.3 核心闭环

**拼贴今天**：手账页 → 工具条选素材 / 从素材抽屉选 → 贴到纸上 → 拖动排版 → 改文字 → 保存。
**回看补写**：翻看 → 选日期 → 看摘要 → 进入当天 → 编辑 / 保存。
**即时反馈**：贴纸飞入、Toast、按钮已保存态、月历缩略页更新。

### 1.4 产品边界

- 无登录、无账号、无后端、无云同步、无分享。
- 无删除素材、无缩放、无自由旋转、无图层顺序调整。
- 仅中文；仅浅色主题；仅手机竖屏。
- 数据完全本地。

---

## 2. 技术架构

### 2.1 技术栈

- Flutter 3.24+ / Dart 3.5+
- 平台：iOS、Android（可兼容 macOS 调试，但不作为交付目标）
- 状态管理：`ChangeNotifier` + `AnimatedBuilder`
- 依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.10
  shared_preferences: ^2.3.0
  image_picker: ^1.1.2
  path_provider: ^2.1.4
  uuid: ^4.4.0
```

不引入路由库、状态管理库、代码生成、国际化框架。

### 2.2 建议目录

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── app_clock.dart
│   ├── app_colors.dart
│   ├── app_metrics.dart
│   └── app_text_styles.dart
├── data/
│   ├── models.dart
│   ├── seed_repository.dart
│   ├── entry_store.dart
│   └── material_catalog.dart
├── state/
│   └── diary_controller.dart
├── ui/
│   ├── shell/
│   │   ├── diary_shell.dart
│   │   ├── bottom_nav.dart
│   │   └── app_toast.dart
│   ├── journal/
│   │   ├── journal_screen.dart
│   │   ├── date_heading.dart
│   │   ├── paper_canvas.dart
│   │   ├── polaroid.dart
│   │   ├── weather_ticket.dart
│   │   ├── editor_toolbar.dart
│   │   └── text_editor_sheet.dart
│   ├── drawer/
│   │   ├── material_drawer_screen.dart
│   │   ├── material_cover.dart
│   │   ├── material_tile.dart
│   │   └── selection_tray.dart
│   ├── month/
│   │   ├── month_screen.dart
│   │   ├── calendar_grid.dart
│   │   ├── mini_page.dart
│   │   └── selected_entry_card.dart
│   └── widgets/
│       ├── tape_strip.dart
│       ├── note_paper.dart
│       └── flying_sticker_overlay.dart
└── painters/
    ├── paper_dot_painter.dart
    ├── tape_painter.dart
    └── ticket_clipper.dart
```

目录可调整，但页面、状态、存储三层必须分离，方便测试与后续替换。

### 2.3 应用形态

- 默认“原型画布”模式：应用内容固定为 `390×844`，屏幕更大时居中显示，外层背景 `#EAE3E7`。
- 屏幕宽度小于 390 时，画布宽度等于屏幕宽度。
- 屏幕高度小于 844 时，画布高度等于可用高度，内容纵向滚动。
- 手机端加 `SafeArea`；状态栏深色图标，背景 `#F7F0F3`。
- 锁定竖屏（手机）；平板/桌面可居中展示。
- 强制浅色主题，不跟随系统深色模式。

> 注意：`reference/` 截图中的深灰色圆角手机外框、外层留白来自展示画廊的 `work-frame.js`，不属于 App 本身。Flutter 只实现 390×844 的浅色应用区域；桌面调试时用 `#EAE3E7` 背景居中即可，不要绘制手机边框。

---

## 3. 设计系统

### 3.1 颜色 Token

| Token | 值 | 用途 |
|---|---|---|
| berry | `#9D3C65` | 主色、按钮、重点文字 |
| berryHover | `#873353` | 主按钮按下 / hover |
| ink | `#49323D` | 主文字、图标 |
| muted | `#765D68` | 次要文字 |
| appBg | `#F7F0F3` | 应用背景 |
| outerBg | `#EAE3E7` | 手机画布外背景 |
| pink | `#EED0DD` | 选中、品牌图标填充 |
| paper | `#FFFDF8` | 纸张 |
| line | `#E4D9DF` | 分割线、边框 |
| surface | `#FCF9FB` | 卡片、Tab 容器、弹窗 |
| selected | `#EEDCE5` | 选中态浅底 |
| noteInk | `#6C5147` | 正文 |
| captionInk | `#725845` | 照片说明 |
| ticketBg | `#F7E7CF` | 天气小票 |
| ticketBorder | `#BC8768`（48% 透明） | 小票边框 |
| ticketInk | `#9C674B` | 小票文字 |
| errorInk | `#873053` | 保存错误 |
| toastBg | `#654456`（93% 透明） | Toast |

### 3.2 字体

| 类别 | 字体 | 用途 |
|---|---|---|
| UI | 系统字体（SF / PingFang SC / Roboto） | 标题、按钮、正文说明 |
| 手写 `hand` | `Kaiti SC` → `STKaiti` → `KaiTi` → `serif` | 品牌、纸张标题、正文、便签、照片说明 |
| 数字 `number` | `Georgia` → `Times New Roman` → `serif`，斜体 | 大日号、月份数字、日期角标 |

Android 通常没有楷体。建议随包引入开源中文字体（如 LXGW WenKai / 霞鹜文楷，OFL 许可）作为 `hand`，否则 Android 会退化为普通衬线体，视觉差异明显。字体文件较大时可做子集化。

`pubspec.yaml` 可选字体声明：

```yaml
fonts:
  - family: WenKai
    fonts:
      - asset: assets/fonts/LXGWWenKai-Regular.ttf
```

`hand` 样式：

```dart
const handStyle = TextStyle(
  fontFamily: 'Kaiti SC',
  fontFamilyFallback: ['STKaiti', 'KaiTi', 'WenKai', 'serif'],
  fontWeight: FontWeight.w500,
);
```

如果没有字体文件，至少保留 `fontFamilyFallback`，不要在代码里写死单一字体。

### 3.3 字号与文字样式

| 元素 | 字号 / 行高 | 字重 / 其他 |
|---|---|---|
| 品牌「拾页」 | 25 | hand，berry，letterSpacing 1 |
| Header 标题（素材抽屉 / 翻翻手账） | 23 | w600，letterSpacing -0.5 |
| 大日号 | 67 | number，斜体，letterSpacing -4，行高 1 |
| 月份大数字 | 72 | number，斜体，letterSpacing -3，行高 1 |
| 日期行「10 月 · 星期日」 | 14 | w600 |
| 年份「2026 年 · 秋日手账」 | 13 | muted |
| 心情文字 | 12 | muted |
| 纸张标题 | 25 | hand，行高 1.3 |
| 纸张正文 | 18 | hand，行高 1.65，noteInk |
| 照片说明（主） | 14 | hand，行高 27 |
| 照片说明（副） | 12 | hand，行高 25 |
| 小票「午后收集」 | 11 | letterSpacing 2 |
| 小票温度 | 24 | number |
| 小票「有风 / 有阳光」 | 14 | hand，行高 1.5 |
| 日期角标 | 12 | number，letterSpacing 0.5 |
| 工具条文字 | 13 | UI |
| 底部导航 | 12 | w500；激活 w600 |
| 素材 Tab | 14 | 激活 w600 |
| 素材封面标题 | 31 | hand，w600，`#753553` |
| 区块标题 | 14 | w600 |
| 数量 / 辅助 | 12 | muted |
| 素材名称 | 13 | muted；选中 berry w600 |
| 粘贴按钮 | 14 | w500，白色 |
| 月历星期 | 12 | muted |
| 月历日期 | 13 | muted，行高 15 |
| 月摘要 | 13 | muted，数字 berry |
| 月份名 | 18 | w600 |
| 选中日期 `09.27` | 19 | number，斜体，berry |
| 摘要卡标题 | 16 | w500，行高 1.4 |
| 摘要卡正文 | 13 | 行高 1.6，muted |
| 摘要卡 CTA | 12 | berry |
| 弹窗标题 | 20 | w600 |
| 弹窗标签 | 13 | muted |
| 弹窗输入 | 16 | 行高 1.5 |
| Toast | 13 | 白色 |

### 3.4 关键尺寸表（390×844）

| 区块 | 尺寸 / 位置 |
|---|---|
| 应用画布 | 390×844，最大 100% |
| 顶部 Header | 高 79，padding `24 23 10`；矮屏（高≤800）高 70、上 padding 17 |
| 品牌图标 | 30×32，rotate -7°；图标 28×28 |
| 撤销按钮 | 44×44，图标 20 |
| 保存按钮 | 92×44，圆角 7；图标 16 |
| 日期区 | 高 93，padding `0 4 12`，gap 14 |
| 心情按钮 | 最小 54×54，图标 23，gap 5 |
| 手账滚动区 | padding `0 20 10`；窄屏（宽≤389）padding 横向 16 |
| 纸张 | 高 510，宽度 = 屏宽 - 40（390 下为 350），圆角 `3 3 9 3` |
| 纸张标题 | left 25，top 21，maxWidth 290 |
| 打孔 | 9×11，left -4，top 41，纵向 gap 170，共 3 个 |
| 主拍立得 | 宽 219（约纸张 62.6%），left 7.14%，top 15.88%，rotate -6°，padding `8 8 5`；图片高 226 |
| 主照片胶带 | 87×28，left 59，top -10 |
| 小票 | 81×159，top 84，right 15，rotate 6° |
| 副拍立得 | 宽 139（约纸张 39.7%），left 56.57%，top 54.31%，rotate 7°，padding `6 6 3`；图片高 138 |
| 副照片胶带 | 60×22，left 41，top -10 |
| 纸张正文 | left 29，top 359，宽 170，行高 1.65 |
| 底部标签行 | left 25，right 23，bottom 16，高 34 |
| 编辑工具条 | 高 64，margin `13 5 0`，4 等分，图标 23 |
| 底部导航 | 高 76，padding `9 30 11`，激活胶囊 49×32，圆角 10 |
| 素材抽屉滚动区 | padding `10 22 14` |
| 素材 Tab 容器 | 高 45，padding 4，圆角 10；滑块高 37，宽 `(W-8)/4`，圆角 7 |
| 素材封面 | 高 108，圆角 4；标题 left 19 bottom 23 |
| 素材网格 | 3 列，列 gap 12，行 gap 15；tile 高 135；图区 106 |
| 素材托盘 | 高 89，横向 margin 22，预览 45，按钮最小高 44，圆角 8 |
| 翻看滚动区 | padding `0 22 18` |
| 月份标题区 | 高 98，gap 17；箭头按钮 44 |
| 月摘要 | margin `10 0 20` |
| 月历 | padding `16 10 13`，圆角 5；日期格高 59，行 gap 6 |
| 迷你页 | 28×31 |
| 选中日期卡 | margin-top 22；缩略图 78×100；箭头 18 |
| 文字弹窗 | 左右 inset 15，底部 110，padding 22，圆角 14 |
| Toast | bottom 177，居中，padding `11 17`，圆角 9 |

### 3.5 阴影

| 元素 | 阴影 |
|---|---|
| 纸张 | `0 2 3 rgba(105,70,91,0.063), 0 9 24 rgba(105,70,91,0.07)` |
| 拍立得 | `0 1 3 rgba(98,74,64,0.19), 2 5 8 rgba(98,74,64,0.09)` |
| 已贴素材 | `dropShadow(1, 2, 1, rgba(94,66,55,0.10))`；hover 更深 |
| 月历纸张 | `0 2 5 rgba(112,68,88,0.02), 0 6 18 rgba(112,68,88,0.02)` |
| 弹窗 | `0 10 50 rgba(112,68,88,0.19)` |
| Toast | `0 4 12 rgba(79,47,69,0.15)` |

### 3.6 动效与状态

| 场景 | 规则 |
|---|---|
| 按钮按下 | scale 0.96，180ms |
| Tab 滑块 | 240ms，`Cubic(0.2, 0.75, 0.25, 1)` |
| 首次进入纸张 | 420ms，opacity 0→1，translateY 7→0，rotate 0.5°→0 |
| 贴纸飞入 | 680ms，路径见 10.4 |
| Toast | 出现/消失淡入淡出约 200ms，停留 4.2s |
| 文字弹窗 | 系统 modal 过渡即可 |
| 页面切换 | 直接切换，无页面转场 |
| 焦点 | 2px berry 外描边，offset 4 |
| 减少动态 | `MediaQuery.disableAnimations` 为 true 时，去掉飞入、纸张入场、按钮缩放 |

---

## 4. 数据模型与持久化

### 4.1 枚举

```dart
enum AppScreen { journal, drawer, month }

enum MaterialCategory { sticker, tape, note, photo }

enum MaterialKind { sticker, tape, note, photo }

enum PhotoSlot { none, main, side }
```

### 4.2 素材与已贴元素

```dart
class MaterialItem {
  final String id;
  final String name;
  final MaterialKind kind;
  final String? src;        // sticker / photo 的资源路径
  final String? tapeStyle;  // tape: rose / check / caramel / flower-tape / dots / plain
  final String? text;       // note 的显示文字（含换行）
  final String? color;      // note 的底色，来自 materials.json
}
```

```dart
class PlacedItem {
  String id;
  MaterialKind kind;
  String name;
  String? src;        // 贴纸/照片：asset 路径或本地文件路径
  String? tapeStyle;
  String? text;       // 便签文字
  String? color;      // 便签底色
  double x;           // 0..1，相对纸张宽
  double y;           // 0..1，相对纸张高
  double rotation;    // 角度，如 -9、5
}
```

### 4.3 手账条目

```dart
class DiaryEntry {
  final int year;
  final int month;
  final int day;
  final String weekday;       // 星期一..星期日
  String mood;                // 好心情 / 被治愈了
  String title;
  String note;
  bool basePhotos;            // 是否显示两张内置拍立得
  String mainSrc;             // 主照片 / 或占位资源
  String mainCaption;
  String sideSrc;
  String sideCaption;
  double mainX, mainY;        // 0..1
  double sideX, sideY;        // 0..1
  List<PlacedItem> items;
  String type;                // flowers/cafe/dog/sticker/picnic/note/blank/today
  String? coverText;          // 便签缩略页上的两行短句
}
```

要求：

- `toJson` / `fromJson` 完整往返，未知字段忽略，缺失字段给默认值。
- `deepCopy()` 用于撤销栈与草稿缓存；`items` 必须逐项复制。
- `key` 格式：`YYYY-MM-DD`，月/日补零。
- 所有位置字段在模型中存 0..1；布局时乘以纸张宽高。

### 4.4 素材目录

从 `seed/materials.json` 加载：

- `categories`：4 个分类的标签、封面标题/副标题、区块标题、单位。
- `stickers`、`tapes`、`notes`、`photos`：素材列表。
- `pasteDefaults`：贴入时的默认位置与角度。
- `materialSizes`：已贴素材的默认尺寸（用于拖动边界）。

### 4.5 持久化

- 使用 `shared_preferences`，key：`shiye-entries-v1`。
- 值为 JSON 对象：`{"2026-09-27": {...DiaryEntry...}, ...}`。
- 读取时校验：必须是对象；解析失败的日期丢弃；整体损坏则回退空表。
- 上传照片：
  - 用 `image_picker` 选择后，复制到 `<ApplicationDocuments>/photos/<uuid>.jpg`。
  - `PlacedItem.src` 存**绝对文件路径**或可解析的相对路径；不要存临时缓存路径。
  - 不要把所有照片塞进 `shared_preferences`；避免体积与性能问题。
  - 若未来支持 Web，再改为 base64 或 IndexedDB 方案。
- 草稿：只保存在内存，切换日期时缓存，刷新/杀进程丢失（与原型一致）。
- 保存是异步的；保存期间按钮显示「保存中」并禁用。

### 4.6 演示时钟

```dart
class AppClock {
  static const bool useRealDate = bool.fromEnvironment('USE_REAL_TODAY');
  static DateTime get today =>
      useRealDate ? DateTime.now() : DateTime(2026, 10, 4);
}
```

- 默认 `useRealDate = false`，保证打开即是原型中的 2026-10-04「有风的下午」。
- `isFuture(day)`：该日期（零点）晚于 `AppClock.today` 的零点。
- 月历“下个月”上限：当前月份（演示模式为 2026-10）。
- 品牌「拾页」点击：加载 `AppClock.today` 对应的条目并切到手账页。
- 真实日期模式下：初始条目改为今天，翻看默认当前月与今天；其余交互不变。

---

## 5. 种子数据

### 5.1 文件

- `seed/entries.json`：21 条。
  - 2026-09：17 天（1, 3, 4, 6, 8, 9, 11, 13, 15, 17, 18, 20, 22, 24, 26, 27, 30）。
  - 2026-10：1–4 日。
- `seed/materials.json`：4 类素材、分类文案、默认粘贴位置、素材尺寸。

### 5.2 使用方式

- 将 `seed/` 注册为 `assets/seed/`，启动时用 `rootBundle.loadString` 读取并解析。
- 种子是只读的；用户保存的条目放 `savedEntries`，覆盖同日期种子。
- 不要修改种子文件来“预置已保存状态”。

### 5.3 默认条目（种子之外的日期）

任何没有种子、也没有保存记录的日期，打开时使用：

- 标题：`我的小小日常`
- 正文：`今天，想留下一点喜欢。`
- 心情：`好心情`
- `basePhotos = false`（空白页版式，不显示拍立得和小票）
- `mainSrc = assets/photos/cafe.webp`（隐藏，仅占位）
- `mainCaption = 留下一点喜欢`
- `sideSrc = assets/photos/dog.webp`，`sideCaption = 偶遇一位小朋友`（隐藏）
- 主/副位置：`(0.0714, 0.1588)` / `(0.5657, 0.5431)`
- `items = []`
- `type = blank`，`coverText = null`
- 星期由日期计算。

空白页版式中，正文上移到纸张 top 102，宽度 `纸张宽 - 58`，最大 280；标题位置不变。

### 5.4 便签文字映射

素材名称与显示文字不完全一致，显示时使用：

| 名称 | 显示文字 |
|---|---|
| 好喜欢 | `好喜欢` |
| 慢慢来 | `慢慢来` |
| 今日份开心 | `今日份\n开心` |
| 给自己放个假 | `给自己\n放个假` |
| 天气很好 | `天气\n很好` |
| 记得这一天 | `记得\n这一天` |

`seed/materials.json` 的 `notes[].text` 已包含换行，直接使用即可。

### 5.5 月份缩略页数据

- 种子条目自带 `type` 与 `coverText`。
- 保存条目后，缩略页样式应依据实际内容判断（见 9.6），不要沿用原型“保存后一律变咖啡照片”的缺陷。

---

## 6. 应用壳与导航

### 6.1 结构

```text
Scaffold
└── Center(SizedBox(390, min(844, viewport)))
    └── Stack
        ├── IndexedStack(index: screen)
        │   ├── JournalScreen
        │   ├── MaterialDrawerScreen
        │   └── MonthScreen
        ├── Positioned(bottom: 0) BottomNav
        └── AppToast (bottom 177)
```

- 使用 `IndexedStack` 保留三个页面的滚动位置和局部状态。
- 底部导航常驻，不因页面切换隐藏。
- Toast 浮在导航之上、工具条附近。
- 文字编辑弹窗使用全局 Overlay / Dialog，不放进 IndexedStack。

### 6.2 底部导航

- 高 76（矮屏 70），背景 appBg，顶部 0.5px line。
- 3 等分：手账（book 图标）、素材（drawer 图标）、翻看（calendar 图标）。
- 图标 23，文字 12，gap 3。
- 激活：文字 berry w600，图标容器 49×32 圆角 10，背景 selected。
- 未激活：muted。
- 点击：
  - 手账：`screen = journal`，不改变当前条目。
  - 素材：`category = sticker`，`screen = drawer`（即使上次停留在胶带，也从贴纸进入）。
  - 翻看：`screen = month`，保留 `viewYear/viewMonth/selectedDay`。
- 无障碍标签：手账 / 素材 / 翻看，激活项标记 selected。

### 6.3 Android 返回键（建议实现）

- 在素材页：返回手账页。
- 在翻看页：返回手账页。
- 在手账页：允许系统默认退出。
- 文字弹窗打开时：先关闭弹窗。

原型没有显式返回逻辑；这是移动端必要的适配，不改变视觉。

---

## 7. 手账页

### 7.1 结构

```text
Column
├── AppHeader（品牌 / 撤销 / 保存）
├── SaveError（可选）
├── Expanded
│   └── SingleChildScrollView
│       └── Column
│           ├── DateHeading
│           ├── PaperCanvas
│           └── EditorToolbar
└── (BottomNav 由 Shell 提供)
```

### 7.2 顶部 Header

- 左侧品牌按钮：
  - 图标 30×32，rotate -7°；书本图标填充 pink、描边 berry。
  - 文字「拾页」25 hand w700，berry，letterSpacing 1。
  - 点击：`loadEntry(AppClock.today)` 并切到手账页。当前未保存内容先进入内存草稿。
  - 无障碍：`打开今天的手账`。
- 右侧：
  - 撤销：44×44；无历史时禁用（透明度 35%）；点击弹栈。
  - 保存：92×44，圆角 7，berry 背景，白字 14 w600，左侧 16 图标。
    - 未保存：文字「保存」。
    - 保存中：文字「保存中」，禁用。
    - 已保存：背景 selected，文字/图标 berry，文字「已保存」。
- 保存错误提示显示在 Header 下方，左右 23，字号 13，errorInk，行高 1.5。

### 7.3 日期区

- 高度 93，横向 padding 4，底部 12。
- 左：大日号（如 `04`），67 number 斜体，letterSpacing -4。
- 中：`10 月 · 星期日`（14 w600）；下一行 `2026 年 · 秋日手账`（13 muted）。
- 右：心情按钮：
  - 图标：好心情用 sun，被治愈了用 heart；23px，描边 1.4。
  - 文字：`好心情` / `被治愈了`，12 muted。
  - 点击切换，先 snapshot，再更新；不弹 Toast。
  - 无障碍：`切换心情，当前好心情`。
- 星期来自条目；默认条目按日期计算。

### 7.4 纸张

- 尺寸：宽 = 屏宽 - 40，高 510；窄屏横向 padding 16。
- 背景 paper，圆角 `3 3 9 3`，阴影见 3.5。
- 点阵：颜色 `#CFC4B8`，半径 0.65，间距 15，起点偏移 (8, 9)。用 `CustomPainter`。
- 纸纹：`paper-grain.png` 平铺，透明度 0.18，乘算/近似叠加；必须 `IgnorePointer`，置于纸面内容最上层。
- 左侧 3 个打孔：9×11，left -4，top 41，间距 170；颜色 appBg，可加内侧阴影。
- 纸张允许内容溢出（胶带、阴影），`Stack.clipBehavior = Clip.none`；但背景圆角只裁剪背景。
- 点击纸张空白处：取消拍立得选中态。

### 7.5 纸面图层顺序

从下到上：

1. 打孔
2. 天气小票
3. 纸张标题
4. 主拍立得
5. 底部标签行
6. 正文
7. 副拍立得
8. 已贴素材（按插入顺序，后贴的在上）
9. 纸纹覆盖层

说明：原型 z-index 为 ticket 1 / title 2 / main 2 / label 2 / note 3 / side 4 / items 6 / grain 8。上述顺序等价。正文可被素材遮挡；素材始终在拍立得和正文之上。

### 7.6 内置拍立得

两个拍立得都是可拖动元素，但尺寸、旋转、说明文字不同：

| 项目 | 主照片 | 副照片 |
|---|---|---|
| 宽度 | 219（纸张 62.6%） | 139（纸张 39.7%） |
| 位置 | left 7.14%，top 15.88% | left 56.57%，top 54.31% |
| 旋转 | -6° | 7° |
| 内边距 | 8 / 8 / 5 | 6 / 6 / 3 |
| 图片高度 | 226（窄屏 234） | 138 |
| 说明字号 | 14 / 行高 27 | 12 / 行高 25 |
| 胶带 | rose，87×28，left 59，top -10，rotate 3° | check，60×22，left 41，top -10，rotate -5° |

- 白色相纸：`#FFFEFB`，阴影见 3.5。
- 图片 `BoxFit.cover`，不可单独点击。
- 说明文字 hand，颜色 captionInk，单行不换行，居中。
- 选中态：1.5px 虚线 berry 外框，offset 4；四角小圆点装饰（可用 CustomPainter）。选中时底部标签行中间显示「按住照片移动」+「完成」按钮。
- 拖动：
  - 按下即选中（`photoSelected = main/side`）。
  - 移动超过 2px 后首次 snapshot。
  - 位置更新为归一化 x/y，限制在纸张内。
  - 旋转角固定，不随拖动改变。
  - 边界计算使用**未旋转**外框尺寸。

### 7.7 天气小票

- 固定装饰，不参与编辑。
- 81×159，top 84，right 15，rotate 6°。
- 背景 ticketBg，1px ticketBorder 边框；上下锯齿裁切（约 16 个小三角）。
- 内容居中：
  - 「午后收集」11，letterSpacing 2。
  - sun 图标 25，描边 1.3。
  - 「23°」24 number。
  - 虚线分隔线（颜色 `#B89271`，左右 margin 9）。
  - 「有风\n有阳光」14 hand，行高 1.5。
- 文字颜色 ticketInk。

### 7.8 标题、正文、日期角标

- 标题：left 25，top 21，maxWidth 290，25 hand，行高 1.3；超出按字符换行。
- 正文：
  - 默认 left 29，top 359，宽 170，18 hand，行高 1.65，noteInk，保留换行。
  - 若正文长度 > 30 或换行数 > 3：固定高度区域（约 98）内部滚动，不撑破纸张。
  - 空白页（`basePhotos == false`）：正文 left 29，top 102，宽 = 纸张宽 - 58，最大 280。
- 日期角标：右下，`MM.DD`（如 `10.04`），12 number，muted，letterSpacing 0.5。
- 底部标签行：
  - left 25，right 23，bottom 16，高 34。
  - 左侧默认空；拍立得选中时显示「按住照片移动」和「完成」按钮（12，berry；按钮无背景），同时隐藏右侧日期角标。
  - 右侧日期角标。

### 7.9 已贴素材

| 类型 | 尺寸 | 渲染 |
|---|---|---|
| 贴纸 | 83×83 | SVG/图片 contain，投影 |
| 照片 | 124×147 | 白色相框，padding 5，图片 cover，投影 |
| 胶带 | 118×36 | 自定义胶带图案，透明度 0.85，rotate 默认 -9° |
| 便签 | 108×90 | 底色 `item.color ?? #F3DEB2` + 手写文字，rotate 默认 -6° |
- 位置：`left = x * paperWidth`，`top = y * paperHeight`。
- 旋转：围绕中心 `Transform.rotate`。
- 后贴的素材在上层。
- 拖动：与拍立得相同的指针逻辑；限制在纸张内；首次有效移动才 snapshot。
- 已贴素材没有单独选中框；按下即可拖。
- 无障碍标签：`移动<素材名>`。

### 7.10 编辑工具条

4 等分按钮，高 64，图标 23，文字 13，颜色 muted；hover 时浅底圆角 8（桌面调试用）。

| 按钮 | 行为 |
|---|---|
| 照片 | 打开系统相册选择图片，成功后压缩并插入纸面 |
| 贴纸 | `openDrawer(sticker)` |
| 胶带 | `openDrawer(tape)` |
| 文字 | 打开文字编辑弹窗 |

工具条不显示“当前分类”高亮；移动端只有点击/按压态。

### 7.11 文字编辑弹窗

- 形态：底部浮层，左右 15，底部 110，padding 22，圆角 14，背景 surface。
- 遮罩：`#432334` 70% 透明；点击遮罩关闭；X 关闭；系统返回关闭。
- 标题「写一点今天」20 w600；右上 X 44。
- 字段：
  - 「这一页的名字」标签 13 muted；输入框单行，maxLength 10，必填。
  - 「想记下的话」标签 13 muted；多行输入，maxLength 75，行数约 4，必填。
  - 输入框背景 `#FFFDF9`，1px `#DDC8D3` 边框，圆角 6，padding `11 12`，字号 16，光标 berry。
- 底部按钮「写到纸上」，全宽，高 44+，圆角 8，berry，白字 14，右侧 check 图标。
- 打开时自动聚焦标题，键盘弹出时整体上移，避免遮挡。
- 校验：trim 后为空不允许提交；按钮可禁用或点击无反应。超长由 `maxLength` 截断。
- 提交：snapshot → 写回 trim 后的标题与正文 → 关闭。
- 关闭不保存修改。

### 7.12 照片上传

- 使用 `image_picker`：
  ```dart
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 700,
    maxHeight: 700,
    imageQuality: 82,
  );
  ```
- 用户取消：无任何变化。
- 选择后校验可解码；失败 Toast「这张照片没有读出来，换一张试试」。
- 非图片：Toast「请选择一张照片」（`image_picker` 通常已限制，但仍需兜底）。
- 成功：
  1. 复制到应用文档 `photos/<uuid>.jpg`。
  2. snapshot。
  3. 追加 `PlacedItem(kind: photo, name: 新照片, src: 本地路径, x: 0.45, y: 0.45, rotation: 5)`。
  4. Toast「照片已放好，按住可以移动」。
- 上传照片在月历缩略页中优先作为封面。

### 7.13 首次入场

- 应用首次构建手账纸张时，执行 420ms 入场动画：opacity 0→1，位移 7px，旋转 0.5°。
- 仅首次进入执行；切换日期/页面不再执行。
- 减少动态时跳过。

---

## 8. 素材抽屉

### 8.1 结构

```text
Column
├── Header（素材抽屉 / X）
├── Expanded
│   └── SingleChildScrollView
│       ├── MaterialTabs
│       ├── MaterialCover
│       ├── SectionLabel
│       └── MaterialGrid
└── SelectionTray
```

底部导航仍由 Shell 提供。

### 8.2 Header

- 左：「素材抽屉」23 w600。
- 右：X 44×44；点击回到手账页。
- 无障碍：`返回手账`。

### 8.3 Tab

- 容器高 45，padding 4，背景 surface，圆角 10。
- 4 等分按钮，文字 14；激活 berry w600，未激活 muted。
- 滑块：宽 `(容器宽 - 8) / 4`，高 37，背景 selected，圆角 7，阴影浅；切换 240ms 平移动画。
- 分类顺序固定：贴纸、胶带、便签、照片。

### 8.4 封面

高 108，圆角 4，背景 `#EFDAE4`，叠加 16% 纸纹。标题 left 19 bottom 23，31 hand w600，颜色 `#753553`。

| 分类 | 标题 | 装饰 |
|---|---|---|
| 贴纸 | 秋日小事 | 小花 85×85，left 209 top 8 rotate 8；咖啡 74×74，right 7 bottom 7 rotate 8 |
| 胶带 | 纸上的温柔 | 右侧一条 check 胶带 150×32，right 20 top 14 rotate 8 |
| 便签 | 随手写写 | 右侧一张便签 68×69，right 20 top 14 rotate 8，文字「慢慢来」 |
| 照片 | 今天的光 | 右侧两张照片 60×74，纸边 4，rotate -8 / 5，重叠 -12 |

### 8.5 区块标题

左侧动态：

- 贴纸：秋日贴纸
- 胶带：把喜欢固定住
- 便签：留一张小纸条
- 照片：镜头里的日常

右侧数量：`6 枚` / `6 枚` / `6 枚` / `4 张`。字体 12 muted；标题 14 w600。

### 8.6 素材网格

- 3 列，列 gap 12，行 gap 15；tile 高 135。
- 图区 106 高，1px line 边框，圆角 7，背景 surface。
- 素材图：
  - 贴纸 88×88 contain。
  - 胶带 86×31 rotate -9。
  - 便签 77×77 rotate -6，文字 17 hand，居中，保留换行；底色直接使用 `seed/materials.json` 中每个 note 的 `color`：
    - 第 1 / 3 项：`#EAD2DF`（粉）
    - 第 2 / 5 项：`#DCE2E8`（蓝）
    - 第 4 / 6 项：`#F3DEB2`（黄）
    - 底部托盘的预览用默认黄色 `#F3DEB2`
  - 照片 78×91，padding 4，背景 paper，rotate -5，图片 cover。
- 名称 13 muted，居中，最多两行。
- 选中：图区 1px berry 边框 + selected 背景；名称 berry w600；右上角 18×18 berry 圆点 + 白色 check 13。
- 单选，默认每类第一项。
- 点击素材只选中，不自动粘贴。
- 无障碍：`选择<素材名>`，选中态 `aria-pressed` 对应 Flutter `Semantics(selected: ...)`。

### 8.7 底部选择托盘

- 高 89，左右 margin 22，顶部 0.5px line。
- 左：45×45 预览。
- 中：素材名称 14（换行时最多两行）。
- 右：「贴到手账」按钮，最小高 44，padding 横向 17，圆角 8，berry，白字 14 w500，右侧 chevron 17。
- 托盘固定，不随网格滚动。

### 8.8 贴入行为

1. 取当前选中素材；复制为 `PlacedItem`。
2. snapshot。
3. 按类型设置默认位置与角度（来自 `seed/materials.json`）：

| 类型 | x | y | rotation |
|---|---|---|---|
| sticker | 0.72 | 0.48 | -9 |
| tape | 0.35 | 0.59 | -9 |
| note | 0.57 | 0.61 | -9 |
| photo | 0.52 | 0.49 | -9 |
| 上传照片 | 0.45 | 0.45 | 5 |

4. 追加到当前条目 `items`，切回手账页。
5. 贴纸：播放飞入动画；其他类型直接 Toast「已贴上，按住可以移动」。
6. 素材选中状态保留；分类状态保留。

---

## 9. 翻看页

### 9.1 初始状态

- `viewYear = 2026`，`viewMonth = 9`，`selectedDay = 27`。
- 月摘要：`写下了 17 天`。
- 选中 9 月 27 日「周末，去河边走走」。
- 月份切换后，`selectedDay` 改为该月最后一个有记录的日子；没有记录则为 1。

### 9.2 结构

```text
Column
├── Header（翻翻手账 / 拾页）
├── Expanded
│   └── SingleChildScrollView
│       ├── MonthHeading
│       ├── MonthSummary
│       ├── CalendarGrid
│       └── SelectedEntryCard
```

### 9.3 Header 与月份标题

- Header：左「翻翻手账」23 w600；右「拾页」17 hand muted。
- 月份标题区高 98，gap 17：
  - 两位月份数字（`09` / `10`）72 number 斜体，letterSpacing -3。
  - 右侧上方 `2026 年` 13 muted；下方 `九月` 18 w600。
  - 最右两个 44×44 箭头按钮：上个月、下个月；chevron 18。
  - 下个月在演示模式 2026-10 时禁用（透明度 35%）；上个月不限。
- 月摘要 `写下了 N 天`，13 muted，数字 berry w500。

### 9.4 月历

- 纸张背景 paper，圆角 5，padding `16 10 13`，阴影见 3.5。
- 星期栏：`一 二 三 四 五 六 日`，12 muted，7 等分，底部 9。
- 日期网格：7 列，行 gap 6，单元格高 59。
- 月份偏移：`DateTime(year, month, 1).weekday - 1`（周一为 0）；前导空格保留，不显示。
- 单元格：
  - 日号 13 muted，行高 15。
  - 有手账：显示迷你页（见 9.5）。
  - 无手账且非未来：底部 21 处显示 3×3 圆点 `#D9CBD1`。
  - 未来日期：禁用，整体透明度 35%，不显示圆点。
  - 选中：背景 selected，内描边 1px berry 24% 透明，日号 berry w700。
- 点击有效日期：设置 `selectedDay`。
- 无障碍：`9月27日，有手账` / `9月2日，还没有手账`；未来日期禁用。

### 9.5 迷你页

28×31，背景 `#FFF7EC`，padding `3 3 5`，rotate -7°，浅阴影；顶部胶带 15×5，颜色 `#DBA3B5`（75% 透明），位置 top -2 left 7。

| 类型 | 样式 |
|---|---|
| 普通照片 | 旋转 -7°；图片 cover |
| dog | 旋转 8°；胶带 `#AEBECD`（85% 透明） |
| sticker | 背景 `#F4E3CB`，旋转 5°；图片 contain |
| note | 背景 `#EFD4E1`，旋转 -4°，padding `7 2 2`；显示 coverText，7 hand，1.25 行高，居中，保留换行；胶带 `#B2C2D7` |
| picnic | 背景 `#F2DFBB`，旋转 4° |
| flowers | 旋转 -4° |

没有 `coverText` 的便签给默认短句（可用 `慢慢来`）。

### 9.6 缩略页来源（改进项）

原型保存条目后，月历缩略图一律变成咖啡照片。实现时改为按实际内容：

1. `items` 中第一张 photo → 用该照片，类型 photo。
2. 否则若 `basePhotos == true` → 用 `mainSrc`，类型 photo。
3. 否则 `items` 中第一张 note → 用 note 样式与文字。
4. 否则 `items` 中第一张 sticker → 用 sticker 样式与图片。
5. 否则若 `type == note` → note 样式，使用 `coverText`。
6. 否则若 `type == sticker` → sticker 样式，使用 `mainSrc`。
7. 否则 → 空白迷你页或默认照片占位。

这条改进让“保存后缩略图突变”消失，视觉更符合用户预期。

### 9.7 选中日期摘要卡

- margin-top 22。
- 日期行：`MM.DD` 19 number 斜体 berry；若当天没有记录，右侧小字「还没有写下这一天」11 muted。
- 有记录：
  - 缩略图 78×100，白底 padding 5，rotate -4°，顶部小胶带 35×12。
  - 标题 16 w500；正文 13 行高 1.6 muted，最多 2 行省略。
  - 右侧 chevron 18 berry。
  - 点击：加载该日期条目，切到手账页。
- 无记录：
  - 标题「给这一天留个位置」16 w500。
  - 描述「一张照片，或者一句话。」13 muted。
  - CTA「写下这一天」12 berry。
  - 点击：创建默认条目，切到手账页。
- 整卡可点击，最小高 106。

### 9.8 月份切换

- 上个月：允许一直向前。
- 下个月：目标月份超过 `AppClock.today` 所在月份时禁用/阻止。
- 切换后 `viewYear/viewMonth` 更新，`selectedDay` 按 9.1 规则重置。
- 月份数据 = 种子（仅 2026-09/10）+ 已保存条目覆盖；其他月份 0 天。
- 计数使用合并后的条数。

### 9.9 打开日期

- `loadEntry(viewYear, viewMonth, selectedDay)`。
- 当前条目若有未保存修改，先存入内存草稿。
- 打开后 `screen = journal`。
- 历史记录清空；`saved` 根据是否有存储记录决定。
- 手账页编辑并保存后，返回翻看即可看到缩略页与摘要更新。

---

## 10. 全局交互状态机

### 10.1 Controller 字段

```dart
class DiaryController extends ChangeNotifier {
  AppScreen screen = AppScreen.journal;
  MaterialCategory category = MaterialCategory.sticker;
  MaterialItem? selectedMaterial;

  DiaryEntry entry;                       // 当前编辑
  final List<DiaryEntry> history = [];    // 最多 15
  bool saved = false;
  bool saving = false;
  String saveError = '';

  String toast = '';
  Timer? toastTimer;

  bool firstEntrance = true;
  String? flyingId;
  PhotoSlot photoSelected = PhotoSlot.none;

  bool editing = false;
  String editTitle = '';
  String editNote = '';

  int viewYear = 2026;
  int viewMonth = 9;
  int selectedDay = 27;

  final Map<String, DiaryEntry> savedEntries = {};
  final Map<String, _Draft> draftEntries = {};
}
```

### 10.2 启动流程

1. 读取 `savedEntries`（损坏则空表）。
2. 加载 `materials.json` 与 `entries.json`。
3. 选中贴纸分类第一项。
4. `entry = savedEntries['2026-10-04'] ?? seed['2026-10-04']`。
5. `saved = savedEntries` 中存在该日期。
6. `history = []`，`screen = journal`。
7. `firstEntrance = true`；约 600ms 后置 false（纸张入场 420ms）。
8. 可选：根据调试参数设置初始页面/分类。

### 10.3 日期切换与草稿

```text
loadEntry(year, month, day):
  if current entry exists:
      draftEntries[key(current)] = Draft(entry.deepCopy(), saved)
  if draft exists:
      entry = draft.entry.deepCopy()
      saved = draft.saved
  else if savedEntries has key:
      entry = savedEntries[key].deepCopy()
      saved = true
  else:
      entry = seedEntry or defaultEntry
      saved = false
  history.clear()
  saveError = ''
  photoSelected = none
```

- 草稿只存在内存。
- 品牌回今天、翻看打开日期都走这套逻辑。
- 切换屏幕（手账/抽屉/翻看）不缓存、不丢失当前编辑。

### 10.4 粘贴与飞入动画

1. 复制选中素材为 PlacedItem。
2. 记录素材网格中选中 tile 图区的全局矩形（用于起点）。
3. snapshot。
4. 设置默认 x/y/rotation，加入 items。
5. `screen = journal`。
6. 若类型不是 sticker，或减少动态，或找不到起点：直接 Toast 并结束。
7. 否则：
   - 目标点：纸张全局左上 + 纸张宽×item.x、纸张高×item.y。
   - 飞行元素 83×83，从素材图区中心飞到目标点。
   - 680ms，关键帧：
     - 0%：translate(0,0)，rotate 0，scale 1
     - 50%：translate(dx×0.5, dy×0.5 - 44)，rotate -15°，scale 1.12
     - 100%：translate(dx, dy)，rotate -9°，scale 1
   - 使用 Overlay 实现，飞行期间对应已贴素材不可见（`flyingId`）。
   - 动画完成后移除 Overlay、清空 `flyingId`、Toast「已贴上，按住可以移动」。
- 动画使用 `AnimationController` + `TweenSequence`；不要阻塞交互。

### 10.5 拖动算法

入参：纸张尺寸 `paperW × paperH`，元素未旋转尺寸 `itemW × itemH`，起始归一化位置 `(ox, oy)`，指针位移 `dxPx, dyPx`。

```text
newX = clamp(ox + dxPx / paperW, 0, 1 - itemW / paperW)
newY = clamp(oy + dyPx / paperH, 0, 1 - itemH / paperH)
```

- 拍立得尺寸使用实际渲染宽高（含相框/说明）；已贴素材使用 `materialSizes`。
- 旋转不参与边界计算。
- 指针按下记录起始；位移超过 2px 才 snapshot；结束清理。
- 每次移动后 `notifyListeners()`，实现实时跟手。
- 桌面端仅左键拖动；移动端单指。
- 拖动中不弹 Toast。

### 10.6 撤销

- `snapshot()`：当前 entry 深拷贝入栈；超过 15 条移除最早；`saved = false`；`saveError = ''`。
- `undo()`：栈空直接返回；`entry = history.removeLast()`；`saved = false`；Toast「已撤销上一次修改」。
- 撤销不恢复保存状态；保存后仍可撤销，撤销后按钮回到「保存」。
- 切换日期清空历史。

### 10.7 保存

1. 若 `saving` 为 true，忽略。
2. `saving = true`；清除错误；通知。
3. 将 entry 写入 `savedEntries[key]` 并持久化 JSON。
4. 成功：`saved = true`；Toast「这一页，收好了」。
5. 失败：`saved = false`；`saveError = '这一页没能保存，内容还在。请腾出一些空间后再试。'`。
6. `saving = false`；通知。
7. 保存不修改 `history`，不关闭页面。

### 10.8 操作与撤销矩阵

| 操作 | 是否 snapshot | 其他副作用 |
|---|---|---|
| 切换心情 | 是 | 更新 mood |
| 应用文字 | 是（校验通过后） | 更新 title/note |
| 上传照片 | 是（成功插入前） | 追加 item |
| 粘贴素材 | 是 | 追加 item，切页 |
| 拖动拍立得/素材 | 首次位移 >2px | 更新 x/y |
| 保存 | 否 | savedEntries 更新 |
| 撤销 | 否 | 弹栈 |
| 切换日期 | 否 | 重置 history |
| 切换页面/月份 | 否 | 无 |
| 选择素材/拍立得 | 否 | 仅 UI 选中态 |
| 关闭弹窗 | 否 | 丢弃未应用输入 |

### 10.9 Toast

- 全局单例；新消息覆盖旧消息并重置 4.2s 计时。
- 底部 177，水平居中，最大宽度约画布宽 - 40；单行优先，长文案可换行。
- 背景 toastBg，白字 13，padding `11 17`，圆角 9。
- 不阻挡点击（`IgnorePointer`）。

### 10.10 无障碍与焦点

- 所有图标按钮有 `Semantics.label`。
- 最小点击区域 44×44。
- 弹窗打开时焦点进入标题输入框；关闭后焦点回到「文字」工具按钮。
- 拍立得选中提供文字提示，不依赖颜色。
- 尊重系统字体缩放，建议限制在 0.9–1.2 倍，避免布局爆裂。
- 尊重 `MediaQuery.disableAnimations`。

---

## 11. 视觉实现细节

### 11.1 纸张点阵

```text
间距 15px
点半径 0.65px
颜色 #CFC4B8
起点 (8, 9)
```

用 `CustomPainter` 绘制，不要用图片，保证任意尺寸清晰。

### 11.2 纸纹

- 资源：`assets/textures/paper-grain.png`（180×180，透明底）或 SVG。
- 平铺整张纸，透明度 0.18。
- 放在内容最上层，`IgnorePointer`，不参与命中测试。
- 若使用 `BlendMode.multiply` 效果更接近原型；普通 alpha 叠加也可接受。

### 11.3 胶带图案

通用：

- 形状为轻微不规则四边形：`(3%,0) (98%,4%) (96%,100%) (0,95%)`。
- 默认 rotate -9°（封面装饰除外）。
- 透明度 0.85–0.86。
- 投影 1px。

| style | 视觉 |
|---|---|
| rose | 竖向条纹，5px 交替 `#C989A4` / `#ECB8CA` |
| check | 两组 8px 网格：横向透明/`#9AACC0`（40%），纵向 `#DCE4E6` / `#A7B9CD` |
| caramel | 纯色 `#DBA86F` |
| flower-tape | 底色 `#EBC3CD`，圆点 `#B96583` 半径 2，间距 13 |
| dots | 底色 `#DACB9F`，圆点 `#997E55` 半径 1.4，间距 9 |
| plain | 纯色 `#B4BFB0` |

用 `CustomPainter` 绘制条纹/圆点，避免为每种胶带准备位图。

### 11.4 便签

- 已贴便签 108×90；素材格 77×77；封面 68×69。
- 底色使用所选便签的 `color`；已贴便签默认 `#F3DEB2`（素材格颜色见 8.6）。
- 文字 17 hand，颜色 `#825846`，居中，行高 1.4，保留换行。
- 轻微 rotate -6°（已贴素材默认 -9°，以模型 rotation 为准）。
- 阴影 `1 2 3 rgba(103,76,55,0.07)`。

### 11.5 拍立得

- 白底 `#FFFEFB`。
- 图片与说明之间无额外间距，说明行高即底部留白。
- 相纸阴影见 3.5。
- 胶带条压在相纸顶部，作为独立层，不参与拖动命中之外的布局。

### 11.6 迷你页

见 9.5。确保旋转后仍在单元格内，不裁切。

### 11.7 按钮状态

- 默认透明背景。
- hover（桌面）：浅色 selected 背景或 berry 文字。
- 按下：scale 0.96。
- 禁用：透明度 0.35，不响应。
- 焦点：2px berry 外框，offset 4。
- 主按钮（保存/粘贴/写到纸上）：berry 背景，白字；hover 变 berryHover；按下缩放。

### 11.8 空状态

- 翻看无记录日期：不显示缩略图，显示「给这一天留个位置」。
- 手账空白页：无拍立得、无小票；只有标题、正文、日期角标；正文上移。
- 素材网格永远有数据，不需要空状态。
- 保存错误：Header 下方文字提示，不使用红色大横幅。

---

## 12. 响应式与平台适配

### 12.1 宽度

- 画布最大宽 390；大于 390 时居中，外层 `#EAE3E7`。
- 小于 390：
  - 手账横向 padding 16。
  - 纸张标题 23。
  - 主拍立得宽改为纸张的 62%（位置仍用归一化 x/y，不改为固定 left）；图片高 234。
  - 副拍立得宽改为纸张的 39%（位置仍用归一化 x/y）。
  - 正文 17，宽 48%，left 7%。
  - 小票 right 4%。
  - 年份文字 11。
  - 素材封面高 177，封面小花 left 45%、宽 115。
  - 网格行 gap 14 / 列 gap 9，tile 131，图区 103。
  - 月历日期格高 66。
- 所有点击目标不小于 44×44。

### 12.2 高度

- 高度 ≤800：
  - Header 高 70，上 padding 17。
  - 日期区高 85。
  - 纸张仍 510，页面滚动。
  - BottomNav 高 70。
  - 素材托盘高 80。
  - 工具条 margin-top 15。
- 键盘弹出：文字弹窗上移，画布不整体缩放。
- 不使用 `resizeToAvoidBottomInset: false`，避免输入框被遮挡。

### 12.3 安全区

- 手机端顶部/底部加 SafeArea。
- 状态栏背景 appBg，深色图标。
- 底部导航在 iPhone home indicator 之上增加底部 padding。

### 12.4 主题

- 固定浅色，不随系统深色切换。
- 文本选择色 pink，光标 berry。
- 系统字体缩放限制 0.9–1.2。

---

## 13. 原型怪癖与实现决策

| # | 原型行为 | 决策 |
|---|---|---|
| 1 | “今天”写死 2026-10-04 | 保留为演示模式；提供 `USE_REAL_TODAY` 编译开关 |
| 2 | 翻看默认 2026-09、选中 27 | 保留，保证首屏与截图一致 |
| 3 | 保存后月历缩略图一律变咖啡照片 | **修正**：按实际照片/主图/便签/贴纸内容生成（9.6） |
| 4 | 按下拍立得就产生撤销点，即使没拖动 | **修正**：位移 >2px 才产生撤销点 |
| 5 | 保存是同步的，看不到“保存中” | 改为异步，展示 saving 状态 |
| 6 | 无删除、缩放、旋转、图层调整 | 非目标，不实现 |
| 7 | 草稿只在内存，刷新丢失 | 保留；可选在 `AppLifecycleState.paused` 时自动落盘草稿 |
| 8 | 上传照片以 base64 存 localStorage | **修正**：文件存应用文档，JSON 存路径 |
| 9 | 下月上限写死 2026-10 | 由 `AppClock` 推导 |
| 10 | 拍立得拖动时旋转角固定 | 保留 |
| 11 | 工具条有 hover 背景 | 仅桌面/鼠标 hover 生效，移动端无持久高亮 |
| 12 | URL query 参数控制初始页/分类 | Flutter 不需要；可选 `--dart-define` 调试参数 |
| 13 | 网页无加载态 | 种子本地读取，直接进入；如异步读取，用同色空白页避免闪烁 |
| 14 | 保存后撤销仍可继续 | 保留；撤销后 saved 置 false |
| 15 | 已贴便签一律显示黄色，丢失素材格颜色 | **修正**：贴入时保留所选便签的 `color` |

---

## 14. 实施顺序

1. 工程脚手架、依赖、资产注册、颜色/字号/尺寸 token。
2. 模型、种子加载、`EntryStore`（读写 + 损坏回退）。
3. `DiaryController`：条目、草稿、历史、保存、Toast、屏幕状态。
4. Shell、底部导航、全局 Toast。
5. 手账页静态视觉：Header、日期区、纸张、拍立得、小票、正文、工具条。
6. 手账页交互：心情、文字弹窗、照片上传、撤销、保存。
7. 素材抽屉：Tab、封面、网格、托盘、选择逻辑。
8. 粘贴 + 贴纸飞入 + 已贴素材渲染。
9. 拖动：拍立得与已贴素材、边界、撤销阈值。
10. 翻看页：月历、迷你页、摘要卡、月份限制、打开日期。
11. 响应式、无障碍、减少动态、字体回退。
12. 测试、golden、真机自测、性能检查。

每完成一步运行一次 `flutter analyze`，第 3 步后开始补单元测试。

---

## 15. 验收标准

### 15.1 功能

- [ ] 启动后显示 2026-10-04「有风的下午」，两张拍立得、天气小票、正文、心情「好心情」。
- [ ] 点击心情在「好心情 / 被治愈了」间切换，图标同步；撤销可恢复。
- [ ] 文字弹窗可编辑标题（≤10）与正文（≤75），空值不能提交；应用后纸面更新。
- [ ] 照片上传成功插入，失败/取消有正确反馈；大图被压缩到最长边 700。
- [ ] 四类素材均可贴入，落点符合默认坐标；贴纸有飞入动画；贴入后自动回手账页。
- [ ] 拍立得与已贴素材均可拖动，不能拖出纸张；拖动后撤销可回到拖动前位置。
- [ ] 撤销最多 15 步；切换日期后清空；无历史时按钮禁用。
- [ ] 保存后按钮显示「已保存」并 Toast；重启应用后内容恢复。
- [ ] 翻看默认 2026-09、选中 27 日、显示 17 天。
- [ ] 月历正确显示有记录/无记录/未来日期；未来日期不可选，下月不超过 2026-10。
- [ ] 点击任意过去日期可进入当天手账；无记录日期显示空白页模板。
- [ ] 在翻看打开 9 月 27 日可看到「周末，去河边走走」及两张照片。
- [ ] 保存某天后，月历缩略页与摘要卡立即更新。
- [ ] 素材分类切换、滑块动画、数量文案、封面装饰均正确。
- [ ] 贴纸/胶带/便签/照片的视觉与参考图一致。

### 15.2 视觉

- [ ] 颜色 Token 与 3.1 一致。
- [ ] 纸张点阵、纸纹、打孔、阴影可见且不干扰操作。
- [ ] 拍立得、胶带、便签、小票的旋转与层级正确。
- [ ] 390×844 下无溢出；320×700 下可滚动且所有按钮可点。
- [ ] 字体回退后仍保持手写/衬线的风格区分。
- [ ] Toast 位置在底部导航上方，不遮挡主操作。

### 15.3 数据与健壮性

- [ ] `shared_preferences` 内容损坏时回退空表，不崩溃。
- [ ] 上传照片重启后仍可显示（不是临时路径）。
- [ ] 条目 JSON 往返字段完整，未知字段不导致崩溃。
- [ ] 快速重复点击保存不会并发写入。
- [ ] 大量素材（如 20 个）拖动、滚动仍流畅。

### 15.4 无障碍

- [ ] 所有图标按钮有语义标签。
- [ ] 点击目标不小于 44×44。
- [ ] 键盘/读屏可完成：切换心情、打开素材、贴入、编辑文字、保存。
- [ ] 开启“减少动态”后无飞入、无入场动画。
- [ ] 文本缩放 1.2 倍下无严重裁切。

---

## 16. 测试计划

### 16.1 单元测试

1. `key(2026, 9, 7) == '2026-09-07'`。
2. 2026-09-01 是周二 → 月历前导空格 1；9 月 30 天；总单元格 31。
3. `isFuture(2026-10-04) == false`；`isFuture(2026-10-05) == true`。
4. 2026-09 合并种子后 17 条；2026-10 为 4 条；其他月份 0。
5. 保存条目覆盖同日期种子，不重复计数。
6. `snapshot` 超过 15 条时丢弃最早；`undo` 后 `saved == false`。
7. 拖动边界：元素宽 124、纸宽 350 时，x 最大 `1 - 124/350`。
8. 便签文字映射含换行的 4 个特殊名称。
9. `DiaryEntry` JSON 往返（含上传照片路径、items、位置、角度）。
10. 默认条目字段与 5.3 一致。

### 16.2 Widget 测试

1. 首屏显示日期、标题、两张拍立得、正确心情。
2. 点击心情 → 文案与图标变化；撤销恢复。
3. 素材页选贴纸 → 贴到手账 → 回到手账且 items +1；撤销移除。
4. 文字弹窗：空标题/空正文不可提交；合法输入应用后纸面更新。
5. 翻看页：未来日期 `onTap == null`；点击 9/27 打开正确标题。
6. 保存按钮：保存后显示「已保存」；修改后回到「保存」。
7. 素材分类切换显示正确标题、数量与素材数量。
8. 减少动态时贴纸直接出现，不创建 Overlay。

### 16.3 Golden 测试（建议）

- `journal_initial_390x844.png`
- `drawer_sticker_390x844.png`
- `month_2026_09_390x844.png`
- 容差 1–2%；字体差异可单独标记为平台差异。

### 16.4 手工验收

- 真机 iOS / Android 各一轮。
- 相册权限拒绝、取消选择、超大图、损坏图。
- 输入法弹起、横竖屏切换（锁定竖屏则验证不旋转）。
- 开启系统减少动态、放大字体。
- 保存 10 天以上数据后重启，检查月历与缩略页。
- 低端机滚动与拖动帧率。

---

## 17. 非目标

明确不做：

- 账号、登录、云同步、多设备。
- 分享、导出图片/PDF、打印。
- 删除素材、缩放、自由旋转、图层顺序、复制粘贴。
- 富文本、字体选择、颜色选择。
- 多语言、深色模式。
- 真实天气接入（小票是装饰）。
- 提醒、打卡、统计图表。
- Web / 桌面正式交付。
- 从原网页动态抓取素材。

这些可以作为后续版本，但不要混入本次实现。

---

## 附录 A：资产清单

### A.1 贴纸 `assets/stickers/`

| 文件 | 名称 |
|---|---|
| `flower.svg` | 小花开了 |
| `puppy.svg` | 小狗朋友 |
| `coffee.svg` | 一杯慢慢喝 |
| `bow.svg` | 蓝色蝴蝶结 |
| `toast.svg` | 面包脑袋 |
| `orange.svg` | 橘子好甜 |

### A.2 照片 `assets/photos/`（均为 760×1140 WebP）

| 文件 | 名称 |
|---|---|
| `cafe.webp` | 巷子里的面包店 |
| `dog.webp` | 路过的小朋友 |
| `picnic.webp` | 草地上的小野餐 |
| `flowers.webp` | 买了一束花 |

### A.3 纹理 `assets/textures/`

| 文件 | 用途 |
|---|---|
| `paper-grain.svg` | 原始纸纹（180×180） |
| `paper-grain.png` | 已转好的透明底平铺图，Flutter 推荐直接用 |

### A.4 图标 `assets/icons/`

`i-book.svg`、`i-drawer.svg`、`i-calendar.svg`、`i-photo.svg`、`i-sticker.svg`、`i-tape.svg`、`i-type.svg`、`i-chevron.svg`、`i-check.svg`、`i-close.svg`、`i-undo.svg`、`i-heart.svg`、`i-sun.svg`。

均为 24×24 viewBox、线性描边；使用 `flutter_svg` 并通过 `ColorFilter` 着色。也可以用 Material Icons 近似，但图标形状会与原稿有差异。

### A.5 种子与参考

- `seed/materials.json`
- `seed/entries.json`
- `reference/01-journal.png`
- `reference/02-drawer-stickers.png`
- `reference/03-drawer-tapes.png`
- `reference/04-drawer-notes.png`
- `reference/05-drawer-photos.png`
- `reference/06-month.png`

---

## 附录 B：pubspec 资产注册

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/stickers/
    - assets/photos/
    - assets/textures/
    - assets/icons/
    - assets/seed/
  # fonts: 见 3.2，可选
```

如果种子文件放在 `assets/seed/` 之外（例如 `lib/seed/`），相应调整加载方式。

---

## 附录 C：关键常量速查

### C.1 位置（归一化）

| 元素 | x | y |
|---|---|---|
| 主拍立得 | 0.0714 | 0.1588 |
| 副拍立得 | 0.5657 | 0.5431 |
| 贴纸粘贴 | 0.72 | 0.48 |
| 胶带粘贴 | 0.35 | 0.59 |
| 便签粘贴 | 0.57 | 0.61 |
| 照片粘贴 | 0.52 | 0.49 |
| 上传照片 | 0.45 | 0.45 |
| 种子贴纸封面元素 | 0.55 | 0.33 |

### C.2 文本限制

| 字段 | 上限 |
|---|---|
| 标题 | 10 字符 |
| 正文 | 75 字符 |
| 长正文阈值 | >30 字符或 >3 行 |

### C.3 时间

| 项 | 值 |
|---|---|
| Toast 停留 | 4200ms |
| 纸张入场 | 420ms |
| 贴纸飞入 | 680ms |
| Tab 滑块 | 240ms |
| 按钮按压 | 180ms |
| 首次入场保护 | 600ms |

### C.4 计数

| 项 | 值 |
|---|---|
| 2026-09 种子 | 17 天 |
| 2026-10 种子 | 4 天 |
| 每类素材 | 贴纸 6 / 胶带 6 / 便签 6 / 照片 4 |
| 撤销上限 | 15 |
| 默认月 | 2026-09 |
| 默认选中 | 27 |
| 演示今天 | 2026-10-04 |

### C.5 存储

| 项 | 值 |
|---|---|
| 偏好 key | `shiye-entries-v1` |
| 照片目录 | `<ApplicationDocuments>/photos/` |
| 日期 key 格式 | `YYYY-MM-DD` |

---

## 附录 D：种子 JSON 字段示例

```json
{
  "2026-09-27": {
    "year": 2026,
    "month": 9,
    "day": 27,
    "weekday": "星期日",
    "mood": "好心情",
    "title": "周末，去河边走走",
    "note": "走了很远，\n心情也轻了一点。",
    "basePhotos": true,
    "mainSrc": "assets/photos/dog.webp",
    "mainCaption": "偶遇一位小朋友",
    "sideSrc": "assets/photos/picnic.webp",
    "sideCaption": "午后，慢一点",
    "mainPosition": { "x": 0.0714, "y": 0.1588 },
    "sidePosition": { "x": 0.5657, "y": 0.5431 },
    "items": [],
    "type": "dog",
    "coverText": "晴天"
  }
}
```

```json
{
  "id": "rose",
  "name": "莓果条纹",
  "kind": "tape",
  "style": "rose"
}
```

```json
{
  "id": "flower",
  "name": "小花开了",
  "kind": "sticker",
  "src": "assets/stickers/flower.svg"
}
```

```json
{
  "id": "note-2",
  "name": "今日份开心",
  "kind": "note",
  "text": "今日份\n开心",
  "color": "#EAD2DF"
}
```

---

## 附录 E：常见实现错误

1. 把 `x/y` 当成像素使用。必须乘以纸张宽高。
2. 用 `DateTime.now()` 初始化，导致首屏不是 2026-10-04。
3. 把上传照片存成临时路径，重启后图片丢失。
4. 拖动时不限制边界，素材飞出纸张。
5. 保存后不更新 `saved` 状态，按钮一直显示「保存」。
6. 把撤销快照放在每次 `onPanUpdate`，导致一次拖动产生几十步历史。
7. 把纸纹层放在内容下方，导致纸张质感消失。
8. 用整张截图做背景，文本无法编辑、缩放模糊。
9. 素材贴入后不切回手账页，用户看不到结果。
10. 月历周日起始，导致 2026-09 的 1 日位置错误。
11. 保存条目覆盖月历时丢掉便签/贴纸样式。
12. 文字弹窗不处理键盘，输入框被遮挡。
13. 忽略 `MediaQuery.disableAnimations`。
14. 在 Android 上依赖 `Kaiti SC`，没有回退字体。
