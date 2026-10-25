# 可直接粘贴给 Flutter Agent 的开工提示词

> 用法：把整个 `lingo-flutter-handoff/` 文件夹（或 zip）附加给 Flutter agent，然后把下面分隔线内的内容整段发给它。不要只发截图；规格、数据和素材都在文件夹里。

---

你是一名资深 Flutter 工程师。请基于随附的 **Pip 英语学习交接包**，从零实现一个可运行的 Flutter App。不要使用 WebView，不要照搬 HTML/CSS；要用 Flutter 原生组件和自绘样式复刻产品与视觉。

## 先读这些文件

按顺序阅读：

1. `README.md` —— 包结构、运行方式、五个必须守住的修复点。
2. `FLUTTER_IMPLEMENTATION_SPEC.md` —— **唯一实现依据**。逐节执行，尤其是第 4 节状态算法、第 5 节页面规格、第 13 节易错点。
3. `data_seed.json` —— 3 节课、15 道题、4 个复习主题、17 个表达、5 个成就条件。直接转成 Dart 常量，不要改文案。
4. `design_tokens.json` —— 颜色、字号、圆角、阴影、地图坐标。
5. `reference/*.png` —— 390×844 视觉基准。
6. `prototype/` —— 可运行的 Web 原型，用于交互对照。不要修改它。
7. `ACCEPTANCE_TESTS.md` —— 完成后逐条验收。

## 任务

在当前工作区创建 Flutter 工程（建议目录 `pip_flutter/`，包名 `com.example.pip`），实现：

- 学习路径：资源条、今日目标、5 个节点、解锁链、进度恢复、底部导航。
- 答题：选词填空 + 听音选图、检查/重试/下一题、生命、连击、真实正确率。
- 结算：XP、正确率、连续 7 天、CTA 分支。
- 复习：4 个主题、词卡翻转、掌握/跳过、完成一轮、持久化。
- 成就：5 枚徽章、详情弹窗、系统分享/剪贴板回退、未解锁跳转。
- 我的：统计、每日目标 5/10/15/20、目标变更逻辑。
- 本地持久化、离线音频、TTS、无障碍语义、小屏/宽屏适配。

## 技术约束

- Flutter 3.41.2 stable / Dart 3.9+，Material 3 可以开启，但视觉必须自绘；不要用默认 elevation 取代硬阴影。
- 依赖控制在：`provider`、`shared_preferences`、`flutter_svg`、`audioplayers`、`flutter_tts`、`share_plus`。
- 状态集中在一个 `ChangeNotifier`（如 `PipController`），日期通过可注入 `Clock` 提供，便于单测。
- 所有素材从 `assets/` 复制到工程，按规格的 `pubspec.yaml` 注册；不要联网下载图标或字体。
- 业务规则以规格为准；视觉以 `reference/` 和 `prototype/` 为准。
- 不要实现后端、登录、网络词典、排行榜。
- 不要在完成前删除或跳过任何页面。

## 执行方式

1. 先输出一个简短的实施计划（M1–M6）和预计文件结构，然后直接开始，不要反复询问需求。
2. 按规格第 10 节顺序实现：M1 骨架 → M2 填空与结算 → M3 听力与音频 → M4 复习 → M5 成就与我的 → M6 打磨。
3. 每个里程碑结束都运行：

   ```bash
   flutter analyze
   flutter test
   ```

   修到 0 error、测试全绿再继续。
4. 至少写以下测试：
   - streak/连续天数、unlock/currentLesson、正确率 80%/100%、XP 只加一次、每日目标夹紧、跨天重置。
   - 暂停恢复保留 qIndex/selection/feedback；复习第一个未掌握；词卡掌握去重。
   - 咖啡课错误→重试→完成显示 80%；挑战全对 100%、+50。
5. 最后跑 `ACCEPTANCE_TESTS.md` 的全部用例，并在 `IMPLEMENTATION_NOTES.md` 记录：
   - 如何运行；
   - 依赖与平台要求；
   - 与规格的差异（如有）；
   - 测试和手工验收结果；
   - 390×844 截图位置。
6. 只有在真正运行过 `flutter analyze`、`flutter test` 和关键流程后才宣称完成。不要把“代码写完”当成“验收通过”。

## 特别容易做错（必须守住）

- 正确率 = 首答正确数 / 总题数，**没有 4 题基线**；答错后重试成功不会恢复正确率。
- 解锁必须逐级：coffee → directions → challenge；不能再用“完成 3 课解锁”。
- `greeting` / `menu` 只打开复习词卡，不是测验课。
- 退出答题后路径必须显示“继续这一课”和“已完成 N / M 题”；节点语义为“继续”。
- 复习返回必须回到用户刚才的主题，不能强制 coffee。
- 听力题答对/答错时，选中项不能整体变淡；这是原型修过的 bug。
- `soundOn` 只控制答对 chime，不控制听力/发音。
- 结算用 `pushReplacement`，返回键不能回到最后一题。

## 完成回复格式

完成后用中文回复，包含：

- 实现的页面清单与关键文件路径；
- `flutter analyze` / `flutter test` 的实际结果；
- 验收清单中通过/未通过的项；
- 已知差异或未完成项（如有）；
- 如何运行与查看截图。

现在开始。先读规格，再创建工程并实现 M1。
