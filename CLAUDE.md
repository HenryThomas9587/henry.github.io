# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

这是一个使用 VuePress 2.x 和 vuepress-theme-plume 主题构建的个人技术博客网站，主要包含 Android、Flutter 等技术笔记。网站支持中英文双语，通过 GitHub Actions 自动部署到 GitHub Pages。

## Essential Commands

### Development
```bash
# 启动开发服务器
pnpm run docs:dev

# 清除缓存后启动开发服务器（用于解决缓存问题）
pnpm run docs:dev-clean

# 本地预览生产构建
pnpm run docs:preview
```

### Build & Deploy
```bash
# 构建生产版本（会自动清除缓存）
pnpm run docs:build

# 更新 VuePress 和主题到最新版本
pnpm run vp-update
```

### Package Manager
- 使用 **pnpm**（项目中存在 pnpm-lock.yaml）
- 安装依赖：`pnpm install`
- CI 环境：`pnpm install --frozen-lockfile`

## Architecture

### Directory Structure

```
docs/
├── .vuepress/
│   ├── config.ts          # VuePress 主配置
│   ├── plume.config.ts    # Plume 主题配置
│   ├── navbar.ts          # 导航栏配置（中英文）
│   ├── notes.ts           # 笔记分类配置（中英文）
│   ├── client.ts          # 客户端增强
│   ├── public/            # 静态资源
│   └── theme/             # 主题自定义
├── notes/                 # 中文笔记目录
│   ├── android/          # Android 笔记
│   │   ├── framework/    # Android Framework 系列
│   │   └── ai/           # AI 相关内容
│   ├── flutter/          # Flutter 笔记
│   └── ui/               # UI 相关笔记
├── en/                    # 英文站点镜像结构
└── README.md             # 首页
```

### Configuration Files

1. **docs/.vuepress/config.ts**: VuePress 核心配置
   - `base`: 设置为 `/henry.github.io/`，需与 GitHub 仓库名匹配
   - `locales`: 多语言配置（zh-CN, en-US）
   - `bundler`: 使用 Vite 构建
   - `theme`: Plume 主题配置入口

2. **docs/.vuepress/plume.config.ts**: Plume 主题配置
   - `profile`: 站点头像和描述
   - `navbar` 和 `notes`: 通过独立文件管理
   - `plugins`: 代码高亮（Shiki）、Markdown 增强、数学公式（KaTeX）等

3. **docs/.vuepress/notes.ts**: 笔记分类配置
   - 每个笔记分类需定义 `dir`、`link` 和 `sidebar`
   - 中文笔记使用 `sidebar: "auto"` 自动生成侧边栏
   - 英文笔记使用手动配置的 sidebar 数组

4. **docs/.vuepress/navbar.ts**: 导航栏配置
   - 分别配置中文（zhNavbar）和英文（enNavbar）导航
   - 笔记菜单使用 `items` 数组支持下拉菜单

### Multi-language Support

- 默认语言：中文（zh-CN）
- 备选语言：英文（en-US）
- 中文内容位于 `docs/` 根目录
- 英文内容位于 `docs/en/` 目录
- 导航和笔记配置分别在 navbar.ts 和 notes.ts 中维护双语版本

### Code Highlighting

项目已预设以下语言高亮（docs/.vuepress/config.ts:79-110）：
- Shell: bash, shell, sh, zsh
- Web: typescript, javascript, html, css, scss
- 移动端: kotlin, java, dart, swift
- 系统: go, c, c++, python, ruby, php
- 数据: json, yaml, xml, sql
- 其他: mermaid, markdown

添加新语言需修改 `shiki.languages` 数组。

### GitHub Actions Deployment

- 触发条件：push 到 main 分支 或 手动触发
- Node.js 版本：20
- 构建输出：`docs/.vuepress/dist`
- 部署分支：`gh-pages`
- 需要在 GitHub 仓库设置中：
  - 开启 Actions 的 Read and write permissions
  - Pages 设置为从 gh-pages 分支部署

## Custom Skills

### gen-note-config - 笔记配置自动生成

**位置**: `.claude/skills/gen-note-config/`

自动扫描 `docs/notes` 目录并生成 `navbar.ts` 和 `notes.ts` 配置文件。

**使用方法**:
```bash
bash .claude/skills/gen-note-config/gen-note-config.sh
```

**适用场景**:
- 添加新笔记分类后自动更新配置
- 重新整理笔记结构
- 保持配置文件与目录同步

详细文档:
- [SKILL.md](.claude/skills/gen-note-config/SKILL.md) - 完整功能说明
- [EXAMPLES.md](.claude/skills/gen-note-config/EXAMPLES.md) - 使用示例

## Common Tasks

### 添加新笔记分类

**方法 1: 使用 gen-note-config skill（推荐）**

1. 在 `docs/notes/` 下创建新目录（如 `new-topic/`）
2. 创建 README.md 并添加 frontmatter:
   ```markdown
   ---
   title: 新主题
   ---
   ```
3. 运行自动生成脚本:
   ```bash
   bash .claude/skills/gen-note-config/gen-note-config.sh
   ```

**方法 2: 手动配置**

1. 在 `docs/notes/` 下创建新目录（如 `new-topic/`）
2. 在 `docs/.vuepress/notes.ts` 中添加配置：
   ```typescript
   const zhNewTopicNote = defineNoteConfig({
     dir: "new-topic",
     link: "/new-topic",
     sidebar: "auto",
   });
   ```
3. 将新笔记添加到 `zhNotes.notes` 数组
4. 在 `docs/.vuepress/navbar.ts` 中添加导航入口

### 修改站点 base 路径

如果更改仓库名或部署路径：
- 修改 `docs/.vuepress/config.ts` 中的 `base` 选项
- 格式：`"/仓库名/"`（用户名.github.io 仓库则使用 `"/"`）

### 启用或禁用插件功能

所有插件配置位于 `docs/.vuepress/config.ts` 的 `plugins` 对象中：
- 评论系统：`comment` (已注释)
- 水印：`watermark` (已注释)
- Markdown 导入：`markdownInclude` (已注释)
- 图片尺寸自动填充：`markdownPower.imageSize` (已注释)

取消注释并配置相应选项即可启用。

## Important Notes

- **Node.js 版本要求**：^18.20.0 || >=20.0.0
- **缓存机制**：主题使用 filesystem 缓存加速编译，遇到问题时使用 `docs:dev-clean` 清除
- **自动 Frontmatter**：主题会自动为 markdown 文件添加 permalink、createTime 和 title
- **性能优化**：`shouldPrefetch: false` 已禁用预加载，适合大型站点
- **代码高亮**：强烈建议预设语言列表，避免加载所有语言导致性能开销
