# Pip 英语学习 · Flutter 交接包

这是一个**自包含的 Flutter 实现交接包**。目标是把已验证的 Web 原型、视觉资产、业务规则和验收标准一次交给另一个 AI / 工程师，让对方不需要读取之前的对话，也不需要猜产品逻辑，就能直接开始写 Flutter。

> 当前状态：Web 原型已完成并通过回归测试；**Flutter 代码尚未开始**。本包是“可直接开工”的实现说明书 + 素材 + 验收清单。若要继续，请让 Flutter agent 先读 [FLUTTER_IMPLEMENTATION_SPEC.md](FLUTTER_IMPLEMENTATION_SPEC.md)，再把 [AI_PROMPT.md](AI_PROMPT.md) 整段贴给它。

## 这个包解决什么

- **不用重新讲上下文**：所有页面、状态、算法、文案、边界条件都在规格里。
- **不用重新找素材**：音频、字体、SVG 角色、图标、答题配图、原型截图全部收齐。
- **不用重新抄数据**：`data_seed.json` 直接从可运行原型导出，包含 3 节课、15 道题、4 个复习主题、17 个表达。
- **可以验收**：`ACCEPTANCE_TESTS.md` 把五组修复点转成了可执行测试。
- **保留视觉基准**：`prototype/` 是能直接运行的 Web 原型，`reference/` 是 390×844 的设计截图。

## 目录

```text
lingo-flutter-handoff/
├── README.md                          ← 本文件
├── FLUTTER_IMPLEMENTATION_SPEC.md     ← 给 AI 的完整实现规格（主文档）
├── AI_PROMPT.md                       ← 可直接粘贴给 Flutter agent 的开工提示词
├── ACCEPTANCE_TESTS.md                ← 验收用例与回归清单
├── design_tokens.json                 ← 颜色、字号、圆角、阴影、地图坐标
├── data_seed.json                     ← 课程、题目、复习词卡、成就规则
├── assets/
│   ├── audio/                         ← 8 段题目音频 + chime.wav
│   ├── fonts/Nunito.ttf               ← 可变字重字体
│   ├── images/                        ← pip 标志、3 个 Pip 表情、6 张选项配图
│   └── icons/                         ← 22 个 24×24 SVG 图标
├── reference/                         ← 390×844 界面截图
│   ├── index.html                     ← 九宫格视觉索引（浏览器打开）
│   ├── path.png
│   ├── quiz-correct.png
│   ├── quiz-listen.png
│   ├── complete.png
│   ├── review-hub.png
│   ├── review-deck.png
│   ├── achievements.png
│   ├── achievement-modal.png
│   └── profile.png
└── prototype/                         ← 已验证的 Web 原型（可运行、可对照）
    ├── index.html
    ├── screens.html
    └── assets/
```

## 给另一个 AI 的最短用法

1. 把整个 `lingo-flutter-handoff/` 文件夹（或 zip）放进 Flutter 工程旁边。
2. 对 Flutter agent 说：**“读 `AI_PROMPT.md` 并严格按它执行。”**
3. 等它完成 M1–M6 后，用 `ACCEPTANCE_TESTS.md` 的 41 条用例验收。
4. 视觉对照以 `reference/` 和 `prototype/` 为准；规格与原型冲突时，以原型为准并在 PR 中说明。

## 推荐运行环境

- Flutter 3.41.2 stable / Dart 3.9+（本机已安装）。
- 目标平台：iOS / Android 优先；Web 可用于快速预览。
- 依赖建议：`flutter_svg`、`shared_preferences`、`audioplayers`、`flutter_tts`、`share_plus`、`provider`。
- 不引入后端、登录、网络接口；所有内容离线内置。

## 素材说明

- 音频与字体来自原型资产，可直接用于本产品原型。
- `option_*.svg` 是答题配图；`bird_*.svg` 是 Pip 的招手、思考、庆祝三种状态。
- `icons/` 中的 SVG 已把 `currentColor` 统一替换为 `#242522`，Flutter 里可直接渲染；仍建议用 `ColorFilter` 实现选中/禁用变色。
- `chime.wav` 是按原型的三音提示音重新生成的本地音频，替代浏览器 WebAudio 合成。

## 对照原型的快速方式

先看视觉索引：[reference/index.html](reference/index.html)。再启动原型：

```bash
cd prototype
python3 -m http.server 8899
# 打开 http://localhost:8899/index.html
```

演示状态：

- `?screen=path|quiz|complete|reviewHub|reviewDeck|achievements|profile`
- `?screen=quiz&state=correct&sound=on&wall=1`：答对反馈
- `?wall=1`：不写 localStorage，重置为演示初始数据
- `?screen=review`：旧链接别名，指向复习首页

## 需要特别守住的五个已修复问题

1. 解锁链必须是「点杯咖啡 → 问个方向 → 单元挑战」，不能回到“三课解锁”。
2. 听音选图必须同时存在于咖啡课、问路课和挑战中，不能只有选词填空。
3. 今日目标、连续天数、复习进度、成就必须从状态实时计算，不能写死。
4. 正确率 = 本轮首答正确数 / 本轮总题数，不叠加基线；重试对了也不能抹掉首答错误。
5. 中途退出后必须显示「继续这一课」与已完成题数；返回复习首页时必须保留用户选择的主题，不能强制回到咖啡。

## 下一步

本包不含 Flutter 源码。需要我继续时，可以直接在这个工作区创建 `pip_flutter/` 工程，按 M1–M6 实现并用同一份验收清单回归。交接包中的规格已经按这个实现顺序写好。
