# 「拾页」Flutter 落地交接包

本目录是 Web 原型 `https://ui.oiloil.org/works/diary/live/index.html`（重定向到 `oil-ui-gallery.vercel.app`）的 Flutter 实现资料包。它不依赖上一轮对话，任何一个新的 AI Agent 或工程师拿到整个目录即可独立完成实现。

## 先看什么

1. **`AGENT_PROMPT.md`**：可直接复制给实现 AI 的任务提示词。
2. **`FLUTTER_IMPLEMENTATION_SPEC.md`**：完整产品行为、视觉规范、数据模型、交互状态机、验收标准。
3. **`seed/materials.json`**：素材目录、分类文案、粘贴默认位置。
4. **`seed/entries.json`**：2026 年 9 月 17 天 + 10 月 4 天的示例手账数据。
5. **`reference/`**：8 张关键界面与交互结果截图，用于视觉对照。
6. **`assets/`**：原型使用的全部贴纸、照片、纸张纹理、图标。

## 目录结构

```text
diary_flutter_handoff/
├── README.md
├── AGENT_PROMPT.md
├── FLUTTER_IMPLEMENTATION_SPEC.md
├── assets/
│   ├── stickers/       6 个 SVG 贴纸
│   ├── photos/         4 张 WebP 照片（760x1140）
│   ├── textures/       paper-grain.svg + paper-grain.png
│   └── icons/          13 个线性 SVG 图标
├── seed/
│   ├── materials.json
│   └── entries.json
└── reference/
    ├── 01-journal.png
    ├── 02-drawer-stickers.png
    ├── 03-drawer-tapes.png
    ├── 04-drawer-notes.png
    ├── 05-drawer-photos.png
    ├── 06-month.png
    ├── 07-text-editor.png
    └── 08-sticker-pasted.png
```

## 一句话理解产品

一个手机端电子手账：在固定纸质页面上拼贴照片、贴纸、胶带、便签，写上标题和正文，保存后通过月历回看。共三个页面：手账、素材抽屉、翻看。

## 关键实现结论

- **技术形态**：Flutter 单页应用，无后端、无账号、无云同步；数据本地持久化。
- **默认演示时钟**：原型把“今天”写死为 **2026-10-04**，月历默认停在 **2026 年 9 月、选中 27 日**。为了视觉/行为 1:1，默认保留这个演示模式；真实日期模式作为可切换项。
- **持久化**：用 `shared_preferences` 对应原型的 `localStorage`（key 仍用 `shiye-entries-v1`）；上传照片建议落到应用文档目录，存文件路径而不是 base64。
- **交互核心**：选素材 → 贴到手账 → 拖动排版 → 保存；任何修改都可撤销（最多 15 步）。
- **截图说明**：`reference/` 里的深灰色圆角手机外框与大面积留白来自展示画廊容器，不属于 App；Flutter 只实现 390×844 的浅色应用区域，桌面调试时用 `#EAE3E7` 背景居中即可。

## 使用方式

把整个目录复制到 Flutter 工程外部或 `docs/` 下，让实现 AI 读取；然后把 `assets/`、`seed/` 注册进 `pubspec.yaml`。若仓库为空，先执行：

```bash
flutter create --org com.example --platforms=ios,android shiye
```

## 版权说明

原型素材（贴纸、照片、图标、纹理）来自上述公开原型页面，仅用于本项目的还原实现与演示；对外发布前请替换为你拥有授权的素材。
