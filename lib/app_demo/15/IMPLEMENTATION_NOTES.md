# APP-15 实现说明

## 依赖

| 依赖 | 用途 |
| --- | --- |
| `flutter_svg` | 图标与插图（22 个 SVG） |
| `just_audio` | 本地 WAV 听力音频 |
| `flutter_tts` | 无 WAV 时的发音兜底与词卡朗读 |
| `share_plus` | 成就系统分享 |
| `shared_preferences` | 本地存档（键 `party_box.demo15.pip_learning_v2`，schema 2） |

字体 `Nunito.ttf` 与全部图片 / 音频位于 `assets/`，离线可用。

## 运行

在仓库根目录执行：

```sh
flutter run -t lib/main.dart -d <device-id>
flutter test test/app_demo/15
flutter analyze lib/app_demo/15 lib/main.dart test/app_demo/15
```

从 Showcase 的 `APP-15(Pip 英语学习)` 进入；应用内没有独立 `main()`。

## 状态机

- 启动：`PipController.initialize()` 读取存档 → 容错合并 → 跨天重置每日秒数 → 重算 streak；失败时回退演示状态并 Toast。
- 学习路径：`currentLessonId` 由完成情况推导；`startLesson(id, mode)` 校验解锁链，返回新 run 或进入对应词卡。
- 答题：`selectAnswer` → `checkAnswer`（首答统计、生命、每日秒数、chime）→ 正确 `advanceQuestion` / 错误 `retryAnswer`。`advanceQuestion` 在最后一题生成 `LessonResult` 并 `pushReplacement` 到结算页。
- 结算：首次完成写入完成标记与 XP，解锁下一课；CTA 按 `demo / challenge / review / 普通` 规则决定目标 Tab。
- 复习：复习首页 → 词卡（翻转、记住 / 跳过、轮次）→ 完成态；掌握状态写回 `reviewMastered` 并持久化，返回时保留主题。
- 成就：弹窗动作为分享或“去完成这一步”；分享失败写剪贴板并 Toast。
- 退出：答题页关闭会暂停并保存 run；系统返回键与页面关闭按钮等价。结算页不会回到最后一题。

所有写入通过串行保存队列提交；状态对象不可变，UI 由 `ListenableBuilder` 重建。

## 演示配置

`AppLaunchConfig`：`initialTab`、`demoCorrectFeedback`、`demoComplete`、`readOnlyDemo`、`soundOn`。只读演示不写存档；演示结算使用与原型一致的 100% / +24 XP 数据。

## 与规格的差异

- 未实现 Web URL 参数解析；使用 `AppLaunchConfig` 提供等价能力（规格明确允许）。
- 分享使用 `share_plus` 系统面板；不可用时复制到剪贴板，未额外实现平台专属分享渠道。
- 验收截图为 390×844 的 Flutter 渲染结果，保存在 `docs/screenshots/`；未附带生成脚本。
- 屏幕阅读器语义已实现，但未在真机上逐项执行 VoiceOver / TalkBack 手工走查。
