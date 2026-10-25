# app_demo 案例代码规范

> 适用范围：`lib/app_demo/` 下所有编号案例。
>
> 参考实现：[APP-14 聚会游戏盒](../lib/app_demo/14/docs/README.md)（完整分层、动效、持久化与测试）、[APP-15 新案例](../lib/app_demo/15/app_15.dart)（最小起步模板）。
>
> 最后更新：2026-10-25

---

## 1. 基本原则

1. **案例自包含**：每个案例都能脱离其他案例独立运行，不引用另一个 `app_demo/NN` 的业务代码。
2. **先正确，再好看**：先保证状态、导航、退出、重来都正确，再投入动效和视觉细节。
3. **优先 SDK 能力**：能使用 Flutter 自带能力完成时，不新增第三方依赖；确需新增时说明收益与替代方案。
4. **不虚构能力**：没有实现的声音、传感器、联网、历史记录等，不展示为可用入口或开关。
5. **如实记录状态**：文档和提交说明只描述已经实现并验证过的行为。
6. **零告警交付**：提交前 `flutter analyze` 无 error/warning；新增代码不引入新的 info 级 lint 告警。

---

## 2. 目录结构

### 2.1 最小案例

单页、无独立状态层的小案例可以只保留必要文件：

```text
lib/app_demo/15/
├── app_15.dart
├── screens/
│   └── home_screen.dart
└── widgets/
    └── theme/
        └── app_15_theme.dart
```

### 2.2 完整案例

存在多页面、回合状态、自定义绘制或持久化时，按职责展开：

```text
lib/app_demo/NN/
├── app_NN.dart                    # 应用壳：主题、初始化、依赖注入、导航边界
├── docs/
│   └── README.md                  # 已交付行为、代码组织、验证方式
├── models/
│   ├── xxx_state.dart             # 不可变页面状态
│   ├── rules/                     # 纯规则，不依赖 Widget / BuildContext
│   ├── view_models/               # ChangeNotifier 回合与设置状态
│   ├── repositories/              # 持久化封装
│   └── services/                  # 随机、反馈、存储等可替换边界
├── screens/
│   ├── home_screen.dart
│   ├── feature_screen.dart
│   └── navigation/                # 集中式路由与内部返回边界
└── widgets/
    ├── theme/                     # 色板与 ThemeData
    ├── motion/                    # 动效时长与曲线
    └── feature/                   # 页面局部组件、绘制器
```

规则：

- 不创建空目录占位；没有对应职责就不建。
- 单个文件只承担一类职责，不把页面、规则和 Painter 堆在同一个文件里。
- 通用组件先留在案例内；被两个以上案例真实复用后再考虑提到共享目录。
- 文档、任务书与交付代码分开存放，不把规划文档混进 `screens/` 或 `models/`。

---

## 3. 命名规范

| 类型 | 规则 | 示例 |
| --- | --- | --- |
| 案例目录 | 两位编号 | `01`、`14`、`15` |
| 文件名 | `snake_case.dart` | `coin_screen.dart`、`dice_view_model.dart` |
| 应用壳 | `AppNN` | `App14`、`App15` |
| 页面 | `<功能>Screen`；跨案例可能重名时加 `AppNN` 前缀 | `CoinScreen`、`App15HomeScreen` |
| 状态模型 | `<功能>State` | `CoinState`、`DiceState` |
| 纯规则 | `<功能>Rules` | `CoinRules`、`DiceRules` |
| ViewModel | `<功能>ViewModel` | `SettingsViewModel` |
| 仓库 | `<功能>Repository` | `SettingsRepository` |
| 服务 | `<功能>Service` 或 `<能力>Source` | `FeedbackService`、`RandomSource` |
| 主题 | `<案例>Theme` | `PartyTheme`、`App15Theme` |
| 动效配置 | `MotionSpec` | `MotionSpec` |
| 私有组件 | `_PascalCase` | `_ResultArea`、`_CloseButton` |
| 测试 Key | 小写短横线字符串 | `app-15-home`、`coin-trigger` |
| 测试文件 | `test/app_demo/NN/<模块>_test.dart` | `coin_screen_test.dart` |

命名要求：

- 标识符使用英文，UI 文案使用中文；不要用拼音缩写命名类和变量。
- 页面组件不可用 `Page`、`Widget` 等泛化后缀凑数，名称要表达业务身份。
- 同一仓库内避免重名；确实需要时用 `AppNN` 前缀限定。
- 不以列表下标作为状态身份，使用稳定 `id` 或 `roundId`。

---

## 4. 应用壳与 Showcase 注册

### 4.1 应用壳

每个案例提供且只提供一个根 Widget：

```dart
class App15 extends StatelessWidget {
  const App15({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '新案例',
      theme: App15Theme.theme,
      home: const App15HomeScreen(),
    );
  }
}
```

要求：

- **不创建独立 `main()`**；由 Showcase 的 `main.dart` 统一启动。
- `MaterialApp` 留在 `AppNN` 内，主题来自案例自己的 Theme 类。
- 应用壳只做组合、初始化、依赖注入和导航边界，不承载页面业务逻辑。
- 需要异步初始化时，先展示明确的加载态，再进入首页；不要让首帧空白或抛异常。
- 可注入依赖通过构造函数暴露（随机源、反馈、存储、设置），默认值在壳内创建。

### 4.2 注册到 Showcase

在 [`lib/main.dart`](../lib/main.dart) 中补充导入和列表项：

```dart
import 'package:flutter_x_widgets/app_demo/15/app_15.dart';

AnimationExample(
  title: 'APP-15(新案例)',
  builder: (context) => const App15(),
  appbarColor: Colors.black,
  isFullScreen: true,
),
```

要求：

- 标题格式固定为 `APP-NN(中文名)`，与目录编号一致。
- Demo App 默认 `isFullScreen: true`，避免 Showcase 的 AppBar 与案例自身头部重复。
- 新增条目后同步检查首页网格的 Hero tag、入口数量与返回行为。

---

## 5. 分层职责

依赖方向固定为：

```text
View → ViewModel → Domain / Repository → Service
```

不允许反向依赖：规则层不 import Widget，服务层不感知页面状态。

| 层 | 负责 | 不负责 |
| --- | --- | --- |
| View | 布局、手势、`AnimationController`、局部重绘、导航 | 抽签规则、持久化、回合状态真值 |
| ViewModel | 不可变状态、回合开始/结束、输入校验、`roundId` | 逐帧动画、`BuildContext`、`Ticker` |
| Domain | 纯函数规则、随机结果组合、题卡去重 | Widget、存储、平台反馈 |
| Repository | 序列化、schema、读取失败回退 | 页面文案与动画 |
| Service | 随机源、震动、偏好存储等可替换边界 | 业务决策 |

约束：

- 状态字段全部 `final`，状态对象不可变；切换状态时整体替换。
- ViewModel 只在阶段切换时 `notifyListeners()`，不按帧通知。
- 动画进度、按下缩放、拖动位移属于 View 的表现状态，不写进 ViewModel。
- 随机结果在开始回合时一次性确定；UI 在揭晓前不读取待揭晓结果。
- 每次回合使用递增 `roundId`；动画、异步回调、反馈都校验 ID，过期事件直接忽略。
- 先锁定状态再发起异步操作；运行中重复点击只允许产生一次回合。
- `AnimationController` 必须在 View 的 `State` 中创建、在 `dispose()` 中释放。

---

## 6. 动效规范

1. **时长集中管理**：新增动效时长写入案例的 `MotionSpec`，不要在页面里散落魔法数字。
2. **三档行为一致**：标准、快速、减少动态共用同一条时间轴；快速模式只压缩时长，不改变状态顺序。
3. **系统设置优先**：系统开启“减少动态效果”时，即使应用内开关关闭，也必须切换为短淡入方案。
4. **减少动态不等于零时长**：仍要保留清晰的状态变化和结果出现，不把整个流程变成瞬间跳变。
5. **取消安全**：使用 `controller.forward().orCancel`，捕获 `TickerCanceled`；页面销毁或切后台后不再提交完成事件。
6. **生命周期**：
   - 切后台时，随机类回合直接结算已确定的结果，不重抽、不补震动。
   - 返回/关闭页面时立即停止动画和计时器，不等待路由转场结束。
   - 页面不可见或被其他路由覆盖时，暂停环境动画（参考 `MenuMeteorBackground`）。
7. **副作用边界**：禁止在 `build`、`paint` 中抽随机数、触发震动或写存储。
8. **性能**：
   - 逐帧变化用 `AnimatedBuilder` + `CustomPainter(repaint: ...)`，不要每帧重建整页。
   - 复杂自绘放在 `RepaintBoundary` 内；`shouldRepaint` 只比较真正影响绘制的字段。
   - 文字排版结果可缓存时缓存，不在每帧重新 `TextPainter.layout()`。
   - 环境动画设置上限（星点、粒子、流星），并在不可见时停止。

---

## 7. 主题与视觉

### 7.1 主题集中

每个案例提供独立主题类，集中定义背景、表面、强调色、文字色、字体与 `ThemeData`：

- 参考 [`party_theme.dart`](../lib/app_demo/14/widgets/theme/party_theme.dart) 与 [`app_15_theme.dart`](../lib/app_demo/15/widgets/theme/app_15_theme.dart)。
- 页面中不重复硬编码同一颜色；需要透明度时用 `withValues(alpha: ...)`。
- 避免直接使用 Material 默认紫色作为最终视觉。

### 7.2 字体

- 展示标题优先使用项目自带 `NeumaticGothic-Black`（仅拉丁字符、单一字重，避免合成加粗）。
- 中文正文与说明使用 `SF Pro Display`。
- 测试涉及标题宽度或基线时，先加载真实字体（参考 [`test/app_demo/14/support/fonts.dart`](../test/app_demo/14/support/fonts.dart)）。

### 7.3 布局基线

- 使用逻辑像素和布局约束，不照搬设计稿物理像素。
- 页面内容最大宽度约 `600`，常用水平边距 `20`，按钮最小高度 `52`，圆角约 `18`。
- 可点击目标不小于 `48×48`；图标按钮通过 `constraints` 或 `SizedBox` 保证热区。
- 使用 `SafeArea`，底部操作区避让 Home 指示条。
- 低高度、横屏、大字体时允许滚动；不通过缩小可点击区域强行塞入。
- 固定舞台比例的位置换算要基于实际可用空间，不假设某一机型尺寸。

### 7.4 素材

- 案例素材放在 `assets/images/NN/`，并在 `pubspec.yaml` 注册目录。
- 图片按逻辑尺寸占位，等比完整显示；加载失败必须有回退图标或占位。
- 不引用不存在的网络素材，不复制参考产品中的品牌标识或专有素材。

---

## 8. 可访问性与反馈

- 所有可操作元素提供 `Semantics` 的 `button`、`enabled` 和可读标签。
- 结果只在真正揭晓后通过 `liveRegion` 播报一次；动画过程中不重复播报。
- 隐藏内容同时使用 `IgnorePointer`、`ExcludeSemantics`，需要时加 `ExcludeFocus`，避免残留焦点和误触。
- 纯装饰的圆环、光晕、背景粒子使用 `IgnorePointer` / `ExcludeSemantics`。
- 图标按钮提供 `tooltip`；返回、关闭等系统语义保持一致。
- 震动是可选项：通过注入的 `FeedbackService` 调用，失败或平台不支持时静默降级，不影响回合。
- 震动开关关闭时不得调用反馈服务；测试需覆盖该分支。
- 键盘和读屏可操作：菜单分页提供滚动语义，必要时支持左右方向键。

---

## 9. 导航规范

1. **集中路由**：多页面案例使用集中式路由工厂（参考 [`demo_routes.dart`](../lib/app_demo/14/screens/navigation/demo_routes.dart)），不在页面里散落字符串路由。
2. **未知路由**：必须返回明确的错误页面，并提供回到案例首页的按钮。
3. **内部边界**：案例内部导航与 Showcase 宿主导航分开；无宿主可返回时，首页返回按钮应禁用而不是假响应。
4. **防重入**：打开页面前加锁，`await Navigator.push` 结束后解锁，避免连点叠开多个相同页面。
5. **系统返回**：使用 `PopScope` 协调内部返回与宿主退出；返回时停止本页动画、计时器和反馈。
6. **首页静止**：停留在案例首页时，不运行游戏回合动画或持续计时。
7. **状态保留**：返回首页时保留当前菜单页码等轻量浏览状态，但活跃回合不恢复。

---

## 10. 持久化规范

- 每个案例使用独立 storage key：`party_box.demoNN.<feature>`，不与其他案例共享。
- 存储内容带 schema 版本；读取时校验类型与版本。
- 读取失败、字段缺失或类型损坏时回退默认值，并给出非阻断提示，不因存储异常导致启动失败。
- 保存失败时保留内存中的当前设置，提供重试入口；不要回滚用户刚做的选择。
- 写入串行执行，避免并发覆盖；初始化期间的本地修改不被异步读取覆盖。
- 不持久化瞬时回合结果、动画进度和历史记录，除非产品明确要求。
- View 不直接调用 `SharedPreferences`；通过 `Repository` + 可注入的 `PreferencesService` 访问。
- 测试使用 `SharedPreferences.setMockInitialValues({})` 或内存实现，不依赖真实平台插件。

---

## 11. 测试规范

### 11.1 位置与分层

```text
test/
├── app_NN_test.dart                 # 入口冒烟：注册、首屏、主流程
└── app_demo/NN/
    ├── support/                     # 字体、固定随机源等测试支撑
    ├── <feature>_rules_test.dart     # 纯规则
    ├── <feature>_view_model_test.dart
    ├── <feature>_screen_test.dart    # 页面状态、手势、读屏
    └── <feature>_motion_test.dart    # 轨迹与关键帧
```

### 11.2 编写要求

- 规则测试使用固定随机序列，断言合法范围、合计、奇偶、连续朝向等。
- ViewModel 测试覆盖：状态锁定、重复触发、过期 `roundId`、后台结算、销毁后不通知。
- Widget 测试覆盖：首屏状态、按钮三态、结果与状态一致、导航、返回、未知路由、防重入。
- 涉及排版时加载项目字体；只依赖方块字体会让宽度、换行、基线断言失真。
- 用稳定的 `ValueKey` 定位关键节点，避免同文案出现多处时误匹配。
- 每个页面测试结束前销毁 Widget（如 `pumpWidget(const SizedBox())`），确认没有 ticker 或销毁后更新异常。
- 环境动画、无限循环动画场景避免无界 `pumpAndSettle()`，改用有界 `pump(duration)` 断言关键帧。
- 至少覆盖一次小屏 + 大字体 + 横屏组合，确认无 overflow。
- 不把未执行的测试称为通过；缺少模拟器或真机时如实说明。

### 11.3 必测清单

- [ ] 规则纯函数的边界与非法输入
- [ ] 回合锁定、结果预确定、过期回调
- [ ] 页面销毁与路由返回的资源释放
- [ ] 系统减少动态与快速模式
- [ ] 切后台结算，不重抽、不补反馈
- [ ] 关闭震动后不调用反馈服务
- [ ] 读屏只在揭晓时播报
- [ ] 小屏、横屏、大字体无溢出
- [ ] 未知路由与内部/宿主返回边界

---

## 12. 代码风格

- 2 空格缩进，行宽 140，保存时格式化。
- 字符串优先单引号；常量能 `const` 就 `const`。
- 跨目录导入使用 `package:flutter_x_widgets/app_demo/NN/...`；不要混用相对导入和包导入表达同一依赖。
- 公共可复用组件写简洁 Dart 文档；普通页面代码不写“是什么”的注释，只在约束、坑点、非显然原因处写“为什么”。
- 不使用 `print`；调试信息通过测试断言或临时断点验证。
- 不保留未使用代码、注释掉的旧实现或空壳入口。
- UI 文案中文，标识符英文；同一概念在全案例使用同一名称。
- 避免给简单计算强行套 Repository、接口或抽象基类。
- 新增依赖前检查项目是否已有等价能力；不在仓库中再引入第二套路由或状态管理框架。
- `dart format` 只作用于本次新增/修改的文件；不要顺手格式化整个历史文件，以免产生与需求无关的大 diff。

---

## 13. 文档与交付

### 13.1 案例文档

多页面、含状态机/动效/持久化的案例必须提供 `lib/app_demo/NN/docs/README.md`，建议包含：

1. 当前阶段与交付范围
2. 已实现行为（按页面或状态描述）
3. 明确不包含的能力
4. 代码组织与关键文件
5. 运行与验证命令
6. 测试覆盖与未验证项
7. 后续计划（如分批交付）

要求：

- 只记录真实行为，不把计划写成已实现。
- 行为变化时同步更新文档；任务书与交付 README 分开维护，不完全重写任务书。
- 简单案例可以不写 README，但入口文件或主题文件应有简短说明。

### 13.2 交付检查清单

- [ ] 案例在 Showcase 中正确注册，标题为 `APP-NN(中文名)`
- [ ] 无独立 `main()`，应用壳命名与目录编号一致
- [ ] 主题集中，无散落颜色和字体硬编码
- [ ] 状态不可变，回合锁定与 `roundId` 校验完整
- [ ] 动效时长进入 `MotionSpec`，减少动态生效
- [ ] Controller、Timer、Observer 全部释放
- [ ] 切后台、返回、连点、未知路由行为明确
- [ ] 可点击目标 ≥ 48，读屏标签与结果播报正确
- [ ] 规则、ViewModel、页面、生命周期测试齐全
- [ ] `flutter analyze` 零新增告警，相关测试通过
- [ ] 案例文档与实际实现一致

---

## 14. 常见反模式

| 反模式 | 正确做法 |
| --- | --- |
| 一次创建多个空壳页面 | 完成一个入口再启用一个入口 |
| 未开放入口仍可点击进入空白页 | 明确禁用并标注“未开放” |
| 在 `build` / `paint` 中抽随机数或触发震动 | 在回合开始时确定结果，反馈由回调触发 |
| ViewModel 持有 `AnimationController` | Controller 放在 View 的 `State` |
| 每帧 `notifyListeners()` | 只在阶段切换时通知，逐帧交给动画 |
| 页面销毁后仍 `setState` | 取消动画并检查 `mounted` / 已销毁标志 |
| 用列表下标代表参与者或题目身份 | 使用稳定 `id` |
| 动画完成回调不校验回合 | 所有异步回调校验 `roundId` |
| 直接读写 `SharedPreferences` | 通过 Repository 与可注入 Service |
| 无限循环动画场景使用无界 `pumpAndSettle()` | 使用有界 `pump` 并断言关键帧 |
| 顺手格式化整个旧文件 | 只格式化本次改动文件 |
| 新增第二套路由/状态框架 | 沿用案例现有 Navigator + ChangeNotifier |

---

## 15. 最小模板

新建 `lib/app_demo/NN` 时，至少包含：

```dart
// lib/app_demo/NN/app_NN.dart
import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/NN/screens/home_screen.dart';
import 'package:flutter_x_widgets/app_demo/NN/widgets/theme/app_NN_theme.dart';

class AppNN extends StatelessWidget {
  const AppNN({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '案例名称',
      theme: AppNNTheme.theme,
      home: const AppNNHomeScreen(),
    );
  }
}
```

```dart
// lib/app_demo/NN/widgets/theme/app_NN_theme.dart
import 'package:flutter/material.dart';

abstract final class AppNNTheme {
  static const background = Color(0xFF121218);
  static const surface = Color(0xFF1D1D26);
  static const accent = Color(0xFF7BD4C8);
  static const chalk = Color(0xFFF3EEE6);
  static const muted = Color(0xFFA7A3B3);

  static ThemeData get theme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(primary: accent, surface: surface),
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'SF Pro Display'),
  );
}
```

对应入口测试：

```dart
// test/app_demo/NN/app_NN_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_x_widgets/app_demo/NN/app_NN.dart';
import 'package:flutter_x_widgets/main.dart';

void main() {
  testWidgets('App NN opens its home screen', (tester) async {
    await tester.pumpWidget(const AppNN());
    await tester.pumpAndSettle();
    expect(find.text('案例名称'), findsOneWidget);
  });

  test('App NN is registered in the showcase', () {
    expect(
      HomeScreen().demoApps.singleWhere((example) => example.title == 'APP-NN(案例名称)').isFullScreen,
      isTrue,
    );
  });
}
```

将占位名称、编号、颜色与文案替换为真实案例信息后，再按第 13.2 节逐项检查。
