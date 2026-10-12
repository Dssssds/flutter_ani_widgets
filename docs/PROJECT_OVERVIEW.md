# Flutter X Widgets — 项目总览

> 本文档由 Cursor Assistant 基于项目扫描自动生成。用于弥补根目录 `README.md` 信息过于单薄的问题。

---

## 📱 项目一览

| 项 | 内容 |
| --- | --- |
| **名称** | `flutter_x_widgets`（Flutter 实验室 / Flutter X Widgets） |
| **类型** | Flutter 动画/交互 **组件 Showcase App** |
| **Flutter** | 3.35+ |
| **Dart SDK** | ^3.7.0 |
| **目标平台** | iOS 优先，README 推荐 iPhone 6 模拟器 |
| **入口** | `lib/main.dart` → `AnimationShowcaseApp` |

---

## 🗂️ 目录结构

```text
lib/
├── main.dart                     # Showcase 主页（两个 Tab：组件 / DemoAPP）
├── example/   (28 个独立组件示例)
│   ├── background_ripples/       # 呼吸动画
│   ├── blurfade/                 # 文字模糊渐变
│   ├── book_open/                # 书本翻开
│   ├── border_beam/              # 边框线条动画
│   ├── calendar/                 # 日历效果
│   ├── card_scroll/              # 自定义滑动列表
│   ├── card_scroll_joystick/     # 摇杆卡片
│   ├── celebrate/                # 庆祝动画
│   ├── custom_appbar/            # 自定义 AppBar
│   ├── dots/                     # 点阵图案
│   ├── folder_shape/             # 文件夹动画
│   ├── gemini_splash/            # Gemini Loading 飞溅
│   ├── grid_animation/           # 网格动画
│   ├── loader_avatars/           # 头像加载
│   ├── loader_sphere/            # 球形加载器
│   ├── loader_square/            # 方形加载器
│   ├── neon_card/                # 卡片霓虹灯背景
│   ├── notification_list/        # 通知列表
│   ├── photo_effect/             # 相片效果
│   ├── progress/                 # 花样进度条
│   ├── scroll_progress/          # 滚动进度
│   ├── stacked_cards/            # 卡片堆叠提示
│   ├── text_hyper/               # 文字滚动
│   ├── text_on_path/             # 文字控制器
│   ├── text_reveal/              # 文字动画（含 4 种策略）
│   ├── text_shine/               # 文字闪烁
│   ├── theme_mode/               # 主题灯泡切换
│   └── water_drop_button/        # 水滴按钮
└── app_demo/  (13 个完整 Demo App，编号 01–13)
    ├── 01  今日训练
    ├── 02  户外训练 TODO
    ├── 03  饮食清单
    ├── 04  3D 计算器
    ├── 05  认知训练
    ├── 06  iOS26 玻璃效果
    ├── 07  iOS26 桌面
    ├── 08  待办事项
    ├── 09  一起听音乐
    ├── 10  学习笔记
    ├── 11  图片编辑器
    ├── 12  积字成山待办
    └── 13  流光聊天
```

---

## 🏠 主页架构（`HomeScreen`）

- **双 Tab + PageView** 联动：「组件」(28 个) / 「DemoAPP」(13 个)
- **2 列 `GridView`** 卡片，点击用 `MaterialPageRoute` 进入
- **全屏 vs 普通页** 两种进入方式，通过 `AnimationExample.isFullScreen` 区分
- **Hero 动画** 包裹每个 demo 卡片的过渡
- 主题：纯黑底白字，`MaterialDark + 自定义 primary`
- 字体：自带 `NeumaticGothic-Black/SemiBold` + `SF Pro Display`

---

## 📦 关键依赖（`pubspec.yaml`）

| 用途 | 包 |
| --- | --- |
| 动画 | `flutter_animate` |
| 字体 | `google_fonts` |
| 富文本 | `super_editor` (0.3.0-dev.40) |
| 音频 | `just_audio`, `just_waveform` |
| 3D | `flutter_3d_controller` |
| 2D 物理 | `forge2d` |
| 着色器 | `flutter_shaders` + `shaders/impeller.frag` |
| 日历 | `table_calendar` |
| 网络图 | `cached_network_image` |
| 表达式 | `math_expressions` |

---

## ⚠️ 几个值得注意的细节

1. **`产品说明文档.md` 描述的不是本项目** —— 它讲的是一个 **Vanilla JS + p5.js + Matter.js** 的「Experimental-Todos」（Mountain Todo / Typographic Gravity），看起来是别的项目遗留文档，被误放到了这里。如果不需要可以删掉，避免误导。
2. **LICENSE 链接指向别的项目** —— README 里给的链接是 `Lakr233/NotchDrop/blob/main/LICENSE`，不是本仓库。
3. **README 内容很单薄**，真正能描述项目的只有 `lib/main.dart` 里的 `AnimationExample` 列表 + 「产品说明文档」（但产品说明文档对不上）。如果之后想发出去，建议重新写 README。
4. **`flutter_x_widgets.iml`** 是 JetBrains IDE 的配置，建议 `.gitignore` 忽略（如果你用 IDEA 之外的编辑器）。
5. 项目包含 **iOS/Android/macOS/Linux/Web/Windows** 六平台壳，但实际只对 iOS 做了优化。

---

_文档生成时间：基于项目扫描自动生成。_