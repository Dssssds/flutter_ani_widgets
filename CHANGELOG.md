# 更新日志

本项目的所有重要变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)。

## [未发布] / Unreleased

### 新增 (Added)
- 新增 28 个独立动画 / 交互组件（见 `lib/example/`）
- 新增 13 个完整 Demo App（见 `lib/app_demo/`）
- 集成 `flutter_animate` 简化动效编写
- 集成 `flutter_shaders` + `shaders/impeller.frag` 自定义片元着色器
- 集成 `forge2d` 2D 物理引擎
- 集成 `just_audio` + `just_waveform` 音频播放与波形
- 集成 `super_editor` 富文本编辑
- 集成 `table_calendar` 日历组件
- 集成 `flutter_3d_controller` 3D 数字模型展示
- 内置 `NeumaticGothic-Black/SemiBold` 与 `SF Pro Display` 字体资源
- 主页双 Tab + 2 列 GridView + `Hero` 动画过渡
- 完整项目说明文档 `docs/PROJECT_OVERVIEW.md`

### 变更 (Changed)
- 重写 `README.md`（新增 28 组件 / 13 Demo 完整列表、技术栈表、目录结构）
- 完善 `.gitignore`（新增 `.fleet/`、`.zed/`、各平台构建产物等条目）
- **重写 `.vscode/` 全套配置**：`settings.json` Dart 化（去除 cmake/java 残留）、新增 `extensions.json`（5 个推荐插件）、新增 `tasks.json`（7 个任务）、升级 `launch.json`（3 个调试配置 + 1 compound）
- **增强 `.zed/` 调试能力**：`tasks.json` 从 5 个任务扩展至 9 个（新增 DevTools / VM Service URL / attach / profile 四类调试任务），`settings.json` 新增 Zed 调试手册注释块

### 修复 (Fixed)
- 修正 `README.md` 中指向错误仓库（`Lakr233/NotchDrop`）的 LICENSE 链接
- 清理掉根目录误放的「产品说明文档.md」（与本项目无关的遗留文档）

### 移除 (Removed)
- 删除 `产品说明文档.md`（描述的是别的 p5.js / Matter.js 项目）
- 删除本地 IDE 残留 `flutter_x_widgets.iml`

## [1.0.0+1] - 2025-10-29

### 新增
- 初始化 `flutter_x_widgets` 仓库
- 接入 `lib/main.dart` Showcase 入口与 `HomeScreen` 双 Tab 主页
- 首次 `flutter pub get` 构建通过

---

[未发布]: https://github.com/<your-username>/flutter_ani_widgets/compare/v1.0.0+1...HEAD
[1.0.0+1]: https://github.com/<your-username>/flutter_ani_widgets/releases/tag/v1.0.0+1
