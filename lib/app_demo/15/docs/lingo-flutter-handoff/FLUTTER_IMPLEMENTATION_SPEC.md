# Pip 英语学习 · Flutter 实现规格

> 版本：1.0（2026-10-25）  
> 依据：`prototype/` 中已通过回归测试的 Web 原型  
> 设计基准：390 × 844 竖屏，逻辑像素 1:1  
> 目标：用 Flutter 原生实现同样的产品逻辑与视觉语言，**不要使用 WebView，不要把 HTML/CSS 直接搬进来**。

---

## 0. 一句话目标

实现一个离线可用的移动端英语学习 App：学习路径 + 两种题型 + 课后结算 + 复习词卡 + 成就 + 个人目标。所有业务状态本地持久化，所有演示数据从状态实时计算。

### 必须保留的产品事实

1. 单元有 3 个可玩关卡，严格按 `点杯咖啡 → 问个方向 → 单元挑战` 解锁。
2. 题型有两种：选词填空、听音选图；咖啡课、问路课、挑战里都必须出现听音题。
3. 今日学习分钟、连续天数、复习掌握、成就进度、个人页统计全部由状态推导，不写死。
4. 正确率 = 本轮首答正确数 ÷ 本轮总题数，**没有 4 题基线**；答错后重试成功不会恢复正确率。
5. 中途退出保留进度；返回学习路径时显示「继续这一课」和已完成题数；复习词卡返回复习首页，不强制回到咖啡主题。

### 非目标

- 不做登录、后端、支付、推送、多单元课程、排行榜。
- 不接真实词典或在线语音服务；发音使用本地 WAV + 系统 TTS。
- 不实现 Web 版的 URL 参数；但建议保留等价的 `AppLaunchConfig` 供测试和截图。
- 不做横屏专属布局；竖屏优先，平板最大内容宽度 430。

---

## 1. 视觉与交互基准

打开 `prototype/index.html` 可交互对照；`reference/` 是 390×844 的静态截图；`design_tokens.json` 是色值、字号、圆角、阴影和地图坐标。发生冲突时：

1. 业务规则以本文为准。
2. 视觉细节以 `prototype/` 和 `reference/` 为准。
3. 文案以 `data_seed.json` 和本文第 9 节为准。

### 1.1 设计语言

- 奶油纸底 `#FFFEF8`，墨色描边 `#242522`，亮黄主色 `#FFD83D`，薄荷绿完成态 `#B9EADD`，珊瑚红错误态 `#F47861`。
- 所有卡片/按钮都是 **2px 墨色描边 + 无模糊硬阴影**（offset 3–8px），不要用 Material elevation 的柔和阴影。
- 圆角偏大：按钮 18，卡片 18–22，底部反馈面板 28，弹窗 24。
- 字体：Nunito 可变字重（`assets/fonts/Nunito.ttf`），中文回退 `PingFang SC / Noto Sans CJK SC`。标题用 900–1000 字重，正文 700–800。
- 图标是粗描边手绘风；使用 `assets/icons/*.svg` + `flutter_svg`，或 Material Icons 中形态接近的图标。图标按钮必须是 44–48 的点击区域。
- 动效短、可中断：按压 100ms，反馈面板升起 280ms，弹窗 180ms。`MediaQuery.disableAnimations` 为 true 时全部跳过（撒花、彩带、飞词动画、连击弹跳）。

### 1.2 硬性视觉规则

- 页面底色是 paper，不是灰色；灰色只用于 App 外部/平板留白。
- 主按钮：黄底、2px 墨边、18 圆角、高 58（列表页可 53）、阴影 `0 6px 0 ink`；按下时整体下移 3–5，阴影收缩到 1–2。
- 次按钮：paper 底、2px 墨边、阴影 `0 4px 0 #D9DBD0`；按下阴影收缩。
- 禁用主按钮：`#EEEEE5` 底、`#8B8E80` 文字、`#D5D8CB` 阴影，不能靠整体 opacity 变淡。
- 禁用答题选项：未选中的文字变灰，选中项保持清晰；听音题禁止出现“选中项也变淡”的 bug。
- 反馈面板从底部升起并占据底部区域；正确是薄荷绿，错误是浅珊瑚色。
- 所有页面进出时不能出现浏览器式焦点描边；Flutter 不需要处理 outline，但屏幕切换后应把语义焦点放到标题（`Semantics(focused: true)` 或 `FocusScope`）。

---

## 2. 技术方案

### 2.1 环境

- Flutter 3.41.2 stable / Dart 3.9+。
- 依赖建议：
  - `provider`：轻量状态注入（`ChangeNotifier`）。
  - `shared_preferences`：JSON 持久化。
  - `flutter_svg`：角色、配图、图标。
  - `audioplayers`：本地 WAV。
  - `flutter_tts`：词卡和动态英文发音。
  - `share_plus`：系统分享。
- 不要引入 `go_router`、数据库、代码生成；这个规模不需要。

### 2.2 工程结构

```text
lib/
  main.dart
  app.dart
  theme/
    pip_theme.dart
    design_tokens.dart
  data/
    models.dart
    seed_data.dart            // 由 data_seed.json 转成 const Dart 数据
    asset_manifest.dart
  state/
    pip_controller.dart       // 唯一业务状态
    persistence.dart          // SharedPreferences JSON 读写
    demo_state.dart           // 演示初始状态 / demoResult
    clock.dart                // 可注入日期，便于测试
  services/
    audio_service.dart
    share_service.dart
  screens/
    root_shell.dart
    path_screen.dart
    quiz_screen.dart
    complete_screen.dart
    review_hub_screen.dart
    review_deck_screen.dart
    achievements_screen.dart
    profile_screen.dart
  widgets/
    pip_button.dart
    pip_brand.dart
    resource_strip.dart
    bottom_nav.dart
    lesson_map.dart
    bird_art.dart
    option_art.dart
    pip_progress_bar.dart
    toast.dart
    achievement_modal.dart
test/
  controller_test.dart
  persistence_test.dart
  quiz_flow_test.dart
  review_flow_test.dart
  screenshot_smoke_test.dart
```

### 2.3 导航模型

- `RootShell` 内含四个 tab：学习 / 复习 / 成就 / 我的，使用 `IndexedStack` 保留滚动位置；当前 tab 用 `RootTab` 枚举。
- `QuizScreen`、`CompleteScreen`、`ReviewDeckScreen` 是整页路由，不显示底部导航。
- 成就详情是 `showDialog`（或 `showModalBottomSheet`），背景可点击关闭。
- 开始关卡：先调用 `controller.startLesson()`，成功后 `Navigator.push(QuizScreen)`；退出答题：保存并 `Navigator.popUntil(root)`，把 tab 设为学习。
- 结算页：`pushReplacement(CompleteScreen)`，避免返回上一题；结算 CTA 再 `popUntil(root)`，按规则切 tab。
- 复习词卡：从复习页 `push(ReviewDeckScreen)`；返回 `pop` 回复习页，绝不重置到咖啡主题。
- Android 返回键：答题页等于“退出并保留进度”；词卡页等于“返回复习首页”；弹窗等于关闭；结算页回到路径而不是题目。

---

## 3. 数据模型

### 3.1 课程与题目

`data_seed.json` 是唯一数据源，字段与 Web 原型完全一致：

```dart
class Lesson {
  final String id;
  final String title;
  final String nodeTitle;
  final String eyebrow;
  final int xp;
  final String estimated;
  final String icon;
  final List<Question> questions;
}

class Question {
  final QuestionType type;       // fill | listen
  final String prompt;           // 题目标题
  final String cn;               // 中文情境
  final String first;            // 填空前半句
  final String prefix;           // 空格前，如 "with"
  final String suffix;           // 空格后
  final List<String> words;      // 选词填空选项
  final String answer;
  final String explain;
  final String? audio;           // 本地 WAV 文件名（不含目录/后缀）
  final String? audioText;       // TTS 备选文本
  final List<ListenOption>? options;
}
```

`fill` 题使用 `first/prefix/suffix/words/answer`；`listen` 题使用 `audio/options/answer`，`words` 为空。挑战的 6 道题是咖啡课和问路课题目的引用副本，顺序固定。

课程数据：

| id | 标题 | 题数 | XP | 说明 |
|---|---|---:|---:|---|
| coffee | 点杯咖啡 | 5 | 24 | 含第 4 题听音选图 |
| directions | 问个方向 | 4 | 24 | 含第 3 题听音选图 |
| challenge | 单元挑战 | 6 | 50 | 两课混合，含 2 道听音 |

单元信息：`第 3 单元 · 通勤英语` / `咖啡店，开口不慌`。

### 3.2 复习词卡

4 个主题，共 17 个表达：

| topic | 标题 | 数量 |
|---|---|---:|
| coffee | 点杯咖啡 | 5 |
| greeting | 打个招呼 | 4 |
| menu | 看懂菜单 | 4 |
| directions | 问个方向 | 4 |

每个主题有 `title/copy/icon/terms`，每个 term 是 `{en, cn}`。掌握状态按 `en` 字符串记录。

### 3.3 成就

5 枚徽章，全部由状态推导：

| id | 名称 | 条件 | 进度文案 |
|---|---|---|---|
| streak | 一周不掉线 | `streak >= 7` | 未获得：`min(streak,7) / 7 天`；获得：`已连续学习 N 天` |
| xp | 千分俱乐部 | `xp >= 1000` | 未获得：`N / 1,000 XP`；获得：`累计 N XP` |
| coffee | 咖啡自由 | coffee 已完成 | `已完成` 或 `完成点单课解锁` |
| directions | 问路达人 | directions 已完成 | `已完成` 或 `完成问路课解锁` |
| unit | 单元通关 | challenge 已完成 | `已完成` 或 `完成挑战解锁` |

### 3.4 运行时状态

```dart
class RunState {
  final String lessonId;
  final RunMode mode;       // lesson | review
  final int qIndex;
  final int answered;       // 已正确完成的题数
  final int correctFirstTry;
  final String selection;
  final Feedback feedback;  // none | correct | wrong
  final bool firstTry;
  final int streak;         // 连续答对题数
}

class LessonResult {
  final String lessonId;
  final String title;
  final String eyebrow;
  final int xpAwarded;
  final int accuracy;
  final int correctFirstTry;
  final int total;
  final RunMode mode;
  final bool completedNow;
  final int streak;
  final int dailySeconds;
  final int dailyGoal;
  final bool allDone;
  final bool demo;
}

class AppState {
  int xp;
  int lives;
  int streak;
  List<String> studyDates;               // yyyy-MM-dd
  int dailyGoal;                         // 5/10/15/20
  int dailySeconds;
  String dailyDate;
  Map<String, bool> completedLessons;    // greeting/menu/coffee/directions/challenge
  Map<String, List<String>> reviewMastered;
  RunState? run;
  Map<String, RunState> pausedRuns;      // key: lessonId:mode
  LessonResult? lastResult;
  bool soundOn;
}
```

`greeting` 和 `menu` 永远是已完成节点，没有对应的测验课程；点击它们打开各自的复习词卡。

---

## 4. 状态与算法

以下规则必须逐条实现，并写单元测试。

### 4.1 初始状态（演示数据）

```text
xp = 1284
lives = 4
studyDates = 今天之前的连续 7 天（不含今天）
streak = 7
dailyGoal = 10
dailySeconds = 360                 // 6 分钟
dailyDate = 今天
completedLessons = {greeting:true, menu:true, coffee:false, directions:false, challenge:false}
reviewMastered = {coffee:[], greeting:[], menu:[], directions:[]}
run = null, pausedRuns = {}, lastResult = null
soundOn = false
```

如果产品要正式上线，把 `xp/lives/dailySeconds` 改为真实初始值即可；但本原型验收使用上面的演示值。

### 4.2 日期与连续学习

- 日期键使用用户本地时区的 `yyyy-MM-dd`，计算时把时间设为当天 12:00，避免夏令时跨日。
- 学习日期集合为 `studyDates`，去重排序。
- `streak` 算法：如果今天在集合里，从今天往回数；否则从昨天往回数；遇到断档停止。

```dart
int computeStreak(Set<String> dates, DateTime now) {
  var cursor = dates.contains(dayKey(now)) ? 0 : 1;
  var count = 0;
  while (dates.contains(dayKey(now.subtract(Duration(days: cursor))))) {
    count++;
    cursor++;
  }
  return count;
}
```

- 第一次答对时调用 `markStudyToday()`：把今天加入集合，并重算 streak。
- 加载状态时重算 streak，不信任持久化值。

### 4.3 每日目标

- 每次答对增加 30 秒；累计上限为 `dailyGoal * 60`。
- 答题前先 `markStudyToday()`。
- 如果加载时 `dailyDate != 今天`：把 `dailyDate` 设为今天，`dailySeconds = 0`。
- 展示分钟 = `min(dailyGoal, dailySeconds ~/ 60)`。
- 进度百分比 = `min(100, round(dailySeconds / (dailyGoal * 60) * 100))`。
- 修改目标：`dailyGoal = n; dailySeconds = min(dailySeconds, n*60);`，然后保存并 Toast `每日目标已改为 N 分钟。`
- 目标选项固定 `[5, 10, 15, 20]`。

### 4.4 解锁与当前课程

```dart
bool unlocked(String id) {
  if (id == 'coffee') return true;
  if (id == 'directions') return completedLessons['coffee']!;
  if (id == 'challenge') return completedLessons['directions']!;
  return false;
}

String? currentLessonId() {
  if (!completedLessons['coffee']!) return 'coffee';
  if (!completedLessons['directions']!) return 'directions';
  if (!completedLessons['challenge']!) return 'challenge';
  return null;
}
```

- 锁定节点点击：Toast `先完成「点杯咖啡」，就能解锁「问个方向」。` / `先完成「问个方向」，就能解锁单元挑战。`，并回到学习页。
- 节点状态：`greeting/menu` 已完成；未解锁为 locked；已完成 lesson 为 completed；当前为 current。
- 节点语义文案：已完成 `已完成：X，复习`；锁定 `未解锁：X`；当前无进度 `开始：X`；当前有暂停进度 `继续：X`。

### 4.5 开始 / 暂停 / 恢复

`startLesson(id, requestedMode)`：

1. 未解锁：Toast + 回学习页，不创建 run。
2. 归一化模式：
   - 未完成 + review → lesson；
   - 已完成 + lesson → review。
3. 如果当前 run 正好是同一 `lessonId:mode` 且未结算：保留原样。
4. 否则如果 `pausedRuns[key]` 存在：先把当前未结算 run 存入 `pausedRuns`，再取出暂停的 run。
5. 否则：先把当前未结算 run 存入 `pausedRuns`，再创建新的 `RunState`。
6. 如果 `lives <= 0`，重置为 4。
7. 停止所有音频，保存，进入答题页。

暂停 key 固定 `lessonId:mode`。暂停的 run 保留 `qIndex/selection/feedback/firstTry/streak/correctFirstTry/answered`，所以恢复后可以继续在当前题，甚至保留“答对反馈”等待点下一题。

### 4.6 答题判定

- 点击选项只更新 `selection`，不判定。
- 点“检查答案”：
  - 正确：
    - `feedback = correct`
    - 若 `firstTry == true`，`correctFirstTry++`
    - `answered = max(answered, qIndex + 1)`
    - `streak++`
    - `addLearningTime(30)`
    - 播放 chime（仅 soundOn）
  - 错误：
    - `feedback = wrong`
    - `streak = 0`
    - `firstTry = false`
    - `lives = max(0, lives - 1)`
- 错误后“再选一次”：如果 `lives == 0` 先补满到 4；清空 selection/feedback，题号不变。
- 正确后“继续下一题”：`qIndex++`，清空 selection/feedback，`firstTry = true`；最后一题则结算。
- 正确率只统计 `correctFirstTry`。答错再答对，本题不算首答正确。
- 连击提示：`streak >= 2` 且当前正确时显示 `N 连击`。
- 生命没有 game over 页面；0 时重试自动补满 4。

### 4.7 结算

```dart
final total = lesson.questions.length;
final accuracy = (run.correctFirstTry / total * 100).round();
var xpAwarded = 0;
var completedNow = false;
if (run.mode != review && !completedLessons[lesson.id]!) {
  xpAwarded = lesson.xp;
  xp += xpAwarded;
  completedLessons[lesson.id] = true;
  completedNow = true;
}
```

- 结算结果保存到 `lastResult`，清空 `run`，删除该课所有暂停记录。
- 只有第一次完成 lesson 才加 XP；复习 mode 永远不加 XP。
- 连续天数与今日分钟在结算时读取当前状态。
- `allDone = currentLessonId() == null`。
- 进入结算页播放 chime（若 soundOn）。

### 4.8 学习页 CTA 与副文案

按以下优先级：

1. 没有任何当前课程（全部完成）：
   - CTA `复习点单`
   - 副文案使用薄荷色通关条：奖杯图标 + `本单元已通关 · 可随时复习`
2. 有当前课程，且存在该课的 active run（current run 或 paused run）：
   - 模式 review → CTA `继续复习`；否则 `继续这一课`
   - 副文案 `已完成 answered / total 题`
3. 有当前课程，没有进度：
   - coffee → `开始这一课`
   - directions → `学习问路`
   - challenge → `开始单元挑战`
   - 副文案 `N 道题 · estimated`
4. 全部完成但存在未结算的复习 run（例如通关后开始复习又退出）：
   - CTA `继续复习` / `继续这一课`
   - 副文案 `已完成 answered / total 题`

学习页节点点击：

- `greeting/menu` → 打开对应复习词卡，不是答题。
- 已完成课程 → 进入 review 模式。
- 未完成且已解锁 → 进入 lesson 模式。
- 锁定 → Toast。

### 4.9 复习词卡

- 打开主题时，从第一个未掌握的词开始；全部掌握则从 0 开始。
- 词卡状态是临时状态：`topic/index/revealed/done/round`，不要求持久化。
- 点卡片翻面；未翻面显示 `点一下，看中文`，已翻面显示中文。
- 已掌握词条标签 `已掌握`，否则 `还没掌握`。
- 操作顺序：
  - 未翻面：主按钮 `看中文`，次按钮 `先跳过`。
  - 已翻面：次按钮 `还不熟`，主按钮 `记住了`（若已掌握则 `再记一次`）。
- `记住了`：把 `term.en` 加入该主题的 mastered（去重），然后下一张。
- `还不熟` / `先跳过`：下一张，不改掌握状态。
- 最后一张后进入完成态：如果该主题全掌握，标题 `这一组，全记住了！`，否则 `这一轮，复习完成！`。
- 完成态显示 `已掌握 N / total`、`本轮 N 轮`；`再来一轮` 回到索引 0 且轮数 +1；`返回复习` 回复习首页。
- 返回按钮/系统返回都回复习首页，保持用户原来打开的主题列表。

### 4.10 成就分享与跳转

- 已获得徽章的弹窗动作是 `分享成就`。分享文案：
  `我在 Pip 英语学习里解锁了「{title}」：{desc}。连续学习 {streak} 天，累计 {xp} XP。`
  优先系统分享；不可用则复制到剪贴板并 Toast `分享文案已复制到剪贴板。`
- 未获得徽章的弹窗动作是 `去完成这一步`：
  - coffee/directions/unit → 关闭弹窗后尝试开始对应课程；未解锁则 Toast 并回学习页。
  - streak/xp → 关闭弹窗回学习页。
- 弹窗点击背景、关闭按钮、Android 返回都可关闭。

### 4.11 持久化

- 使用 `SharedPreferences`，key 建议 `pip_learning_v2`，值为整个 `AppState` 的 JSON 字符串。
- 每次改变状态（选词、检查、下一题、退出、目标、音效、复习掌握、结算）都要保存。
- 读取时做容错合并：
  - 缺失字段用默认值；
  - 非法枚举/越界数字夹紧；
  - 重算 streak；
  - 跨天重置 dailySeconds；
  - 如果当前 run 指向不存在的课，清空 run。
- 日期与整数以本地时区处理；不要存 `DateTime` 对象本身。
- `wall/demo` 模式（如用于展示）只读演示状态、不写存储；Flutter 用 `AppLaunchConfig(readOnlyDemo: true)` 实现。

### 4.12 演示启动配置（可选但推荐）

为截图和 widget 测试准备：

```dart
class AppLaunchConfig {
  final RootTab initialTab;
  final bool demoCorrectFeedback; // q1 选中 milk 且显示答对反馈
  final bool demoComplete;        // 直接展示演示结算
  final bool readOnlyDemo;
  final bool soundOn;
}
```

功能等价于 Web 的：

- `?screen=path|reviewHub|achievements|profile`
- `?screen=quiz&state=correct`
- `?screen=complete`
- `?screen=reviewDeck`
- `?wall=1`
- `?sound=on`

发布版不解析 URL；测试里通过构造 `PipApp(launch: ...)` 注入。

---

## 5. 页面规格

### 5.1 学习路径（Path）

结构自上而下：

1. 顶栏 90 高：左侧 `pip` 字标（40px、字距 -3、旋转 -4°，右上角黄底墨边小圆点，`assets/images/pip.svg`）；右侧资源条：火焰 + `7 天`、闪电 + `1,284 XP`、爱心 + `4`。资源条间距 16，图标 21–25。
2. 黄色单元横幅：两侧墨边；左 `第 3 单元 · 通勤英语`（12，深黄/墨），下 `咖啡店，开口不慌`（24/900）；右 50 左右的杯子线稿图标。
3. 今日目标行：左 `今日目标` + `6 / 10 分钟`（已达目标追加 ` · 已完成`）；右 100×11 的粗描边进度条，黄填充。
4. 地图区域：占剩余空间，最小约 330 高，左右 20。设计画布 350×425：
   - 底轨 14 宽 `#EAE9E0`，完成轨 14 宽薄荷绿；圆头。
   - 节点坐标与标签坐标严格使用 `design_tokens.json` 的 `map` 值。
   - 节点：76×61 椭圆，2px 边；已完成薄荷底/深薄荷边/6px 阴影 + 勾；锁定灰底/浅灰边/6px 灰阴影 + 锁；当前 86×69 黄底/墨边/8px 墨阴影 + 播放三角，并在外部 offset -15 画 2px 黄褐虚线环（半径随尺寸）。
   - 标签 14/800，颜色 `#5E6258`，不换行；当前节点标签放在节点下方，其余在右侧。
   - Pip 插画 112×122，位于 (232,137)，旋转 7°；全部通关时换成庆祝表情。
   - 点击节点：按 4.8 规则。
5. 底部行动区：副文案 13/700 灰色；主 CTA 占满宽度、高 53、圆角 18、黄色硬阴影；右侧箭头。
6. 底部导航 81 高：四个 tab，每项 77×60，图标 26，文字 12/800；激活项背景 `#FFF2B3`、文字墨色、图标填充黄。

地图实现建议：`LayoutBuilder` 按 `width/350` 缩放 `Positioned` 坐标；轨迹用 `CustomPainter` 按同一比例缩放 cubic path。窄屏最小宽度 320 时标签仍不能互相覆盖。

### 5.2 答题页（Quiz）

顶部 77 高：

- 左关闭按钮 44×44，语义 `退出本课，保留答题进度`。
- 中间进度条：高 14、2px 墨边、圆角 10，底 `#EBECE3`；填充宽度 `answered / total`，黄色，右侧 2px 墨边，填充内顶部有一条 3px 浅黄高光。
- 右生命值：心 + 数字。

内容区（左右 24）：

- 元信息行 13/800：`{复习/挑战 · }{选词填空|听音选图} · {qIndex+1} / {total}`；右侧音效开关 44×44，图标 sound/mute。
- 标题 26/900，行高 1.35。
- 情境区：
  - 选词填空：思考表情的 Pip（108×130，左，旋转 -6°） + 白色对话气泡（2px 墨边、19 圆角、17/800、小三角）。气泡内中文 + `听听怎么说` 文字按钮（喇叭 + 12/800，最小 44 高）。答对后隐藏 Pip，只保留气泡。
  - 听音选图：Pip + 只含中文的气泡；下方独立黄色音频按钮（全宽、2px 边、18 圆角、浅黄底、4px 黄褐阴影），左侧 46 圆盘内喇叭，右侧标题 `播放英文` + 提示 `听完选出对应的图片`；播放中标题 `正在播放…`，播完 `再听一遍`，提示播完 `点这里再听一遍`。
- 选词填空：
  - 句子 28/850，Nunito，行高约 1.9；前半句单独一行；空格为黄底圆角块（选词后显示单词 + 对勾；未选显示 `···`）；标点单独处理。
  - 词库 2 列，间距 13/14；按钮高 53、2px 浅灰边、16 圆角、4px 灰阴影、22/850；选中黄底/黄褐边/黄褐阴影 + 对勾；答对后所有按钮禁用，被选单词原位置替换成空虚线槽。
- 听音选图：
  - 三列等宽，间距 11，卡片最小高 142；2px 浅灰边、18 圆角、4px 灰阴影；内部 66×66 配图、15/900 中文、11/800 英文（Nunito）。
  - 选中黄底/黄褐边/黄褐阴影；答对后选中项右上角显示勾；答错显示叉，选中项浅珊瑚底/深珊瑚边。
  - 禁用时未选中项整体降为 55% 视觉但文字仍可读；选中项必须保持不透明。
- 底部：
  - 未作答：主按钮 `检查答案`（无选择时禁用）+ 提示 `选一个答案，补全这道题。`
  - 答对：薄荷绿反馈面板，顶部 28 圆角 + 2px 墨边，高度约 219；右上角 Pip 庆祝（106×118，溢出面板上方 62）；行内墨圆勾 + `答对了！` 27/1000；说明 15/800（左缩进 39）；主按钮 `继续下一题` / 最后一题 `查看本课成果`（挑战为 `查看挑战结果`）。连击徽章在右上，墨底黄字。
  - 答错：浅珊瑚反馈面板，红色圆叉 + `差一点，再试试`；说明 `{explain}。把这个说法记住！`；主按钮 `再选一次`（生命为 0 时 `补满生命，再试一次`），右侧复习图标。
- 音效：开关只控制 chime，不影响人声/听力播放。

### 5.3 课后结算（Complete）

- 顶栏 26/24：`pip` 字标 + 右侧 `第 3 课 · 点杯咖啡`（13/800 灰）。eyebrow 根据结果传入，问路是 `第 4 课`，挑战是 `咖啡店单元`。
- 庆祝区：大 Pip 庆祝（约 220 高）、黄色晕环、彩带/星星、落影。`disableAnimations` 时保持静态构图。
- 标题 31/1000，副标题 15/700：
  - 挑战：`整条街，都敢开口了！` / `咖啡和问路，一次打通。`
  - 问路：`这条路，你走通了！` / `下次问路，别再只靠手势。`
  - 咖啡复习：`又练了一遍，更顺了！` / `重复，是把句子变成本能的方式。`
  - 咖啡正课：`这杯英语，你拿下了！` / `下次点咖啡，试着用英语说说看。`
- 奖励双卡：两列，13 间距，左右 24；每卡 2px 边、18 圆角、4px 灰阴影、内边距 17。
  - 左：`本课经验 / 挑战奖励 / 复习成果`；值 `+24 XP`（29/1000）或 `已巩固`。
  - 右薄荷底：`正确率`；值靶心 + `100%`。
- 连续学习卡：2px 边、22 圆角，内边距 16/17；标题 23/900 `连续学习 7 天！` + 火焰；下方 7 天行：标签 `今天` 或 `一..日`（12/800），圆片 30；已学习浅黄底 + 勾，今天已学习黄底墨边 + 3px 墨阴影 + 旋转 -7°，今天未学习虚线边。
- CTA 与脚注：
  - demo → `返回学习路径`，脚注 `这是演示结算页，可以直接返回路径。`
  - allDone + challenge → `查看单元成就`，跳成就 tab。
  - review → `返回学习路径`。
  - 其他 → `收下奖励`，返回学习路径。
  - 剩余分钟 > 0 → `再学 N 分钟，完成今日目标。`，否则 `今日目标已完成，明天继续。`
- 结算页是 `pushReplacement`，不能返回答题。

### 5.4 复习首页（Review Hub）

- 可滚动内容，顶部 header：返回按钮 + `复习`（24/900）。
- 黄色总结卡：左侧方形时钟图标 45，标题 `已经掌握 X / 17 个表达`（16/900），说明 `翻一翻词卡，把学过的句子变成自己的。`；右侧 55 环形进度（conic），环内白/黄圆 41，显示百分比 11/900。
- 四个主题卡：全宽、2px 墨边、18 圆角、4px 灰阴影；左 46 方形浅黄图标；中间标题 17/900、说明 12/700、7 高进度条（薄荷绿 + 墨边）、`已掌握 N / 4`（10/800）；右箭头。
- 四个主题都必须可进入；点击后进入对应词卡。
- 底部导航激活“复习”。

### 5.5 复习词卡（Review Deck）

- 无底部导航。header：返回 + 主题名（24/900）+ 右侧 `1 / 5`（12/900 灰）。
- 进度条 8 高，2px 墨边，黄色填充 `(index+1)/total`。
- 词卡：占满剩余，最小 300 高，2px 墨边、24 圆角、6px 灰阴影；背景从浅黄到 paper 的对角渐变；内容居中。
  - 左上标签 `已掌握` / `还没掌握`（10/900，1.5 边，圆角胶囊，白底）。
  - 英文：Nunito 27–38/900，字距 -0.7，允许长词换行。
  - 中文：20/900；未翻面时用 13/800 灰字 `点一下，看中文`；下方提示 `点卡片翻面` / `再点一下可以收起`。
  - 整卡可点翻转，必须有 48 以上触控和语义 label `翻转词卡`。
- 音频行：次按钮 `听发音`（46 高、内边距 15）+ 右侧 `N / 5 已掌握`。
- 操作区两列 12 间距，按钮高 54：
  - 未翻面：`看中文`（主）、`先跳过`（次）。
  - 翻面：`还不熟`（次）、`记住了` / `再记一次`（主）。
- 完成态：庆祝 Pip 125×138、标题 24/1000、说明 14/700、统计条、两个按钮 `再来一轮`（次）、`返回复习`（主）。
- 返回/系统返回 → 复习首页。

### 5.6 成就（Achievements）

- 可滚动。header 返回 + `成就`。
- 薄荷总结卡：奖杯图标 + `已解锁 2 / 5 枚徽章` + `每一点进步都算数。` + 环形 40%。
- 列表 5 项，行间 2px 浅线；每行：46 方形浅黄/灰图标、标题 16/900、说明 12/700、进度 10/800、右侧状态胶囊 `已获得`（薄荷）或 `待解锁`（灰）。
- 未获得行图标灰度、opacity 0.65，标题灰。
- 点击任意行打开弹窗：
  - 背景 46% 墨色；居中卡片最大宽 330，2px 墨边、24 圆角、8px 墨阴影，进入 180ms scale/fade。
  - 顶部 66 方形图标；状态胶囊；标题 24/1000；说明 13/700；进度白底条；主按钮（分享/去完成）；文字关闭按钮。
  - 点击背景关闭；关闭后回到列表。
- 底部导航激活“成就”。

### 5.7 我的（Profile）

- 可滚动。header 返回 + `我的 Pip`。
- Pip 招手 112×112；名字 `小林的学习日常` 23/900 居中。
- 详情行：左标签灰 14/800，右值 15/900；上下 13 内边距，2px 浅线分隔：
  - 正在学习 / 英语 · 初级 A1
  - 累计经验 / 1,284 XP
  - 连续学习 / 7 天
  - 已完成关卡 / 2 / 5
  - 复习掌握 / 0 / 17
- 目标区：上方 2px 线；行 `每天的目标` + `6 / 10 分钟`；四个 chip 等宽：5/10/15/20 分钟，40 高、2px 边、12 圆角、3px 灰阴影；激活黄底黄褐边黄褐阴影；点击更新目标并 Toast。
- 说明 `改变目标后，今日进度会按新目标重新计算。`
- 底部主按钮 `回去学一点` → 学习 tab。内容在 844 高度内必须完整可见；小屏允许滚动。
- 底部导航激活“我的”。

### 5.8 导航、Toast、弹窗

- 底部导航只出现在四个主 tab 页面。
- Toast：墨色底、paper 字、16 圆角、14/1.5，距底部约 184（避开导航），4.3 秒自动消失；连续 Toast 覆盖上一条。
- 弹窗：见成就；背景点击关闭，内容点击不关闭。
- 所有页面切换停止正在播放的音频。

---

## 6. 音频与发音

### 6.1 文件映射

| 文件 | 内容 | 使用位置 |
|---|---|---|
| `coffee-milk.wav` | I'd like a coffee with milk. | coffee q1 |
| `to-go.wav` | Can I get it to go? | coffee q2 |
| `small.wav` | A small one, please. | coffee q3 + coffee 听音 q4 |
| `thank-you.wav` | Thank you. Have a nice day! | coffee q5 |
| `where-station.wav` | Excuse me, where is the station? | directions q1 |
| `go-straight.wav` | Go straight for two blocks. | directions q2 |
| `turn-left.wav` | Turn left at the corner. | directions q3（听音） |
| `next-to-bank.wav` | It's next to the bank. | directions q4 |
| `chime.wav` | 三音上行提示 | 答对（soundOn）+ 结算 |

- 题目音频优先用 WAV；如果某题没有 `audio` 但有 `audioText`，用 TTS。
- 词卡 `听发音` 用系统 TTS，`en-US`，语速 0.88。
- 播放状态 UI：
  - 大音频按钮：播放中标题 `正在播放…`，结束 `再听一遍`；提示播放中 `正在播放…`，结束 `点这里再听一遍`。
  - 气泡内 `听听怎么说`：播放中 `正在播放…`，结束 `再听一遍`。
- 播放失败 Toast `这次没播放出来，点一下再听。`
- 切换页面、退出答题、关闭弹窗时停止音频与 TTS。
- 不要自动播放听力题（用户主动点播放），避免惊吓与自动播放限制。

### 6.2 音效

- `soundOn` 默认 false；开关持久化。
- 只在答对和结算播放 chime；切换开关时如果打开，立即播放一次轻提示。
- TTS 与人声音频不受 `soundOn` 控制。

---

## 7. 无障碍与响应式

- 每个图标按钮提供 `Semantics(label:)`；纯装饰图 `excludeFromSemantics`。
- 进度条使用 `Semantics(value: '3 / 5')`；资源条整组提供可读标签 `连续学习 7 天`、`1,284 经验值`、`剩余 4 颗生命`。
- 反馈面板使用 live region，让屏幕阅读器读出对错与说明。
- 触控区域至少 44×44；底部导航至少 60 高。
- 支持系统文字缩放至 1.2–1.3；标题允许 2 行，答题句子和选项不允许被裁切。
- 支持 `disableAnimations`：跳过飞词、撒花、连击弹跳，但保留状态变化。
- 短屏（可用高度 < 790）：压缩地图最小高度、卡间距、结算插画；个人页与复习/成就页可滚动，底部导航固定。
- 宽屏（> 430）：内容居中，最大 430；外部背景 `#E9E9E1`，圆角 24 的 App 面板可选。
- 颜色对比：黄底上的墨字、薄荷底上的墨字均满足可读性；不要用浅灰字做主要信息。

---

## 8. 素材清单

```text
assets/audio/*.wav          9 个（8 题 + chime）
assets/fonts/Nunito.ttf
assets/images/pip.svg       字标
assets/images/bird_wave.svg
assets/images/bird_think.svg
assets/images/bird_celebrate.svg
assets/images/option_small.svg
assets/images/option_large.svg
assets/images/option_iced.svg
assets/images/option_left.svg
assets/images/option_right.svg
assets/images/option_straight.svg
assets/icons/*.svg          22 个 24×24 图标
```

`pubspec.yaml`：

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/audio/
    - assets/images/
    - assets/icons/
  fonts:
    - family: Nunito
      fonts:
        - asset: assets/fonts/Nunito.ttf
```

SVG 已统一包含 `xmlns` 并把 `currentColor` 换成 `#242522`；如需要状态变色，用 `ColorFilter.mode` 或复制资源，不要修改原始文件。

---

## 9. 关键文案清单

### 全局

- 今日目标 / `{minutes} / {goal} 分钟` / ` · 已完成`
- `连续学习 {n} 天！`
- `已完成 {answered} / {total} 题`
- `已掌握 {done} / {total}`
- `本单元已通关 · 可随时复习`

### 解锁与错误

- `先完成「点杯咖啡」，就能解锁「问个方向」。`
- `先完成「问个方向」，就能解锁单元挑战。`
- `这次没播放出来，点一下再听。`
- `这道题没有音频。`
- `每日目标已改为 {n} 分钟。`
- `分享文案已复制到剪贴板。`

### 答题

- `选词填空` / `听音选图`；`复习` / `挑战` 前缀
- `播放英文` / `听完选出对应的图片` / `正在播放…` / `再听一遍` / `点这里再听一遍`
- `检查答案` / `选一个答案，补全这道题。`
- `答对了！` / `差一点，再试试` / `把这个说法记住！`
- `继续下一题` / `查看本课成果` / `查看挑战结果`
- `再选一次` / `补满生命，再试一次`
- `{n} 连击`

### 结算

见 5.3；CTA `收下奖励` / `查看单元成就` / `返回学习路径`。

### 复习 / 成就 / 我的

见 5.4–5.7。分享文案见 4.10。

---

## 10. 实施顺序（给 AI 的里程碑）

### M1 — 工程与状态骨架

- 创建 Flutter 工程，加入依赖和资产。
- 实现主题/设计 token、模型、种子数据、`PipController`、持久化、日期/连续天数。
- 实现 RootShell + 底部导航 + 学习页静态布局（节点、轨迹、资源条、CTA）。
- 产出：可运行的学习页，数据来自状态；单元测试覆盖 streak/unlock/current。

### M2 — 选词填空全链路

- Quiz 页填空类型、选项、检查、正确/错误反馈、生命、连击、进度。
- 结算页、XP、完成标记、解锁下一课、CTA 规则。
- 产出：咖啡课 5 题可完成，结算显示真实正确率；单测覆盖 80%/100%。

### M3 — 听力题与音频

- 听音选图 UI、本地 WAV、TTS 回退、播放状态、错误 Toast。
- 关闭音频/切页停止播放。
- 产出：咖啡和问路听音题都能作答；音频资源不联网。

### M4 — 复习

- 复习首页、四主题、词卡翻转、掌握/跳过/再来一轮、完成态、持久化。
- 产出：17 个表达可掌握，返回路径不抢主题。

### M5 — 成就与个人页

- 成就派生、弹窗、分享、去完成。
- 个人页统计与目标 chips，目标更新 Toast 与进度重算。
- 产出：5 枚徽章条件准确；目标 5/10/15/20 均可切换。

### M6 — 打磨与验收

- 动效、无障碍、小屏/宽屏、焦点/语义、演示配置。
- 跑 `flutter analyze`、`flutter test`、手工走 `ACCEPTANCE_TESTS.md`。
- 截图与 `reference/` 对照，修正间距与色彩。

---

## 11. 测试要求

### 11.1 单元测试

- `computeStreak`：今天已学/未学、昨天断档、空集合、7 天演示数据 → 7；今天学习后 → 8。
- `currentLessonId`：初始 coffee；完成 coffee → directions；完成三个 → null。
- `unlocked`：三课顺序与锁定。
- 正确率：5 题全对 100%；错 1 后重试 80%；4 题全对 100%；挑战 6 题全对 100%。
- XP：首次完成加 24/24/50；复习完成不加；重复完成不加。
- 每日：答对 +30 秒、封顶；跨天重置；目标改小夹紧、改大不增加。
- 复习：第一个未掌握、全掌握从 0、掌握去重、跳过不改。
- 持久化：round-trip、缺失字段合并、非法数据降级、跨天重置。
- 暂停/恢复：qIndex/selection/feedback/firstTry 完整保留；不同模式分开保存。

### 11.2 Widget / 集成测试

- 初始学习页：6/10、7 天、coffee current、后两课锁定。
- 锁定节点 Toast。
- 咖啡课：选 milk → 检查 → 答对 → 下一题；错误 → 生命 -1 → 重试 → 对；最后一题结算 80%。
- 退出 1 题后回路径：`继续这一课`、`已完成 1 / 5 题`、节点语义“继续”。
- 听音题：点播放、选小杯、正确反馈、选项不整体变淡。
- 问路完成：解锁挑战、结算标题正确。
- 挑战全对：100%、+50、CTA `查看单元成就`。
- 复习：打开 directions 主题、翻面、记住、跳过、完成、返回复习首页。
- 成就：已获得弹窗分享；未获得弹窗去完成。
- 目标：改 5 分钟并夹紧进度，改 20 分钟进度重算。
- 重启 App 后状态恢复。

---

## 12. 完成定义（DoD）

- `flutter analyze` 0 error；`flutter test` 全绿。
- 390×844 截图与 `reference/` 的布局、间距、颜色、层级一致；文字不裁切。
- 以下五条回归必须通过：
  1. 解锁链正确，无“三课解锁”文案。
  2. 听音题存在且可播放、可答对。
  3. 今日目标/连续/复习/成就全部实时计算。
  4. 正确率无基线，重试不洗白首答错误。
  5. 退出恢复、继续文案、复习主题返回正确。
- 所有音频离线可用；无网络请求。
- 关闭/重开 App，XP、完成状态、复习掌握、目标、音效开关、暂停进度都保留。
- 屏幕阅读器能读出导航、进度、资源、反馈、弹窗。
- `disableAnimations` 下无飞词/撒花，但功能完整。

---

## 13. 容易做错的地方

1. **不要**把 `answered` 当成题目索引。答题进度用 `answered`，当前题用 `qIndex`；答错时两者不变。
2. **不要**在答错时给 `correctFirstTry` 加回去；重试成功只影响 `feedback`，不影响首答统计。
3. **不要**在复习模式给 XP；只有首次 lesson 完成给。
4. **不要**在解锁判断里使用“已完成课程数 >= 3”这种旧逻辑；必须逐级依赖。
5. **不要**把 `greeting/menu` 当成测验课；它们只打开复习词卡。
6. **不要**在每次重渲染时重置 `firstTry`；它只在进入下一题时重置。
7. **不要**把今日分钟直接存成展示值；存秒数，展示时取整。
8. **不要**在跨天后保留昨天的 dailySeconds；加载时和答题前都要检查日期。
9. **不要**在复习返回时重开 coffee；使用传入的 topic。
10. **不要**把 `soundOn` 用来静音听力/发音；它只管 chime。
11. **不要**在听力反馈时降低选中选项不透明度；这是已修复的视觉 bug。
12. **不要**用系统默认 Material 卡片/按钮覆盖硬阴影视觉；自绘 `PipButton`。
13. **不要**把地图节点绝对坐标硬编码到 390 屏幕；按设计画布 350 缩放。
14. **不要**在结算页用 `Navigator.push` 让返回键回到最后一题；用 replacement。
15. **不要**在词卡完成态把“再来一轮”做成重置掌握；掌握状态必须保留。

---

## 14. 交付物

Flutter agent 最终需要提交：

- 可运行 Flutter 工程（iOS/Android 至少一个真机或模拟器通过）。
- 上述目录结构的源码与测试。
- 一份简短 `IMPLEMENTATION_NOTES.md`：依赖、运行方式、状态机说明、与规格的差异（如有）。
- 验收截图：学习页、填空答对、听音题、结算、复习首页、词卡、成就弹窗、个人页（390×844）。
- `flutter analyze` 与 `flutter test` 输出。
